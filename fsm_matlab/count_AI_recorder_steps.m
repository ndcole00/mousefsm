function step_number = count_AI_recorder_steps(AI_filename)
      
    threshold = 50;
    ai_contents = readAIrecorderBinFile(AI_filename);
    differences = diff(ai_contents.data(:, 1));
    step_number = find(differences > threshold)
    step_number = size(step_number)
    step_number = step_number(1)
   
end