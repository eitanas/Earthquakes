%%
clear; clc; close all
%cd '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/'
cd 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019'
LocData = load('accNet.mat');
LocData = LocData.data;
Lon = table2array( LocData(:, 2));
Lat = table2array( LocData(:, 3));

%
FS = 200;
WINDOW_LENGTH = 2;
OVERLAP_LENGTH = 0.5 * WINDOW_LENGTH;
SIGNAL_LENGTH = 20;
%pathToFiles =  '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/031/';
pathToFiles = 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019\015\';
files = dir(pathToFiles);
filesBool = returnAllFilesWithLetter(pathToFiles, 'Z');
files = files(logical(filesBool));
fn = length(files);
%choose a random file
fi = randi(fn);
file = files(fi);
fname1 = file.name; fname1 = strsplit(fname1, '.'); fname1 = fname1{1}
filedata = rdmseed([pathToFiles, file.name]);
s1 = cat(1, filedata.d)';
t = cat(1, filedata.t);
t = (t - t(1))*24*60;

[index, found] = find(LocData.StationName==fname1);
sum(found)
%
K = 4;
lon = LocData.Longtitude;
lat = LocData.Latitude;
if sum (found)==1
    stationName = LocData.Location{index}
    
    %idx = find(found)
    currLon = LocData.Longtitude(index);
    currLat = LocData.Latitude(index);
    %now we need to traverse all locatios and find thier distance from our
    %current loc
    
    [D, indcs] = pdist2( [lat lon],[currLat currLon], 'euclidean', 'Smallest', K) ;
    
    
    LocData.Location(indcs)
    
end
s1 = s1./sum(s1);
std_s1 = std(s1);
idx = find( ((s1 - mean(s1))/std_s1 > 2));
figure;
subplot(K,1,1)
plot(s1);  hold on;
scatter( idx,s1(idx))
title(stationName)
grid on;

axis tight;

for i=2:K
    subplot(K,1,i)
    file = files( indcs(i));
    file
    currfiledata = rdmseed([pathToFiles, file.name]);
    t = cat(1, currfiledata.t);
    t = (t - t(1))*24*60;
    s = cat(1, currfiledata.d)';
    s = s./sum(s);

    std_s = std(s);
    idx = find( ((s - mean(s))/std_s > 2));
    plot(s);  hold on;
    scatter(idx,s(idx),5)
    title(LocData.Location(indcs(i)))
    grid on;
    axis tight;
end

