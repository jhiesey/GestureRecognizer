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