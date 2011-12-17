function [between_group_var within_group_var total_var total_mean  ] = findOptimalClustering(data)

allData = zeros(0, size(data{1}{1},2));
for k=1:numel(data)
    exampleData = vertcat(data{k}{:});
    allData = [allData ; exampleData];
end

total_var = mean(var(allData));
total_mean = mean(allData,1);
clust_range = 10:100;
between_group_var = [];
within_group_var = [];

for i = 1:numel(clust_range)
    num_clusters = i + clust_range(1) - 1;
    disp(['Num clusters: ' num2str(num_clusters)]);
    clust = computeClusters(allData, num_clusters);
    T = delaunayn(clust);
    cat = dsearchn(clust, T, allData);
     
    clust_data = cell(1,num_clusters);
    within_var = [];
    for j = 1:numel(clust_data)
        clust_data{j} = allData(logical(cat == j));
        within_var(j) = mean(var(clust_data{j}));
    end
    within_group_var(i) = mean(within_var);
    
    %group_means = zeros(0,size(allData,2));
    var_sum = 0;
    for j = 1:numel(clust_data)
        var_sum = var_sum + size(clust_data{j},1)*(mean(clust_data{j},1) - total_mean) .^ 2;
        %group_means(j,:) = mean(clust_data,1);
    end
    between_group_var(i) = mean(var_sum) / num_clusters;
    
end

end

