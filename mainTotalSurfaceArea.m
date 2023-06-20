%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\128\20200114_pos1');

embryosFiles=dir(inPath);
dirEmbryos = [embryosFiles.isdir];
subDirs = embryosFiles(dirEmbryos); 
embryosFiles = subDirs(3:end);


for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));

%     allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),2);
    allTissues = cell(size(segmentedEmbryosFiles,1),1);
    allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    
    originalImagePath = originalEmbryosFiles.folder;
    segmentPath = segmentedEmbryosFiles.folder;
    
    for nFiles=1:length(segmentedEmbryosFiles)

        imageName=originalEmbryosFiles(nFiles).name;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'_itkws');

        if exist(fullfile(segmentPath, fileName{1})) ~=7
            fileName=strsplit(segmentName,'_itkws');
            mkdir(segmentPath, fileName{1})

        end
        [totalCells,numberValidCells,validCells,segmentedImageResized,z_Scale,pixel_Scale] = seaStarOnlyExtractValidCells(originalImagePath,segmentPath,imageName,segmentName);
        

%        allGeneralInfo{nFiles,3} = numberValidCells;
%        disp(numberValidCells)
       
       totalSurfaceArea=regionprops3(segmentedImageResized>1,'SurfaceArea');
       
       allGeneralInfo{nFiles,1} =  fileName{1};
       allGeneralInfo{nFiles,2} = totalSurfaceArea.SurfaceArea*(pixel_Scale^2);
       
     
       
    end
    
%     imwrite(layout, strcat(outPath, '/', embryosFiles(nEmbryos).name, '.bmp'),'bmp');
%     save(strcat(outPath, '/', embryosFiles(nEmbryos).name,'.mat'), 'layout');
    
allGeneralInfo=cell2table(allGeneralInfo,'VariableNames',{'ID', 'surfaceArea'});
writetable(allGeneralInfo,[inPath,'_',embryosFiles(nEmbryos).name,'global_surfaceArea_' date '.xls'],'Sheet', 'allGeneralInfo','Range','B2');
 
    
    
end
% embryoName=strsplit(string(inPath),'\');

