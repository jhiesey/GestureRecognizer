function [IDX, C] = computeClusters(origPoints)

[origM, origDim] = size(origPoints);
threshold = 0.1;

% Filter, keeping samples with large deltas only
points = zeros(1, 3);
points(1,:) = origPoints(1,:);
m = 1;
for k=2:origM
  % distSq = dot(origPoints(k,:), origPoints(m,:));
  distSq = dot(origPoints(k,:), origPoints(k - 1,:));
  if distSq > threshold
     points = [points; origPoints(k,:)];
     m = m + 1;
  end
end


% Compute the average radius
centroid = mean(points);
avgRadius = 0;
for k=1:m
  radius = sqrt(dot(points(k,:) - centroid, points(k,:) - centroid));
  avgRadius = avgRadius + radius;
end

avgRadius = avgRadius / m;

% Do k-means
dictSize = 10;
centers = zeros(dictSize, 3);

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

[IDX, C] = kmeans(points, dictSize, 'start', centers, 'emptyaction', 'drop');
% [IDX, C] = kmeans(points, dictSize, 'emptyaction', 'drop');

end