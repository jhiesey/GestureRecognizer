
num_clusters = 10;     % number of clusters in our emission alphabet

[data, total_samples] = readTrainingExamplesAll({'circles', 'triangles'});


% training and testing are each cell arrays containing a cell array for
% each gesture. Each of these gesture cell arrays contains a matrix of
% accel data.


% num_folds = total_samples;
% fold_labels = crossvalind('Kfold', total_samples, num_folds);
% kfold_ind = cell(1,numel(data));
% segment_index = 0;
% for g = 1:numel(data)
%     kfold_ind{g} = fold_labels(segment_index+1:numel(data{g}));
%     segment_index = segment_index + numel(data{g});
% end

num_folds = 10;
kfold_ind = cell(1,numel(data));
for g = 1:numel(data)
    kfold_ind{g} = crossvalind('Kfold', numel(data{g}), num_folds);
end

accuracy = zeros(1,num_folds);
for fold = 1:num_folds
    
    % split the data into these vars for this fold
    training = cell(1,numel(data));
    testing = cell(1,numel(data));
    for g = 1:numel(data)
        training{g} = data{g}(kfold_ind{g} ~= fold);
        testing{g} = data{g}(kfold_ind{g} == fold);
    end
    
    % collect all training data samples together for clustering
    
    allData = cell(numel(data), 1);
    
    allData{1} = zeros(0, size(training{1}{1},2));
    allData{2} = zeros(0, size(training{1}{1},2));
    
    for k=1:numel(training)
        exampleData = vertcat(training{k}{:});
        allData{k} = [allData{k} ; exampleData];
        
    end
    
    % computer cluster centroids
    clust = cell(numel(data), 1);
    T = cell(numel(data), 1);
    
    for k=1:numel(training)
        clust{k} = computeClusters(allData{k}, num_clusters);
        clust{k};
        % computer delauny simplices from cluster centroids
        T{k} = delaunayn(clust{k});
    end
    
    
    prior_init = 1/8 * ones(8,1);
    emission_init = 1/num_clusters * ones(8, num_clusters); % init emission matrix with first guess
    trans_init = ...                % init transistion matrix with first guess
        [ 1/3 1/3 1/3 0 0 0 0 0; ...
        0 1/3 1/3 1/3 0 0 0 0; ...
        0 0 1/3 1/3 1/3 0 0 0; ...
        0 0 0 1/3 1/3 1/3 0 0; ...
        0 0 0 0 1/3 1/3 1/3 0; ...
        0 0 0 0 0 1/3 1/3 1/3; ...
        0 0 0 0 0 0 1/2 1/2; ...
        0 0 0 0 0 0 0 1 ...
        ];
    
    
    transmats = cell(size(training));   % holds the learned transistion matrix for each gesture HMM
    obsmats = cell(size(training));     % holds the learned emission matrix for each geture HMM
    
    
    
    for k=1:numel(training)
        gestureExamples = training{k};
        numExamples = numel(gestureExamples);
        
        % convert training samples into symbol sequences
        seq = cell(1, numExamples);
        for l=1:numExamples
            seq{l} = dsearchn(clust{k}, T{k}, gestureExamples{l})';
        end
        
        % train and save the HMM
        [transmat, obsmat] = hmmtrain(seq, trans_init, emission_init, 'maxiterations', 15, 'verbose', false);
        transmats{k} = transmat;
        obsmats{k} = obsmat;
    end
    
    
    % test classifier
    num_gestures = numel(testing);
    num_correct = 0;
    num_total = 0;
    for g = 1:num_gestures
        for k = 1:numel(testing{g})
            % discretize
            %seq = dsearchn(clust, T, testing{g}{k})';
            
            % try all HMMs
            loglik = zeros(1, num_gestures);
            for l = 1:num_gestures
                loglikz = 0;
                [seq1, distance] = dsearchn(clust{l}, T{l}, testing{g}{k});
                seq = seq1';
                distance_final = norm(distance);
                
                [PSTATES loglikz] = hmmdecode(seq, transmats{l}, obsmats{l});
                loglik(l) = loglikz * distance_final
            end
            [val, ind] = max(loglik);   % find max loglik gesture model
            if ind == g
                num_correct = num_correct + 1;
            end
            num_total = num_total + 1;
        end
    end
    disp(['Accuracy of ' num2str(num_correct / num_total) ' on ' num2str(num_total) ' test samples']);
    accuracy(fold) = num_correct / num_total;
end
disp(['Overall accuracy of ' num2str(mean(accuracy)) ' on ' num2str(num_folds) '-fold cross validation']);


% allData = readAccelData('../data/circles/xbowSensorLog.txt');
%
% origPoints = allData(:,5:7);
%
% hold on
% scatter3(origPoints(:,1), origPoints(:,2), origPoints(:,3), 2, 'k')
%
% [IDX, C] = computeClusters(origPoints);
%
% IDX
% C
% clustSizes = zeros(dictSize, 1);
% for k=1:m
%   clustSizes(IDX(k)) = clustSizes(IDX(k)) + 1;
% end
%
% maxSize = max(clustSizes);
% clustSizes = clustSizes ./ (maxSize / 10);
%
% scatter3(C(:,1), C(:,2), C(:,3), clustSizes * 5, 'b')

