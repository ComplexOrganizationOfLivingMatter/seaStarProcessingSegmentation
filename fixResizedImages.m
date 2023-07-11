%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');

embryosFiles=dir(inPath);
dirEmbryos = [embryosFiles.isdir];
subDirs = embryosFiles(dirEmbryos); 
embryosFiles = subDirs(3:end);

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\segmentedImageResized*Apr*\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));
 for nFiles=1:length(segmentedEmbryosFiles)
    [segmentedImage] = readStackTif(strcat(segmentedEmbryosFiles(nFiles).folder,'\',segmentedEmbryosFiles(nFiles).name));
    
    [originalImage,imgInfo] = readStackTif(strcat(originalEmbryosFiles(nFiles).folder,'\',originalEmbryosFiles(nFiles).name));
    if size(originalImage,3)~= size(segmentedImage,3)
        segmentedImage=imresize3(segmentedImage,size(originalImage),'nearest');
        writeStackTif(uint16(segmentedImage),strcat(segmentedEmbryosFiles(nFiles).folder,'\',segmentedEmbryosFiles(nFiles).name))
    end
 end
end