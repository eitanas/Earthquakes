
FS = 200;
WINDOW_LENGTH = FS * 30; % [in points]  -  30 seconds
OVERLAP_LENGTH = 1000;  % 200 for 1 second
SIGNAL_LENGTH = FS * 60 * 20; % [points]
MINFREQ = 0.1;
MAXFREQ = 10;
%cd '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/'
cd 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019'
LocData = load('accNet.mat');
LocData = LocData.data;
AccLocDataNames = LocData.StationName;
AccLocDataNames = cellstr(AccLocDataNames);

Lon = table2array( LocData(:, 3));
Lat = table2array( LocData(:, 2));

events  = {'015', '031', '177', '180', '024', '135'};
%pathToFiles =  '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/';
pathToFiles = 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019\';
eventi = 1;
files = dir(currPathToFiles);
filesBool = returnAllFilesWithLetter(currPathToFiles, 'Z');
files = files(logical(filesBool));

fn = length(files);
% from files keep only the files which we have thier coordinates in "accNet"
filesNamesCell = cell(1, fn);
for fi=1:fn
    curr_file = files(fi);
    fname1 = curr_file.name; fname1 = strsplit(fname1, '.'); fname1 = fname1{1};
    filesNamesCell{fi} = fname1;
end

% [A.(newstruct)] = values_cell{:};
[files.shortName] = filesNamesCell{:}

intersection = intersect(filesNamesCell, AccLocDataNames);

boolean = zeros(1, fn);
for fi=1:fn
    file = files(fi);
    fname = file.name;fname = strsplit(fname, '.'); fname = fname{1};
    if ismember(fname, intersection)
        boolean(fi) = 1;
    end
end

files = files(logical(boolean));
%
% remove duplicates
shortName = {files.shortName}.';
[u,i] = unique(shortName);
files = files(i);
% LocData: col 2 =
% next we want to find for each file it's coordinates from accNet
Lon = [];
Lat = [];

for fi=1:length(files)
    file = files(fi);
    fname = file.name;fname = strsplit(fname, '.'); fname = fname{1};
    
    idx = find(LocData.StationName==fname);
    currLat = LocData.Latitude(idx); currLat = currLat(1);
    currLong = LocData.Longtitude(idx);  currLong = currLong(1);
    
    Lon = [Lon currLong];
    Lat = [Lat currLat];
end

C = num2cell(Lon);
[files.Longitude] = C{:};

C = num2cell(Lat);
[files.Latitude] = C{:};

c = {files.Latitude};
c = cell2mat(c);
[v,i]=min(c);
shoutest = files(i);

southest_lat = shoutest.Latitude;
southest_lon = shoutest.Longitude;
% sort by distance
Latitude = [files.Latitude].';
Longitude = [files.Longitude].';
[D, indcs] = pdist2( [Latitude Longitude], [southest_lat southest_lon], 'euclidean', 'Smallest',86);%, 'euclidean', 'Smallest') ;

sortedFiles = files(indcs);

% now we can caculate the correaltions matrix

%num_of_windows = calculateNumOfWindowsWithHalfOverlap(SIGNAL_LENGTH, WINDOW_LENGTH);
[numOfLoc, ~] = size(sortedFiles);

%, num_of_windows);

ws =[];
taus =[];
lengths = [];
tic
start_idx = 1;
start_t = 0;
clrmap = redblue(256);
%TODO - parfor loop on windows
max_t = 240000;
startIdcs = buildStartIndicesWindowsTimeWithOverlapStartFromHalfWinSize(WINDOW_LENGTH, OVERLAP_LENGTH, start_t, max_t);
startIdcs = startIdcs + 1;
num_of_windows = length(startIdcs);
wi=1;
start_idx = startIdcs(wi);
end_index = start_idx + WINDOW_LENGTH;
loc1=1;
file1 = sortedFiles(loc1);

loc2 = loc1
file2 = sortedFiles(loc2);
f1 = rdmseed([currPathToFiles, file1.name]);
f2 = rdmseed([currPathToFiles, file2.name]);

lon1 = files(loc1).Longitude;  lat1 = files(loc1).Latitude;
lon2 = files(loc2).Longitude;  lat2 = files(loc2).Latitude;
latlon1 = [lat1 lon1];
latlon2 = [lat2 lon2];
%calculate distance in km from longitude-latitude:
[d1km d2km] = lldistkm(latlon1,latlon2);

timeOfArrivalSeconds = d1km/ 8;
%get date
t = cat(1, f1.t);
% t = (t - t(1))*24*60;
t_greg = datestr(t);  t_greg(3,1:20)
s1 = cat(1, f1.d)'; s2 = cat(1, f2.d)';
l1 = length(s1); l2 = length(s2);
s1 = s1-mean(s1);   s2 = s2-mean(s2);
signal1 = s1(start_idx:end_index-1);
signal2 = s2(start_idx:end_index-1);

% FFT to remove high freqs
signal1 = ExtractSignalwave(MINFREQ, MAXFREQ, signal1 , FS);
signal2 = ExtractSignalwave(MINFREQ, MAXFREQ, signal2 , FS);

maxlag = floor(length(signal1)/2);
[r, lags] = xcorr(signal2, signal1, maxlag, 'Coeff');
