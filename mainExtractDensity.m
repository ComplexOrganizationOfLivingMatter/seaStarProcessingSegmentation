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
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));
    
    %     allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    %     allGeneralInfo = cell(size(segmentedEmbryosFiles,1),3);
    %     allTissues = cell(size(segmentedEmbryosFiles,1),1);
    %     allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),3);
    %     allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    
    layout = uint8(zeros([413*size(segmentedEmbryosFiles, 1),570*3, 3]));
    
    originalImagePath = originalEmbryosFiles.folder;
    segmentPath = segmentedEmbryosFiles.folder;
    
    allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),4);
    
    if exist(fullfile(segmentPath,strcat('segmentedImageHole_',date))) ~=7
        mkdir(segmentPath,strcat('segmentedImageHole_',date));
    end
    outPath=strcat(segmentPath,'\segmentedImageHole_',date,'\');
    
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
        
        [volume,basalArea,apicalArea,holeArea,holeProjection,validCells] = seaStarExtractDensity(originalImagePath,segmentPath,imageName,segmentName);
           
        writeStackTif(uint16(holeProjection),fullfile(outPath,strcat(fileName{1},'.tiff')))
         
        allMeanCellsFeatures{nFiles,1} = apicalArea;
        allMeanCellsFeatures{nFiles,2} = basalArea;
        allMeanCellsFeatures{nFiles,3} = holeArea;
        allMeanCellsFeatures{nFiles,4} = volume;
        allMeanCellsFeatures{nFiles,5} = {originalEmbryosFiles(nFiles).name};
    end
    
    writetable(cell2table(allMeanCellsFeatures),[strcat(embryosFiles(nEmbryos).folder,'\'),embryosFiles(nEmbryos).name,'_','regionsArea_3dFeatures_' date '.xls'],'Sheet', 'meanCellParameters','Range','B2');
    
end
