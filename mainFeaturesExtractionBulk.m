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
%     segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
%     originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\512\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\',embryosFiles(nEmbryos).name,'.mat'));
    
    
    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    allTissues = cell(size(segmentedEmbryosFiles,1),1);
    allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    load(fullfile(originalEmbryosFiles.folder,originalEmbryosFiles.name)); 
    for nFiles=1:length(segmentedEmbryosFiles)
        
        originalImagePath = originalEmbryosFiles(nFiles).folder;
        segmentPath = segmentedEmbryosFiles(nFiles).folder;
        imageName=originalEmbryosFiles(nFiles).name;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'_itkws');
        
%         if exist(fullfile(segmentPath, fileName{1})) ~=7
%             fileName=strsplit(segmentName,'_itkws');
%             mkdir(segmentPath, fileName{1})
%             
%         end
%         [generalInfo,tissue3dFeatures,meanCellsFeatures,stdCellsFeatures] = seaStarPostProcessing(originalImagePath,segmentPath,imageName,segmentName);
        [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
        segmentedImage=imresize3(segmentedImage,[size(segmentedImage,1:2) (size(segmentedImage,3)-1)],'nearest');
        segmentedImage(segmentedImage==1)=0;
        segmentedImage=double(segmentedImage);
        [basalLayer,apicalLayer,lateralLayer,labelledImage_realSize]=resizeTissue(segmentPath,segmentName,segmentedImage,z_Scale); 
        
        contactThreshold=0.5;
        validCells=unique(labelledImage);
        noValidCells=[];
        
        [allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage_realSize,apicalLayer,basalLayer,lateralLayer,segmentPath,segmentName,pixel_Scale,contactThreshold,validCells,noValidCells);

        allGeneralInfo{nFiles} = generalInfo;
        allTissues{nFiles} = tissue3dFeatures;
        allMeanCellsFeatures{nFiles} = meanCellsFeatures;
        allStdCellsFeatures{nFiles} = stdCellsFeatures;
        
    end
    
    summarizeAllTissuesProperties(allGeneralInfo,allTissues,allMeanCellsFeatures,allStdCellsFeatures,inPath,[],1);
    
end
