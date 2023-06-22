%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');

segmentedEmbryosFiles = dir(strcat(inPath,'/segmentedImages/*.tif*'));
originalEmbryosFiles = dir(strcat(inPath,'/originalImages/*.tif*'));

allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
allTissues = cell(size(segmentedEmbryosFiles,1),1);
allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);

for nFiles=1:length(segmentedEmbryosFiles)

    originalImagePath = originalEmbryosFiles(nFiles).folder;
    segmentPath = segmentedEmbryosFiles(nFiles).folder;
    imageName=originalEmbryosFiles(nFiles).name;
    segmentName=segmentedEmbryosFiles(nFiles).name;
    fileName=strsplit(segmentName,'_itkws');
    fileName=strsplit(fileName{1},'.tif');
    if exist(fullfile(segmentPath, fileName{1})) ~=7
        mkdir(segmentPath, fileName{1})
    end
    
%     try
    [generalInfo,tissue3dFeatures,meanCellsFeatures,stdCellsFeatures] = seaStarPostProcessing(originalImagePath,segmentPath,imageName,segmentName);
    
    allGeneralInfo{nFiles} = generalInfo;
    allTissues{nFiles} = tissue3dFeatures;
    allMeanCellsFeatures{nFiles} = meanCellsFeatures;
    allStdCellsFeatures{nFiles} = stdCellsFeatures;
%     catch
%         disp(strcat('error in file nº', num2str(nFiles)))
%         continue
%     end
    
end

summarizeAllTissuesProperties(allGeneralInfo,allTissues,allMeanCellsFeatures,allStdCellsFeatures,inPath,[],1);


