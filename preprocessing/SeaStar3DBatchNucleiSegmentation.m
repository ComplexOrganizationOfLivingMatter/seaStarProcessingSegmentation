%% Loop Images_3D

clc;
clearvars;
workspace;
imtool close all;
format long g;
format compact;

addpath('data')
addpath('lib')
addpath('src')

directory = dir('data/nucleiPath');
fromPath = strcat("data/nucleiPath");
savePath = strcat("data/segmentedNuclei");

for imageIx = 3:size(directory, 1)
    %path = directory(imageIx).folder;
    name = directory(imageIx).name;
    SeaStar3DNucleiSegmentation(fromPath, name, savePath, strcat('segmented_nuclei_', name), 0.5);
    disp('###')
    disp('DONE')    
    disp(imageIx)
    disp('###')

end
