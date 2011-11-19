
num_clusters =  28;
[training, testing] = readTrainingExamples({'circles', 'triangles'}, 0.7);

allData = zeros(0, size(training{1}{1},2));
for k=1:numel(training)
  exampleData = vertcat(training{k}{:});
  allData = [allData ; exampleData];
end

clust = computeClusters(allData, num_clusters);
T = delaunayn(clust);

prior_init = 1/8 * ones(8,1);
emission_init = 1/num_clusters * ones(8, num_clusters);
trans_init = ...
[ 1/3 1/3 1/3 0 0 0 0 0; ...
  0 1/3 1/3 1/3 0 0 0 0; ...
  0 0 1/3 1/3 1/3 0 0 0; ...
  0 0 0 1/3 1/3 1/3 0 0; ...
  0 0 0 0 1/3 1/3 1/3 0; ...
  0 0 0 0 0 1/3 1/3 1/3; ...
  0 0 0 0 0 0 1/2 1/2; ...
  0 0 0 0 0 0 0 1 ...
];

% prior_init = normalise(rand(8,1));
% trans_init = mk_stochastic(rand(8,8));
% emission_init = mk_stochastic(rand(8, num_clusters)); 


priors = cell(size(training));
transmats = cell(size(training));
obsmats = cell(size(training));
for k=1:numel(training)
  gestureExamples = training{k};
  numExamples = numel(gestureExamples);
  sample = cell(1, numExamples);
  for l=1:numExamples
    sample{l} = dsearchn(clust, T, gestureExamples{l});
  end
  [ll_trace, prior, transmat, obsmat, iterNr] = dhmm_em(sample, prior_init, trans_init, emission_init, 'max_iter', 15);
  priors{k} = prior;
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
        disc_test = dsearchn(clust, T, testing{g}{k});
        
        % try all HMMs
        loglik = zeros(1, num_gestures);
        for l = 1:num_gestures
            loglik(l) = dhmm_logprob(disc_test, priors{l}, transmats{l}, obsmats{l});
        end
        [val, ind] = max(loglik);
        if ind == g
            num_correct = num_correct + 1;
        end
        num_total = num_total + 1;
    end
end
disp(['Accuracy of ' num2str(num_correct / num_total) ' on ' num2str(num_total) ' test samples']);


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

