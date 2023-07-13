function [allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures] = seaStarPostProcessing(originalImgPath,segmentedPath,imageName,segmentedImageName)

%% Open segmented and original files
[segmentedImage] = readStackTif(strcat(segmentedPath,'\',segmentedImageName));
[originalImage,imgInfo] = readStackTif(strcat(originalImgPath,'\',imageName));

outputName=strsplit(segmentedImageName,'_itkws');
outputName=strsplit(outputName{1},'.tif');
segmentedPath=strcat(segmentedPath,'\',outputName{1});

%%  Extract Z step and resolution from original file
if exist(strcat(segmentedPath,'\',outputName{1},'.mat'),'file')==0
    
    pixelWidth=1/unique([imgInfo.XResolution]);
    
    extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
    extractingSpacing = extractingSpacing{2};
    extractingSpacing = strsplit(extractingSpacing, 'loop=');
    extractingSpacing = extractingSpacing{1};
    pixelDepth = str2num(extractingSpacing);
    
    z_Scale=pixelDepth/pixelWidth;
    pixel_Scale = pixelWidth;
    
    
    save(strcat(segmentedPath,'\',outputName{1},'.mat'),'z_Scale','pixel_Scale');
    
else
    load(strcat(segmentedPath,'\',outputName{1},'.mat'),'z_Scale','pixel_Scale');
end


%% If lumen is labelled, delete from the cellular labels
labelsVolume = regionprops3(segmentedImage, 'Volume');

uniqueLabels = unique(segmentedImage);
invalidLabels = uniqueLabels(labelsVolume.Volume>1000000);

for invalidLabelIx = 1:length(invalidLabels)
    invalidLabel = invalidLabels(invalidLabelIx);
    segmentedImage(segmentedImage==invalidLabel)=0;
end

%% Resize segmented files and remove empty labels
segmentedImageResized= imresize3(double(segmentedImage), [size(originalImage,1),size(originalImage,2),size(originalImage,3)],'nearest');
[segmentedImageResized] = relabelStack(segmentedImageResized);

%% Get inner
[outerLayer,innerLayer,lateralLayer,labelledImage]=getApicalBasalLateralFromEmbryos(segmentedPath,outputName{1},segmentedImageResized,z_Scale,1);


%% Select valid regions and extract 3d features
[numberTotalCells,validCells,numberValidCells,noValidCells]=filterValidRegion(labelledImage,pixel_Scale);

[allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,outerLayer,innerLayer,lateralLayer,segmentedPath,outputName{1},pixel_Scale,validCells,noValidCells);

end

