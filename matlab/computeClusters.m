function clust = computeClusters(points, dictSize)

[m, dim] = size(points);

% Compute the average radius
centroid = mean(points);
avgRadius = 0;
for k=1:m
  radius = sqrt(dot(points(k,:) - centroid, points(k,:) - centroid));
  avgRadius = avgRadius + radius;
end

avgRadius = avgRadius / m;

% Do k-means
centers = zeros(dictSize, dim);

dlong = pi * (3 - sqrt(5));
long = 0;
dz = 2 / dictSize;
z = 1 - dz / 2;
for k=1:dictSize
  r = sqrt(1 - z * z);
  centers(k, 1) = cos(long) * r;
  centers(k, 2) = sin(long) * r;
  centers(k, 3) = z;
  z = z - dz;
  long = long + dlong;
end

centers = centers * avgRadius;
for k=1:dictSize
  centers(k,:) = centers(k,:) + centroid;
end

% scatter3(centers(:,1), centers(:,2), centers(:,3), clustSizes * 5, 'g')

[IDX, clust] = kmeans(points, dictSize, 'start', centers, 'emptyaction', 'drop');
% [IDX, C] = kmeans(points, dictSize, 'emptyaction', 'drop');

end