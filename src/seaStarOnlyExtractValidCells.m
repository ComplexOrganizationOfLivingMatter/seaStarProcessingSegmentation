function [numberTotalCells,numberValidCells,validCells,labelledImage_realSize,z_Scale,pixel_Scale,originalImage] = seaStarOnlyExtractValidCells(originalImgPath,segmentedPath,imageName,segmentedImageName)
   

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

%     cellProps = regionprops3(segmentedImageResized, "Centroid");
%     [indexEmpty,~]=find(isnan(cellProps.Centroid));
%     cellProps(indexEmpty,:)=[];
    
    for zIndex=1:size(segmentedImageResized,3)
       if max(max(max(segmentedImageResized(:,:,zIndex))))>0 
           break
       end
    end
    
    %%resize Tissue
    [~,~,~,labelledImage_realSize]=resizeTissue(segmentedPath,outputName{1},segmentedImageResized,z_Scale,1);
    
    labelledImage_realSize=labelledImage_realSize+1;
    labelledImage_realSize(labelledImage_realSize==1)=0;
    
     %% Select z distance to select valid cells  
    zDistance=30; %30 microns
    zThreshold=(zDistance/pixel_Scale)+(zIndex*z_Scale); %Selecting zDistance from the first slice with cells
    cellProps = regionprops3(labelledImage_realSize, "Centroid");
    
    noValidCells=find(round(cellProps.Centroid(:,3))>zThreshold);
    
    [indexEmpty,~]=find(isnan(cellProps.Centroid(:,3)));
    noValidCells=unique([noValidCells; indexEmpty]);
    
    validCells=setdiff(1:max(max(max(labelledImage_realSize))),noValidCells);
    
    numberValidCells=length(validCells);
    totalCells=max(max(max(labelledImage_realSize)))-length(indexEmpty);
    numberTotalCells=length(totalCells);
    
%     [allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage_realSize,apicalLayer,basalLayer,lateralLayer,segmentedPath,outputName{1},pixel_Scale,contactThreshold,validCells,noValidCells);

    
%     segmentedImageResizedValidCells=segmentedImageResized;
    
%     for nCell=1:length(noValidCells)
%         labelledImage_realSize(labelledImage_realSize==noValidCells(nCell))=1;
%     end
    
%      for nCell=1:length(noValidCells)
%         segmentedImageResized(segmentedImageResized==noValidCells(nCell))=1;
%     end

% axisLengths=regionprops3(labelledImage_realSize>1,'PrincipalAxisLength');   


%     save(strcat(segmentedPath,'\',outputName{1},'.mat'),'z_Scale','pixel_Scale','sliceFactor','cellProps');
    
    
end

