classdef BigTiffReader < handle
    % this reader relies on constant sizes of IFD and frame data
    % developed to be compatible with ScanImage BigTiff files
    % Tiff file documentation: https://www.awaresystems.be/imaging/tiff.html
    % https://www.itu.int/itudoc/itu-t/com16/tiff-fx/docs/tiff6.pdf
    
    properties (Access = private)
        fid = [];
        firstStripOffset;
        stripByteCounts;
        stripOffsetDelta;
        imageWidth;
        imageLength;
        imageDatatype;
        bytesPerPixel;
    end
    
    %% Lifecycle
    methods
        function obj = BigTiffReader(filePath)
            obj.fid = fopen(filePath,'r');
            assert(obj.fid > 0,'Could not open file %s',filePath);
            
            % check file type
            fileIdentifier = fread(obj.fid,2,'*uint8');
            assert(isequal(fileIdentifier,[73;73]),'Not a Tiff file in little endian format'); % 0x4949 II
            tiffVersion = fread(obj.fid,2,'*uint8');
            assert(isequal(tiffVersion,[43;0]),'Not a BigTiff file'); %0x002B
            
            % get offsets
            assert(fread(obj.fid,1,'*uint16')==8,'Byte Size of Offsets is not 8');
            assert(fread(obj.fid,1,'*uint16')==0,'Placeholder is not 0');
            
            firstDirectoryOffset = fread(obj.fid,1,'*uint64');
            
            error = fseek(obj.fid,firstDirectoryOffset,-1); % go to first directory
            assert(error==0,'Reached end of file before first directory');
            [tags,secondDirectoryOffset] = obj.readTags();
            
            obj.firstStripOffset = tags(273); % StripOffsets
            obj.stripByteCounts  = tags(279); % StripByteCounts
            obj.stripOffsetDelta = secondDirectoryOffset - firstDirectoryOffset;
            obj.imageWidth       = tags(256);
            obj.imageLength      = tags(257);
            
            sampleFormat = tags(339);
            bitsPerPixel = tags(258);
            
            assert(ismember(bitsPerPixel,[8,16,32]),'Unsupported data format');
            obj.bytesPerPixel = uint64(bitsPerPixel / 8);
            switch sampleFormat
                case 1 % unsigned
                    obj.imageDatatype = sprintf('uint%d',bitsPerPixel);
                case 2 % signed
                    obj.imageDatatype = sprintf('int%d',bitsPerPixel);
                otherwise
                    error('Unsupported sample format');
            end            
        end
        
        function delete(obj)
            if ~isempty(obj.fid) && obj.fid >= 0
                fclose(obj.fid);
            end
        end
    end
    
    %% User Methods
    methods
        function data = readFrame(obj,frameIdx)
            validateattributes(frameIdx,{'numeric'},{'scalar','integer','positive'});
            offset = obj.firstStripOffset + obj.stripOffsetDelta * uint64(frameIdx-1);
            error = fseek(obj.fid,offset,-1);
            assert(~error,'Reached end of file');
            
            nPixels = obj.stripByteCounts/obj.bytesPerPixel;
            data = fread(obj.fid, nPixels, ['*' obj.imageDatatype]);
            
            data = reshape(data,obj.imageWidth,obj.imageLength);
            data = data'; % this 
        end
    end
    
    %% Internal Methods
    methods (Access = private)        
        function [tags,nextDirectoryOffset] = readTags(obj)
            numberDirectoryEntries = fread(obj.fid,1,'*uint64');
            tags = containers.Map('KeyType','double','ValueType','any');
            
            for idx = 1:numberDirectoryEntries
                [identifier,data] = readTag();
                tags(double(identifier)) = data;
            end
            
            nextDirectoryOffset = uint64(fread(obj.fid,1,'*uint64'));
            
            function [identifier, data] = readTag()
                identifier = fread(obj.fid,1,'*uint16');
                dataType   = fread(obj.fid,1,'*uint16');
                elements   = fread(obj.fid,1,'*uint64');
                data       = fread(obj.fid,8,'*uint8');
                
                switch dataType
                    case 1 % 1 = BYTE 8-bit unsigned integer
                        % No-op
                    case 2 % 2 = ASCII 8-bit byte that contains a 7-bit ASCII code; the last byte must be NUL (binary zero).
                        % No-op
                    case 3 % 3 = SHORT 16-bit (2-byte) unsigned integer.
                        data = typecast(data,'uint16');
                    case 4 % 4 = LONG 32-bit (4-byte) unsigned integer.
                        data = typecast(data,'uint32');
                    case 5 % 5 = RATIONAL Two LONGs: the first represents the numerator of a fraction; the second, the denominator.
                        data = double(typecast(data,'uint32'));
                        data = data(1)/data(2);
                    case 6 % 6 = SBYTE An 8-bit signed (twos-complement) integer.
                        data = typecast(data,'int8');
                    case 7 % 7 = UNDEFINED An 8-bit byte that may contain anything, depending on the definition of the field.
                        data = data(1:elements);
                    case 8 % 8 = SSHORT A 16-bit (2-byte) signed (twos-complement) integer.
                        data = typecast(data,'int16');
                    case 9 % 9 = SLONG A 32-bit (4-byte) signed (twos-complement) integer.
                        data = typecast(data,'int32');
                    case 10 % 10 = SRATIONAL Two SLONG’s: the first represents the numerator of a fraction, the second the denominator.
                        data = double(typecast(data,'int32'));
                        data = data(1)/data(2);
                    case 11 %11 = FLOAT Single precision (4-byte) IEEE format.
                        data = typecast(data,'single');
                    case 12 % 12 = DOUBLE Double precision (8-byte) IEEE format.
                        data = typecast(data,'double');
                    case 16 % 16 = TIFF_LONG8 being unsigned 8byte integer
                        data = typecast(data,'uint64');
                    case 17 % 17 = TIFF_SLONG8 being signed 8byte integer
                        data = typecast(data,'int64');
                    case 18 % 18 = TIFF_IFD8 being a new unsigned 8byte IFD offset.
                        data = typecast(data,'uint64');
                    otherwise
                        % no conversion
                end
                
                if elements < numel(data)
                    data = data(1:elements);
                end
            end
        end
    end
end