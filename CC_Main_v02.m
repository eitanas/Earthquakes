%% This is the main code that I use

% algorithm:
% get long - lat coords
% 1. find southest point
% 2 pdist euclidean to sort all the rest of the points accordingly.

% open webpage to find the date and time of an event
%url = 'http://seis.gii.co.il/heb/earthquake/searchEQS.php'
%web(url,  '-browser')

% TODO:
% adjust window lengths according to distance.
% Since we are looking now at the P waves, which travel at 8km/h on the
% earth surface, we must change the window size accordingly.
% change the windows - start from sec 15 - with 1/5 sec step, (25 sec.
% overlap)
% For each event find its' exact time of occurence using
%url = 'http://seis.gii.co.il/heb/earthquake/searchEQS.php'
%web(url,  '-browser')
% mark the windows of the occurence somehow, and the location
% another option, is to check the total PSD of all stations before during
% and after the event.

% 15:   '201901151558'	2019-01-15T15:59:55.221	3.8	0	3.5  	29.4669	34.973	16	Arava	        F
% 31:   '201901311142'	2019-01-31T11:43:19.783	2.5	0	2.6	    32.8461	35.5733	4	Hula-Kinneret	EQ
% 24:   '201901242003'	2019-01-24T20:04:58.660	3.3	0	3.3 	32.7738	35.3215	1	Galilee	        EQ
% 135:  '201905151652'	2019-05-15T16:53:49.587	0	0	4.5	    32.77	32.824	14	E.Mediter.Sea	F
% 177:  '201901311142'	2019-01-31T11:43:19.783	2.5	0	2.6	    32.8461	35.5733	4	Hula-Kinneret	EQ
% 180:  '201906290541'	2019-06-29T05:43:17.731	0	0	3.1	    31.9826	35.225	1	Judea-Samaria	F

clear; clc; close all

FS = 200;
WINDOW_LENGTH = FS * 30; % [in points]  -  30 seconds
OVERLAP_LENGTH = 1000;  % 200 for 1 second
SIGNAL_LENGTH = FS * 60 * 20; % [points]
MINFREQ = 0.1;
MAXFREQ = 10;
%cd '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/'
cd 'D:\Dropbox\PhD\Earthquakes\01_crossCorr_Main'
LocData = load('accNet.mat');
LocData = LocData.data;
AccLocDataNames = LocData.StationName;
AccLocDataNames = cellstr(AccLocDataNames);

Lon = table2array( LocData(:, 3));
Lat = table2array( LocData(:, 2));

events  = {'135',  '031', '177', '180', '024', '015' };
%pathToFiles =  '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/';
pathToFiles = 'D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019\';
modes = {'E', 'Z', 'N'};

