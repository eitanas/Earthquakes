function [bool] = returnAllFilesWithLetter(pathToFiles, wantedLetter)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

files = dir(pathToFiles);
fn = length(files);
bool = zeros(1,fn);

for fi=3:fn
   
    file = files(fi);
    fname = file.name;
    str = strsplit(fname, '.');
    str_to_check = str{2};
    str_to_check = strsplit(str_to_check, '_');
    str_to_check = str_to_check{1};
    letter = str_to_check(3);
    
    if strcmp(letter, wantedLetter)
        bool(fi) = 1;
    end 
end

end

