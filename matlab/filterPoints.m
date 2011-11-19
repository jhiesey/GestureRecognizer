function points = filterPoints(origPoints)

[origM, origDim] = size(origPoints);
threshold = 0.1;

% dim selection
dim_select = [5:7 11:13];

% Filter, keeping samples with large deltas only
points = zeros(1, numel(dim_select));
points(1,:) = origPoints(1,dim_select);
for k=2:origM
  % distSq = dot(origPoints(k,:), origPoints(m,:));
  distSq = dot(origPoints(k,dim_select), origPoints(k - 1,dim_select));
  if distSq > threshold
     points = [points; origPoints(k,dim_select)];
  end
end