function [training, testing] = readTrainingExamples(gestures, proportion)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

data_path = '../data';

training = cell(1,numel(gestures));
testing = cell(1,numel(gestures));
for i = 1:numel(gestures)
    gest = gestures{i};
    gest_path = [data_path '/' gest];
    filelist = dir([gest_path '/*.txt']);
    
    gest_cell = cell(1,numel(filelist));
    
    cutoff = round(numel(filelist) * proportion);
    trainlist = filelist(1:cutoff);
    testlist = filelist(cutoff+1:end);
    
    gest_cell = cell(1,numel(trainlist));
    for j = 1:numel(trainlist)
        gest_cell{j} = filterPoints(readAccelData([gest_path '/' trainlist(j).name]));
    end
    training{i} = gest_cell;
    
    gest_cell = cell(1,numel(testlist));
    for j = 1:numel(testlist)
        gest_cell{j} = filterPoints(readAccelData([gest_path '/' testlist(j).name]));
    end
    testing{i} = gest_cell;
end

end

