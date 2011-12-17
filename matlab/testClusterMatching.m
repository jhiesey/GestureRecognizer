function total_accuracy = testClusterMatching(num_clusters)


[data, total_samples] = readTrainingExamplesAll({'triangles', 'circles', 'bowling','upflips','rightflips','squares'});


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

% 
% for scrams = 1:(numel(data{1})+numel(data{2}))
%     ind1 = Sample(1:numel(data{1}));
%     ind2 = Sample(1:numel(data{2}));
%     temp = data{1}(ind1);
%     data{1}(ind1) = data{2}(ind2);
%     data{2}(ind2) = temp;
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
    
    for i = 1:numel(data)
        allData{i} = zeros(0, size(training{1}{1},2));
    end
    
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
                distance_final = norm(distance)^2;
                
                [PSTATES loglikz] = hmmdecode(seq, transmats{l}, obsmats{l});
                loglik(l) = loglikz * distance_final;
                %loglik(l) = -1 * distance_final;
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
total_accuracy = mean(accuracy);

end