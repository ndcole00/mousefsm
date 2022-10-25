classdef lightBox
    %LIGHTBOX class to hold the optogenetic stimuli when using the
    %projector as an optogenetic lightsource in widefield recordings

    properties
        imagesLocation
        imagePaths
        imageIDs
        loadedImages
        imageTextures
        destRects
        numOfImages
        imageHeight
        Xoffset
        Yoffset
        displayInfo
        outputLine
        roundDisplayOrder
        currentImageID
        currentTrial
        tbtImageID
        tbtTrialNum
        psuedorandom
    end

    methods
        function obj = lightBox(presSettings)
            %UNTITLED4 Construct an instance of this class
            %   Detailed explanation goes here
            obj.imagesLocation = presSettings.imagesLocation;
            if isempty(obj.imagesLocation)
                obj.imagesLocation = uigetdir('', 'Please select the folder to get the optogenetic stimuli from:');
            end
            obj.roundDisplayOrder = [];
            obj.imageHeight = presSettings.imageHeight;
            obj.Xoffset = presSettings.Xoffset;
            obj.Yoffset = presSettings.Yoffset;
            obj.displayInfo.screenSettings.size = [presSettings.screenRect(3), presSettings.screenRect(4)];
            obj.displayInfo.screenSettings.centre = [obj.displayInfo.screenSettings.size(1)/2, obj.displayInfo.screenSettings.size(2)/2];
            obj.displayInfo.winPrimary = presSettings.psychWindow;
            obj = obj.prepareImages;
            obj.psuedorandom = presSettings.psuedorandom;

            obj.currentTrial = 0;
            obj.currentImageID = nan;
            if obj.psuedorandom
                obj = obj.prepareRound;
            end
        end


        function obj = prepareImages(obj)
            %Make the list of images:
            imageDir = dir(obj.imagesLocation);
            dirIndex = find(~[imageDir.isdir])';

            %Sort the images so they are ordered in number order
            imageList = arrayfun(@(x) fullfile(imageDir(x).folder, imageDir(x).name), dirIndex, 'uni', 0);
            imageName = arrayfun(@(x) regexp(imageDir(x).name, ['\.'], 'split'), dirIndex, 'uni', 0);

            for ii = 1:length(imageName)
                imageList{ii,2} = str2double(imageName{ii,1}{1,1});
            end
            imageList = sortrows(imageList,2);

            obj.imagePaths = imageList(:,1);
            obj.imageIDs = imageList(:,2);
            obj.numOfImages = length(obj.imageIDs);

            %Calculate whether a shift of the stimuli is needed
            if abs(obj.Xoffset) <=1
                xShift = obj.Xoffset*obj.displayInfo.screenSettings.centre(1);
            else
                xShift = obj.Xoffset;
            end
            if abs(obj.Yoffset) <=1
                yShift = obj.Yoffset*obj.displayInfo.screenSettings.centre(2);
            else
                yShift = obj.Yoffset;
            end


            % Load all the images
            for jj = 1:length(obj.imagePaths)
                obj.loadedImages{jj,1} = imread(obj.imagePaths{jj});

                % Make textures for all the images
                % Get the size of the image
                [s1, s2, s3] = size(obj.loadedImages{jj,1});
                aspectRatio = s2 / s1;

                imageWidth = round(obj.imageHeight*aspectRatio);

                %Rescaling the image
                theRect = [0 0 imageWidth, obj.imageHeight];
                obj.destRects{jj} = CenterRectOnPointd(theRect, obj.displayInfo.screenSettings.centre(1)+xShift, obj.displayInfo.screenSettings.centre(2)+yShift);

                % Make the image into a texture
                obj.imageTextures{jj,1} = Screen('MakeTexture', obj.displayInfo.winPrimary, obj.loadedImages{jj,1});
            end
        end

        function obj = prepareRound(obj)
            obj.roundDisplayOrder = randperm(obj.numOfImages)';
        end

        function obj = prepareNextStimulus(obj)

            if obj.currentTrial == obj.numOfImages && obj.psuedorandom
                obj.currentTrial = 1;
                obj.prepareRound;
            else
                obj.currentTrial = obj.currentTrial+1;
            end

            % Setup the next stimulus
            if obj.psuedorandom
            obj.currentImageID = obj.roundDisplayOrder(obj.currentTrial);
            else
                obj.currentImageID = randperm(obj.numOfImages, 1);
            end

            obj.tbtImageID(end+1,1) = obj.currentImageID;
            obj.tbtTrialNum(end+1,1) = obj.currentTrial;
        end
    end
end

