%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');

segmentedEmbryosFiles = dir(strcat(inPath,'/segmentedImages/*.tif*'));
originalEmbryosFiles = dir(strcat(inPath,'/originalImages/*.tif*'));

allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),2);

for nFiles=1:length(segmentedEmbryosFiles)

    originalImagePath = originalEmbryosFiles(nFiles).folder;
    segmentPath = segmentedEmbryosFiles(nFiles).folder;
    imageName=originalEmbryosFiles(nFiles).name;
    segmentName=segmentedEmbryosFiles(nFiles).name;
    fileName=strsplit(segmentName,'_itkws');
    
    if exist(fullfile(segmentPath, fileName{1})) ~=7
        fileName=strsplit(segmentName,'_itkws');
        mkdir(segmentPath, fileName{1})
         
    end
    [cells3dFeatures] = seaStarExtractCircularity(originalImagePath,segmentPath,imageName,segmentName);
    
    allMeanCellsFeatures{nFiles,1} = mean([cells3dFeatures.Circularity]);
    allMeanCellsFeatures{nFiles,2} = {originalEmbryosFiles(nFiles).name};
    
end
    
    writetable(cell2table(allMeanCellsFeatures), [inPath,'circularity_3dFeatures_' date '.xls'],'Sheet', 'meanCellParameters','Range','B2');