for eventi = 1:length(events)
    currEvent = events{eventi};     currEvent
    currPathToFiles = [pathToFiles, currEvent, '\'];
        
    for mode_i =1:3
        
        mode = modes{mode_i};
        
        
        %pathToFiles =  '/Volumes/Eitan/Dropbox/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/031/';
        files = dir(currPathToFiles);
        filesBool = returnAllFilesWithLetter(currPathToFiles, mode);
        files = files(logical(filesBool));
        
        fn = length(files);
        % from files keep only the files which we have thier coordinates in "accNet"
        filesNamesCell = cell(1, fn);
        for fi=1:fn
            curr_file = files(fi);
            fname1 = curr_file.name; fname1 = strsplit(fname1, '.'); fname1 = fname1{1};
            filesNamesCell{fi} = fname1;
        end
        [files.shortName] = filesNamesCell{:}
        
        intersection = intersect(filesNamesCell, AccLocDataNames);
        
        boolean = zeros(1, fn);
        for fi=1:fn
            file = files(fi);
            fname = file.name;fname = strsplit(fname, '.');  fname = fname{1};
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
        
        % num_of_windows = calculateNumOfWindowsWithHalfOverlap(SIGNAL_LENGTH, WINDOW_LENGTH);
        
        %remove stations with different time than 240000
        [m, ~] = size(sortedFiles);
        zeroInds = [];
        for fi=1:m
            file = sortedFiles(fi);
            filedata = rdmseed([currPathToFiles, file.name]);
            t = cat(1, filedata.t);
            if ~(length(t)==240000)
                
                zeroInds = [zeroInds fi];
            end
        end
        sortedFiles(zeroInds, :) = [];
        
        ts=[];
        [numOfLoc, ~] = size(sortedFiles);
        
        for fi=1:numOfLoc
            file = sortedFiles(fi);
            filedata = rdmseed([currPathToFiles, file.name]);
            s1 = cat(1, filedata.d);
            data(:,fi) =  s1;
        end
        [numOfLoc, ~] = size(sortedFiles);
        % FFT and mean substraction
        for fi=1:numOfLoc
            s = data(:, fi);
            s = s - mean(s);
            fft_signal = ExtractSignalwave(MINFREQ, MAXFREQ, s , FS);
            data(:,fi) =  fft_signal;
        end
        
        start_idx = 1;
        start_t = 0;
        clrmap = redblue(256);
        max_t = 240000;
        startIdcs = buildStartIndicesWindowsTimeWithOverlapStartFromHalfWinSize(WINDOW_LENGTH, OVERLAP_LENGTH, start_t, max_t);
        startIdcs = startIdcs + 1;
        num_of_windows = length(startIdcs);
        for wi=1:num_of_windows-2
            disp([num2str(currEvent),' - working on window ',num2str(wi),'/',num2str(num_of_windows)])
            
            max_cor_vals = zeros(numOfLoc);
            min_cor_vals = zeros(numOfLoc);
            
            start_idx = startIdcs(wi);
            end_index = start_idx + WINDOW_LENGTH;
            
            for loc1=1:numOfLoc
                f1 = data(:,loc1);
                
                for loc2 = loc1:numOfLoc
                    
                    %disp(['win num = ',num2str(wi), ', f1 = ',num2str(loc1), ' f2 =  ',num2str(loc2)])
                    f2 = data(:,loc2);
                    
                    % get date
                    % t = cat(1, f1.t);
                    % t = (t - t(1))*24*60;
                    % t_greg = datestr(t);  t_greg(3,1:20)
                    
                    signal1 = f1(start_idx:end_index-1);
                    signal2 = f2(start_idx:end_index-1);
                    
                    maxlag = floor(length(signal1)/2);
                    [r, lags] = xcorr(signal2, signal1, maxlag, 'Coeff');
                    [w, tau, c] = calculateWeight(r, FS);
                    
                    max_cor_vals(loc1, loc2) = max(r);
                    min_cor_vals(loc1, loc2) = min(r);
                    
                end
            end
            max_cor_vals = tri_up_to_symmetric_square(max_cor_vals);
            min_cor_vals = tri_up_to_symmetric_square(min_cor_vals);
            
            %figure;
            %imagesc(currMat); colormap(clrmap)
            %colorbar
            dlmwrite(['D:\Dropbox\PhD\Earthquakes\01_crossCorr_Main\video files\', num2str(currEvent),'\',mode, '\MAX\',...
                num2str(currEvent), '_',mode, '_MAX_corrVals_window_',num2str(WINDOW_LENGTH), '_win_num_', num2str(wi),'.txt'], max_cor_vals);
            dlmwrite(['D:\Dropbox\PhD\Earthquakes\01_crossCorr_Main\video files\', ...
                num2str(currEvent),'\',mode,'\MIN\',num2str(currEvent),'_',mode,'_MIN_corrVals_window_',num2str(WINDOW_LENGTH), '_win_num_', num2str(wi),'.txt'], min_cor_vals);
            
            %start_idx = start_idx + 0.5 * WINDOW_LENGTH ;
        end
        
        
    end
    
end

