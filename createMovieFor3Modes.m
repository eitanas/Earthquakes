%%

% 15:   '201901151558'	2019-01-15T15:59:55.221	3.8	0	3.5  	29.4669	34.973	16	Arava	        F
% 31:   '201901311142'	2019-01-31T11:43:19.783	2.5	0	2.6	    32.8461	35.5733	4	Hula-Kinneret	EQ
% 24:   '201901242003'	2019-01-24T20:04:58.660	3.3	0	3.3 	32.7738	35.3215	1	Galilee	        EQ
% 135:  '201905151652'	2019-05-15T16:53:49.587	0	0	4.5	    32.77	32.824	14	E.Mediter.Sea	F
% 177:  '201901311142'	2019-01-31T11:43:19.783	2.5	0	2.6	    32.8461	35.5733	4	Hula-Kinneret	EQ
% 180:  '201906290541'	2019-06-29T05:43:17.731	0	0	3.1	    31.9826	35.225	1	Judea-Samaria	F

clc
tic
modes = {'E', 'Z', 'N'};
events  = {'015', '031', '024', '135',  '177', '180',  };
locData = load('sortedFilesData.mat');locData = locData.sortedFiles;
Latitude = [locData.Latitude].';
Longitude = [locData.Longitude].';
times = {'15:59:55', '11:43:19','20:04:58','16:53:49', '11:43:19','05:43:17'}
strength = {3.5, 2.6, 3.3, 4.5, 2.6, 3.1 }
locations = {[29.4669	34.973], [32.8461 35.5733], [32.7738	35.3215], [32.77	32.824], [32.8461	35.57], [31.9826	35.225]} 
for ei=1:6
event = events{ei};
pathToFiles = ['D:\Dropbox\PhD\Earthquakes\Data\IttayKurzon\EventSubset\EventSubset\2019\',event,'\'];
%pathToFiles = '/Volumes/Eitan/Dropbox (BIU)/PhD/Earthquakes/Data/IttayKurzon/EventSubset/EventSubset/2019/177/';
files = dir(pathToFiles);
curr_file = files(5);
filedata = rdmseed([pathToFiles, curr_file.name]);
t = cat(1, filedata.t);
t_greg = datestr(t) ;

%
pathToFiles = ['D:\Dropbox\PhD\Earthquakes\01_crossCorr_Main\video files\',event,'\'];

mode = 'E';
currPathToFiles_E = [pathToFiles, mode, '\MAX\'];
files_E = dir(currPathToFiles_E);
files_E = natsortfiles({files_E.name})';
files_E = files_E(2:end);

mode = 'N';
currPathToFiles_N = [pathToFiles, mode, '\MAX\'];
files_N = dir(currPathToFiles_N);
files_N = natsortfiles({files_N.name})';
files_N = files_N(2:end);

mode = 'Z';
currPathToFiles_Z = [pathToFiles, mode, '\MAX\'];
files_Z = dir(currPathToFiles_Z);
files_Z = natsortfiles({files_Z.name})';
files_Z = files_Z(2:end);

figure;

v = VideoWriter([event,'_3_modes_EQnetwork.avi']);    v.FrameRate = 1;
open(v)
TOP10MEAN_E =[];
TOP10MEAN_N =[];
TOP10MEAN_Z =[];
BOTTOM10MEAN_E =[];
BOTTOM10MEAN_N =[];
BOTTOM10MEAN_Z =[];
MEAN_E =[];
MEAN_N =[];
MEAN_Z =[];
LARGEST_EV1_E = [];
LARGEST_EV2_E = [];
LARGEST_EV1_Z = [];
LARGEST_EV2_Z = [];
LARGEST_EV1_N = [];
LARGEST_EV2_N = [];
clrmap = 'jet'
idx = 1;

eventloc = locations{ei};   
    [D, indcs] = pdist2( [Latitude Longitude], eventloc, 'euclidean', 'Smallest', 1);%, 'euclidean', 'Smallest') ;
    closestStationLon = locData(indcs).Longitude;
    closestStationLat = locData(indcs).Latitude;
    
for fi=3:length(files_Z)
    % 'Z'
    file = files_Z{fi};
    a  = load([currPathToFiles_Z,file]);
    subplot(6,2,[1,3]); hold on;
    A = imagesc(a);
    axis equal tight
    colormap(clrmap);
    caxis([0 1])
    colorbar; title('Z')
    cood = indcs;
    %rectangle('Position',pos) creates a rectangle in 2-D coordinates.
    %Specify pos as a four-element vector of the form [x y w h] in data units. 
    %The x and y elements determine the location and the w and h elements determine the size
    if cood<=6
        cood=6;
    end
    rectangle('Position',[cood-6 cood-6 12 12],'Curvature', 0.2, 'EdgeColor','k',...
    'LineWidth',2, 'LineStyle', '-')

    [m,n] = size(a);
    
    ev = eig(a);
    sorted_ev = sort(ev, 'descend');
    curr_largest1  = sorted_ev(1);
    curr_largest2  = sorted_ev(2);
    LARGEST_EV1_Z = [LARGEST_EV1_Z curr_largest1];
    LARGEST_EV2_Z = [LARGEST_EV2_Z curr_largest2];

    a = triu(a);
    for i=1:m
        a(i,i) = 0;
    end
    mean_a = nanmean(a(:));
    MEAN_Z = [MEAN_Z mean_a];
    sorted = sort(a(:), 'descend'); sorted(isnan(sorted)) = [];
    top10 = sorted(1:10); top10mean = mean(top10);
    TOP10MEAN_Z = [TOP10MEAN_Z top10mean];
    greaterThanZero = find(sorted,10, 'last');
    bottom10 = sorted(greaterThanZero);  bottom10mean = nanmean(bottom10);
    BOTTOM10MEAN_Z = [BOTTOM10MEAN_Z     bottom10mean];
    
    t = 1:1:length(TOP10MEAN_Z);
    t = t*5/60;
    subplot(6,2,2);hold on

    plot(t,TOP10MEAN_Z)
    xlabel('Time[Min.]'); ylabel('Top 10 values mean')
   % plot(t, MEAN_Z)   
    subplot(6,2,4);hold on
    plot(t, LARGEST_EV1_Z)   
    plot(t, LARGEST_EV2_Z)   
    ylabel('2 largest e.v.')
    xlabel('Time[Min.]');
    
    file = files_N{fi};
    a  = load([currPathToFiles_N, file]);
    subplot(6,2,[5,7]); hold on;
    A = imagesc(a);
    axis equal tight
    colormap(clrmap);
    caxis([0 1])
    colorbar;title('N')
    %rectangle('Position',pos) creates a rectangle in 2-D coordinates.
    %Specify pos as a four-element vector of the form [x y w h] in data units. 
    %The x and y elements determine the location and the w and h elements determine the size
      rectangle('Position',[cood-6 cood-6 12 12],'Curvature', 0.2, 'EdgeColor','k',...
    'LineWidth',2, 'LineStyle', '-')

    
    [m,n] = size(a);
    ev = eig(a);
    sorted_ev = sort(ev, 'descend');
    curr_largest1  = sorted_ev(1);
    curr_largest2  = sorted_ev(2);
    LARGEST_EV1_N = [LARGEST_EV1_N curr_largest1];
    LARGEST_EV2_N = [LARGEST_EV2_N curr_largest2];
    
    a = triu(a);
    for i=1:m
        a(i,i) = 0;
    end
    mean_a = nanmean(a(:));
    MEAN_N = [MEAN_N mean_a];
    sorted = sort(a(:), 'descend'); sorted(isnan(sorted)) = [];
    top10 = sorted(1:10); top10mean = mean(top10);
    TOP10MEAN_N = [TOP10MEAN_N top10mean];
    greaterThanZero = find(sorted,10, 'last')
    bottom10 = sorted(greaterThanZero);  bottom10mean = nanmean(bottom10);
    BOTTOM10MEAN_N = [BOTTOM10MEAN_N     bottom10mean];
    
    t = 1:1:length(TOP10MEAN_N);
    t = t*5/60;
    subplot(6,2,6);hold on;
    plot(t,TOP10MEAN_N)
    xlabel('Time[Min.]'); ylabel('Top 10 values mean')
    %plot(t,MEAN_N)
    subplot(6,2,8);hold on;
%   plot(t,BOTTOM10MEAN_N)
    plot(t,LARGEST_EV1_N)   
    plot(t,LARGEST_EV2_N)   
    ylabel('2 largest e.v.')
    xlabel('Time[Min.]');
    file = files_E{fi};
    a  = load([currPathToFiles_E,file]);
    subplot(6, 2, [9,11]);  hold on;
    A = imagesc(a);
    axis equal tight
    colormap(clrmap);
    caxis([0 1])
    colorbar;title('E')
    %rectangle('Position',pos) creates a rectangle in 2-D coordinates.
    %Specify pos as a four-element vector of the form [x y w h] in data units. 
    %The x and y elements determine the location and the w and h elements determine the size
      rectangle('Position',[cood-6 cood-6 12 12],'Curvature', 0.2, 'EdgeColor','k',...
    'LineWidth',2, 'LineStyle', '-')

    
    [m,n] = size(a);
     ev = eig(a);
    sorted_ev = sort(ev, 'descend');
    curr_largest1  = sorted_ev(1);
    curr_largest2  = sorted_ev(2);
    LARGEST_EV1_E = [LARGEST_EV1_E curr_largest1];
    LARGEST_EV2_E = [LARGEST_EV2_E curr_largest2];
    a = triu(a);
    for i=1:m
        a(i,i) = 0;
    end
    mean_a = nanmean(a(:));
    MEAN_E = [MEAN_E mean_a];
    
    sorted = sort(a(:), 'descend'); sorted(isnan(sorted)) = [];
    top10 = sorted(1:10); top10mean = mean(top10);
    TOP10MEAN_E = [TOP10MEAN_E top10mean];
    greaterThanZero = find(sorted,10, 'last')
    bottom10 = sorted(greaterThanZero);  bottom10mean = nanmean(bottom10);
    BOTTOM10MEAN_E = [BOTTOM10MEAN_E     bottom10mean];
    
    t = 1:1:length(TOP10MEAN_E);
    t = t*5/60;
    subplot(6,2,10);
    plot(t,TOP10MEAN_E)
    xlabel('Time[Min.]'); ylabel('Top 10 values mean')
   % plot(t,MEAN_E)
    subplot(6,2,12); hold on;
    plot(t,LARGEST_EV1_E)   
    plot(t,LARGEST_EV2_E)  
    ylabel('2 largest e.v.')
    xlabel('Time[Min.]');
    
    strdate = t_greg(idx, 1:end);
    
    suptitle(['Event ',event,', Power = ',num2str(strength{ei}),', ',  strdate, ', Event time = ',times{ei} ])
    set(gcf, 'position', [100 100 1200 1200])
    
    h = getframe(gcf);
    writeVideo(v,h )
    idx = idx + 1000;
    
    
end

close(v)
close all
end

toc
%% find largest eigenvals

ev = eig(d);
sorted_ev = sort(ev, 'descend');
largest (1, di) = sorted_ev(1);
largest (2, di) = sorted_ev(2);




