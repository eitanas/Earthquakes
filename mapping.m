%%
%{

figure
geoshow('landareas.shp', 'FaceColor', [0.5 1.0 0.5]);
hold on
geoshow(Lon,Lat)
%}
data = accNet;
save ('accNet.mat', 'data')

%%
%cd '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/'
cd 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019'
data = load('accNet.mat');
data = data.data;
Lon = table2array( data(:, 2));
Lat = table2array( data(:, 3));


%%
FS = 200;
WINDOW_LENGTH = 2;
OVERLAP_LENGTH = 0.5 * WINDOW_LENGTH;
SIGNAL_LENGTH = 20;
MINFREQ = 0.1;
MAXFREQ = 10;


%pathToFiles =  '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/031/';
pathToFiles = 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019\015\';
files = dir(pathToFiles);
filesBool = returnAllFilesWithLetter(pathToFiles, 'Z');
files = files(logical(filesBool));
fn = length(files);
files(70:80).name
%choose a random file
%fi = randi(34);
fi = 103;
file = files(fi);
fname1 = file.name; fname1 = strsplit(fname1, '.'); fname1 = fname1{1}
filedata = rdmseed([pathToFiles, file.name]);
s1 = cat(1, filedata.d)';
t = cat(1, filedata.t);
t = (t - t(1))*24*60;

[index, found] = find(data.StationName==fname1)
sum(found)
%
K = 8;
if sum (found)==1
     lon = data.Longtitude;
    lat = data.Latitude;
  
    
    stationName = data.Location{index}
    
    idx = find(found)
    currLon = data.Longtitude(index);
    currLat = data.Latitude(index);
    %now we need to traverse all locatios and find thier distance from our
    %current loc
     [D, indcs] = pdist2( [lat lon], [currLat currLon], 'euclidean', 'Smallest', K+1) ;
    indcs = indcs(2:end);
    
    data.Location(indcs)
    
end

std_s1 = std(s1);
idx = find( ((s1 - mean(s1))/std_s1 > 2));
figure;
subplot(K+1,1,1)
s1 = ExtractSignalwave( MINFREQ, MAXFREQ, s1 , FS);

time = (convertGregorainToDate(t));
plot(,s1);  hold on;
scatter( idx, s1(idx))
title(stationName)
grid on;

axis tight;

for i=2:1+K
    subplot(K+1,1,i)
    file = files( indcs(i-1));
    file
    currfiledata = rdmseed([pathToFiles, file.name]);
    t = cat(1, currfiledata.t);
    t = convertGregorainToDate(t);
    %t = (t - t(1))*24*60;
    s = cat(1, currfiledata.d)';
    s = ExtractSignalwave( MINFREQ, MAXFREQ, s , FS);

    std_s = std(s);
    idx = find( ((s - mean(s))/std_s > 2));
    plot(s);  hold on;
    scatter(idx,s(idx))
    title(data.Location(indcs(i-1)))
    grid on;
    axis tight;
end
