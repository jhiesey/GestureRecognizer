function points = filterPoints(origPoints)

[origM, origDim] = size(origPoints);
threshold = 0.1;

% Filter, keeping samples with large deltas only
points = zeros(1, 3);
points(1,:) = origPoints(1,:);
for k=2:origM
  % distSq = dot(origPoints(k,:), origPoints(m,:));
  distSq = dot(origPoints(k,:), origPoints(k - 1,:));
  if distSq > threshold
     points = [points; origPoints(k,:)];
  end
end