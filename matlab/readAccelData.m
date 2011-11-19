function data_matrix = readAccelData( filename )
%READACCELDATA Summary of this function goes here
%   Detailed explanation goes here

% time, xMag, yMag, zMag, xAccel, yAccel, zAccel, latitude, longitude,
% altitude, xRate, yRate, zRate, roll, pitch, yaw

data_matrix = zeros(0,16);
fid = fopen(filename);
line_num = 0;
while ~feof(fid)
    curr_line = strtrim(fgets(fid));
    line_num = line_num + 1;
    if line_num <= 2
        continue;           % skip the first two header lines
    end
    data_matrix(end+1,:) = sscanf(curr_line, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
end
fclose(fid);
end

