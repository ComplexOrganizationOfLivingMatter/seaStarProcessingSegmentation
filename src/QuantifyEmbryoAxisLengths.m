addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');

segmentedEmbryosFiles = dir(strcat(inPath,'/segmentedImages/*.tif*'));
originalEmbryosFiles = dir(strcat(inPath,'/stacks/*.tif*'));

embryoLength=cell(size(segmentedEmbryosFiles,1),2);
for nFiles=1:length(segmentedEmbryosFiles)
    
    originalImagePath = originalEmbryosFiles(nFiles).folder;
    segmentPath = segmentedEmbryosFiles(nFiles).folder;
    imageName=originalEmbryosFiles(nFiles).name;
    segmentName=segmentedEmbryosFiles(nFiles).name;
    fileName=strsplit(segmentName,'_itkws');
    
    [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
    
    [originalImage,imgInfo] = readStackTif(strcat(originalImagePath,'\',imageName));
    
    %     fileName=strsplit(imageName,'_2');
    %     fileName=strcat('2',fileName{2});
    %     fileName=erase(fileName,'.tif');
    
    pixelWidth=1/unique([imgInfo.XResolution]);
    
    extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
    extractingSpacing = extractingSpacing{2};
    extractingSpacing = strsplit(extractingSpacing, 'loop=');
    extractingSpacing = extractingSpacing{1};
    pixelDepth = str2num(extractingSpacing);
    
    z_Scale=pixelDepth/pixelWidth;
    pixel_Scale = pixelWidth;
    
    segmentedImage=imresize3(segmentedImage,[size(originalImage,1) size(originalImage,2) size(originalImage,3)*z_Scale],'nearest');
    
    %         index=0;
    %     allAxis=[];
    %     for zIndex=1:size(segmentedImage,3)
    %         axisLengths=regionprops(segmentedImage(:,:,zIndex)>1,"MajorAxisLength","MinorAxisLength");
    %
    %         if isempty(axisLengths)==0
    %             index=index+1;
    %             allAxis(index,1)=zIndex;
    %             allAxis(index,2)=axisLengths.MajorAxisLength;
    %             allAxis(index,3)=axisLengths.MinorAxisLength;
    %         end
    %     end
    %
    %
    %     IndexSemiSphere=find(allAxis(:,2)==max(allAxis(:,2)));
    %
    %     segmentedImage=segmentedImage(:,:,1:max(IndexSemiSphere),1);
    %
    %     zDiameter=zRadius*2;
    %
    %     embryoAxisLength=[allAxis(max(IndexSemiSphere),2:3) zDiameter];
    

    axisLengths=regionprops3(segmentedImage>1,"PrincipalAxisLength");
    
    embryoAxisLength=[axisLengths.PrincipalAxisLength(1:2) axisLengths.PrincipalAxisLength(3)*2];
    
    embryoAxisLength= embryoAxisLength*pixel_Scale;
    
    
    % OuterCentroid=regionprops(segmentedImage(:,:,allAxis(1,1))>1,'Centroid');
    % InnerCentroid=regionprops(segmentedImage(:,:,allAxis(max(IndexSemiSphere),1))>1,'Centroid');
    %
    % centroid1=[OuterCentroid.Centroid allAxis(1,1)];
    % centroid2=[InnerCentroid.Centroid allAxis(max(IndexSemiSphere),1)];
    %
    % zRadius2=pdist2(centroid1,centroid2);
    
    embryoLength{nFiles,1} = fileName;
    embryoLength{nFiles,2} = embryoAxisLength;
    
end

writetable(embryoLength, [inPath,'global_embryosAxisLength_' date '.xls'],'Sheet', 'embryoLength','Range','B2'); 