%%

accuracy = [];
for i = 10:5:50
    disp(['NUM CLUSTERS: ' num2str(i)]);
    accuracy(end+1) = testClusterMatching(i);
end