function [l] = calculateNumOfWindowsWithHalfOverlap(signalLength, windowLength)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


start_idx = 1;
end_index =  start_idx + windowLength;
starting_windows_stor = [start_idx];
while (end_index + 0.5*windowLength) <signalLength
    
    end_index =  start_idx + windowLength;
    start_idx = start_idx + 0.5*windowLength;
    starting_windows_stor = [starting_windows_stor start_idx];
    
end

l = length(starting_windows_stor);