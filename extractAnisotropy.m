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
colours=rand(500,3);
colours=vertcat([0.9 0.9 0.9],colours); 

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));

    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),2);
%     allGeneralInfo = cell(size(segmentedEmbryosFiles,1),3);
    allTissues = cell(size(segmentedEmbryosFiles,1),1);
    allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);

    layout = uint8(zeros([413*size(segmentedEmbryosFiles, 1),570*3, 3]));
    
    originalImagePath = originalEmbryosFiles.folder;
    segmentPath = segmentedEmbryosFiles.folder;
%     outPath=strcat(segmentPath,'\segmentedImageResized_',date,'\');
    
    for nFiles=1:length(segmentedEmbryosFiles)

        imageName=originalEmbryosFiles(nFiles).name;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'_itkws');

        if exist(fullfile(segmentPath, fileName{1})) ~=7
            fileName=strsplit(segmentName,'_itkws');
            mkdir(segmentPath, fileName{1})

        end
        [totalCells,numberValidCells,validCells,segmentedImageResized,z_Scale,pixel_Scale,axisLengths] = seaStarOnlyExtractValidCells(originalImagePath,segmentPath,imageName,segmentName);
        
       allGeneralInfo{nFiles,1} =  fileName{1};
%        allGeneralInfo{nFiles,2} = totalCells;
%        allGeneralInfo{nFiles,3} = numberValidCells;
%        disp(numberValidCells)
      allGeneralInfo{nFiles,2} = axisLengths.PrincipalAxisLength.*pixel_Scale;
       
%        segmentedImageResized=relabelMulticutTiff(segmentedImageResized);
%        segmentedImageResized=imresize3(segmentedImageResized,[size(segmentedImageResized,1)/4 size(segmentedImageResized,2)/4 size(segmentedImageResized,3)/4],'nearest');
       
               
       
    end
 
    embryoName=embryosFiles(nEmbryos).name;
    allGeneralInfo=cell2table(allGeneralInfo,'VariableNames',{'ID', 'axisLength'});
    writetable(allGeneralInfo,[inPath,strcat(embryoName,'validVolumeLength_',date,'.xls')],'Sheet', 'allGeneralInfo','Range','B2');

    
end

