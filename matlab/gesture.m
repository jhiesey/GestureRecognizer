
num_clusters =  28;
[training, testing] = readTrainingExamples({'circles', 'triangles'}, 0.7);

allData = zeros(0, size(training{1}{1},2));
for k=1:numel(training)
  exampleData = vertcat(training{k}{:});
  allData = [allData ; exampleData];
end

clust = computeClusters(allData, num_clusters);
T = delaunanyn(clust);

emission_init = ones(num_clusters, );
trans_init = ...
[ 1/3 1/3 1/3 0 0 0 0 0; ...
  0 1/3 1/3 1/3 0 0 0 0; ...
  0 0 1/3 1/3 1/3 0 0 0; ...
  0 0 0 1/3 1/3 1/3 0 0; ...
  0 0 0 0 1/3 1/3 1/3 0; ...
  0 0 0 0 0 1/3 1/3 1/3; ...
  0 0 0 0 0 0 1/2 1/2; ...
  0 0 0 0 0 0 0 0 1 ...
];

for k=1:numel(training)
  gestureExamples = training{k};
  numExamples = numel(gestureExamples);
  sample = cell(1, numExamples);
  for l=1:numExamples
    sample{l} = dsearchn(clust, T, gestureExamples{l});
  end
  dhmm_em(sample, trans_init, emission_init);
end

allData = readAccelData('../data/circles/xbowSensorLog.txt');

origPoints = allData(:,5:7);

hold on
scatter3(origPoints(:,1), origPoints(:,2), origPoints(:,3), 2, 'k')

[IDX, C] = computeClusters(origPoints);

IDX
C
clustSizes = zeros(dictSize, 1);
for k=1:m
  clustSizes(IDX(k)) = clustSizes(IDX(k)) + 1;
end

maxSize = max(clustSizes);
clustSizes = clustSizes ./ (maxSize / 10);

scatter3(C(:,1), C(:,2), C(:,3), clustSizes * 5, 'b')