function [cells3dFeatures] = seaStarExtractCircularity(originalImgPath,segmentedPath,imageName,segmentedImageName)
   

    [segmentedImage] = readStackTif(strcat(segmentedPath,'\',segmentedImageName));
    
    [originalImage,imgInfo] = readStackTif(strcat(originalImgPath,'\',imageName));
    
%     fileName=strsplit(imageName,'_2');
%     fileName=strcat('2',fileName{2});
%     fileName=erase(fileName,'.tif');
    
    outputName=strsplit(segmentedImageName,'_itkws');
    segmentedPath=strcat(segmentedPath,'\',outputName{1});
    
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
    
       %chequear si el lúmen está cogido como 2 o  no cogido (básciametne quitar
    %las células que sean anormalmente grandes)
    labelsVolume = regionprops3(segmentedImage, 'Volume');
    
    uniqueLabels = unique(segmentedImage);
    invalidLabels = uniqueLabels(labelsVolume.Volume>1000000);
    
    for invalidLabelIx = 1:length(invalidLabels)
        invalidLabel = invalidLabels(invalidLabelIx);
        segmentedImage(segmentedImage==invalidLabel)=0;
    end
    
    segmentedImage=double(segmentedImage);
    segmentedImageResized= imresize3(segmentedImage, [size(originalImage,1),size(originalImage,2),size(originalImage,3)],'nearest');
    
    [segmentedImageResized] = relabelMulticutTiff(segmentedImageResized);
    
    cellProps = regionprops3(segmentedImageResized, "Centroid");
    [indexEmpty,~]=find(isnan(cellProps.Centroid));
    cellProps(indexEmpty,:)=[];
    
    for zIndex=1:size(segmentedImageResized,3)
       if max(max(max(segmentedImageResized(:,:,zIndex))))>0 
           break
       end
    end
    
    sliceFactor=round((142+(zIndex)*z_Scale)/z_Scale); %Selecting 142 microns from the first slice with cells because we selected that in the first movie 20200114_pos1 this space.
    noValidCells=find(round(cellProps.Centroid(:,3))>sliceFactor);
    validCells=setdiff(1:max(max(max(segmentedImageResized))),noValidCells);
    
    labelledSequenceOnlyValidCells(segmentedImageResized,segmentedPath,noValidCells);
    
    cells3dFeatures=[];
    
    for indexCell=1:size(validCells')
        actualImg = bwlabeln(segmentedImageResized==validCells(1,indexCell));
        actualImg2=actualImg(:,:,round(cellProps.Centroid(validCells(1,indexCell),3)));
        oneCell3dFeatures = regionprops(actualImg2, 'Circularity');
        cells3dFeatures = [cells3dFeatures; horzcat(oneCell3dFeatures)];
    end
    
    save(fullfile(segmentedPath, 'circularityCells.mat'),'cells3dFeatures')

end

