function [data total_samples] = readTrainingExamplesAll(gestures)
%readTrainingExamples return training data split by gestures

data_path = '../data';

total_samples = 0;
data = cell(1,numel(gestures));
for i = 1:numel(gestures)
    gest = gestures{i};
    gest_path = [data_path '/' gest];
    filelist = dir([gest_path '/*.txt']);
    
    total_samples = total_samples + numel(filelist);
    
    % randomize order
    %filelist = filelist(randperm(numel(filelist)));
    
    gest_cell = cell(1,numel(filelist));
    
    gest_cell = cell(1,numel(filelist));
    for j = 1:numel(filelist)
        gest_cell{j} = filterPoints(readAccelData([gest_path '/' filelist(j).name]));
    end
    data{i} = gest_cell;
    
end

end

