function [volume,validCells] = seaStarExtractDensity(originalImgPath,segmentedPath,imageName,segmentedImageName)
   

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
    
    segmentedImageResized=segmentedImageResized+1;
    segmentedImageResized(segmentedImageResized==1)=0;

    cellProps = regionprops3(segmentedImageResized, "Centroid");
    embryoCentroid = regionprops3(segmentedImageResized>0, "Centroid");
%     [indexEmpty,~]=find(isnan(cellProps.Centroid));
%     cellProps(indexEmpty,:)=[];
    
    for zIndex=1:size(segmentedImageResized,3)
       if max(max(max(segmentedImageResized(:,:,zIndex))))>0 
           break
       end
    end
    
  %% Select z distance to select valid cells
    zDistance=142; %distancia en pixeles
%     zDistance=150;
    xDistance=50; %distancia en micras
    

    sliceFactor=round((zDistance+(zIndex)*z_Scale)/z_Scale); %Selecting zDistance from the first slice with cells because we selected that in the first movie 20200114_pos1 this space.

    XYFactor=xDistance/pixel_Scale;
    
    validCells=find( round(cellProps.Centroid(:,3))<=sliceFactor & cellProps.Centroid(:,1) > (embryoCentroid.Centroid(1)-XYFactor) & cellProps.Centroid(:,1) <(embryoCentroid.Centroid(1)+XYFactor) & cellProps.Centroid(:,2)> (embryoCentroid.Centroid(2)-XYFactor) & cellProps.Centroid(:,2)<(embryoCentroid.Centroid(2)+XYFactor));
    
    
%     [indexEmpty,~]=find(isnan(cellProps.Centroid(:,3)));
%     noValidCells=unique([noValidCells; indexEmpty]);
    
    noValidCells=setdiff(1:max(max(max(segmentedImageResized))),validCells);
    
%     distXPixels= max(cellProps.Centroid(validCells(:),1)) - min(cellProps.Centroid(validCells(:),1));
%     distXmicrons=distXPixels*pixel_Scale;
%     
%     distYPixels= max(cellProps.Centroid(validCells(:),2)) - min(cellProps.Centroid(validCells(:),2));
%     distYmicrons=distYPixels*pixel_Scale;
%     
%     if distXmicrons > 200 || distYmicrons > 200
%         disp(imageName);
%     end
%     
    for nCell=1:length(noValidCells)
        segmentedImageResized(segmentedImageResized==noValidCells(nCell))=0;
    end

   [basalLayer,apicalLayer,lateralLayer,labelledImage_realSize]=resizeTissueRegion(segmentedPath,outputName{1},segmentedImageResized);
    
    volumeRegion=regionprops3(labelledImage_realSize>0,'Volume');


%     numberValidCells=length(validCells);
%     totalCells=max(max(max(segmentedImageResized)))-length(indexEmpty);
%     [basalLayer,apicalLayer,lateralLayer,labelledImage_realSize]=resizeTissue(segmentedPath,outputName{1},segmentedImageResized);
%     
%     contactThreshold = 0.5;
% 
%     [allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage_realSize,apicalLayer,basalLayer,lateralLayer,segmentedPath,outputName{1},pixel_Scale,contactThreshold,validCells,noValidCells);

    
%     segmentedImageResizedValidCells=segmentedImageResized;



%     for nCell=1:length(noValidCells)
%         segmentedImageResized(segmentedImageResized==noValidCells(nCell))=1;
%     end
  
%         [holeArea,holeProjection] = extractEmbryoArea(segmentedImageResized);
    
%         load(strcat(segmentedPath,'\morphological3dFeatures.mat'))
%         find(CellularFeaturesAllCells)
%         apicalArea=sum(cellularFeaturesValidCells.Apical_area);
%         BasalArea=sum(cellularFeaturesValidCells.Basal_area);
%         volume=sum(cellularFeaturesValidCells.Volume);
        apicalArea=apicalArea*(pixel_Scale^2);
        BasalArea=BasalArea*(pixel_Scale^2);
        holeArea=holeArea*(pixel_Scale^2);
        volume=volumeRegion.Volume *(pixel_Scale^3);
end

