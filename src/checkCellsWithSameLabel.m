addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');

segmentedEmbryosFiles = dir(strcat(inPath,'/segmentedImages/*.tif*'));

for nFiles=1:length(segmentedEmbryosFiles)


    segmentPath = segmentedEmbryosFiles(nFiles).folder;
    segmentName=segmentedEmbryosFiles(nFiles).name;
    fileName=strsplit(segmentName,'_itkws');
 
    [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
    
for indexCell = 1:max(max(max(double(segmentedImage))))
    actualImg = bwlabeln(segmentedImage==indexCell);
    oneCell3dFeatures = regionprops3(actualImg, 'Volume');
    if size(oneCell3dFeatures, 1) > 1
        warning('In the file %s, the label %d correspond to two cells',fileName{1},indexCell);
    end
end
    
end



% % 
% for xIndex=1:size(x,1)
%    segmentedImage(x(xIndex,1),y(xIndex,1),z(xIndex,1))=214; 
% end
% % 
% for xIndex=1:size(x,1)
%    actualImage(x(xIndex,1),y(xIndex,1),:)=1; 
% end