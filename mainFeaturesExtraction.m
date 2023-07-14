%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mainfeaturesExtraction
% Main code for extracting sea star cellular features
% from segmentations. Segmentations should be
% in .tif or .tiff format.
% Some paths must be changed by user --> inPath
% Both raw images and segmented images should be
% inside inPath directory. 2 Folders are needed.
% 
% EXAMPLE
% 
% fullPathTo\SeaStarSegmentations
%         > segmentedImages
%               >SegmentedImg1.tif
%               >SegmentedImg2.tif
%         > originalImages
%               >OriginalImg1.tif
%               >OriginalImg2.tif
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% add library paths
addpath(genpath('src'))
addpath(genpath('lib'))

% clear workspace
clear all
close all

% get path
inPath = uigetdir('E:\FullPathTo\SeaStarSegmentations');

% set directories
segmentedEmbryosFiles = dir(strcat(inPath,'/segmentedImages/*.tif*'));
originalEmbryosFiles = dir(strcat(inPath,'/originalImages/*.tif*'));

% Initialize variables
allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
allTissues = cell(size(segmentedEmbryosFiles,1),1);
allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);

% for each file in directory, extract all features and store the info
% in the afore-initialized variables
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

% summarize all properties
summarizeAllTissuesProperties(allGeneralInfo,allTissues,allMeanCellsFeatures,allStdCellsFeatures,inPath,[],1);


