%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');


segmentedEmbryosFiles = dir(strcat(inPath,'/segmentedImages/*.tif*'));
originalEmbryosFiles = dir(strcat(inPath,'/originalImages/*.tif*'));

allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
allGeneralInfo = cell(size(segmentedEmbryosFiles,1),3);
allTissues = cell(size(segmentedEmbryosFiles,1),1);
allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);

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
    [totalCells,validCells] = seaStarOnlyExtractValidCells(originalImagePath,segmentPath,imageName,segmentName);
    
   allGeneralInfo{nFiles,1} =  fileName{1};
   allGeneralInfo{nFiles,2} = totalCells;
   allGeneralInfo{nFiles,3} = validCells;
    
end

% embryoName=strsplit(string(inPath),'\');
allGeneralInfo=cell2table(allGeneralInfo,'VariableNames',{'ID', 'totalCells','validCells'});
writetable(allGeneralInfo,[inPath,'global_validCells_' date '.xls'],'Sheet', 'allGeneralInfo','Range','B2');

