function [allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures] = seaStarPostProcessing(originalImgPath,segmentedPath,imageName,segmentedImageName)
   

    [segmentedImage] = readStackTif(strcat(segmentedPath,'\',segmentedImageName));
    
    [originalImage,imgInfo] = readStackTif(strcat(originalImgPath,'\',imageName));
    
%     fileName=strsplit(imageName,'_2');
%     fileName=strcat('2',fileName{2});
%     fileName=erase(fileName,'.tif');
    
    outputName=strsplit(segmentedImageName,'_itkws');
    outputName=strsplit(outputName{1},'.tif');
    segmentedPath=strcat(segmentedPath,'\',outputName{1});
    
    if exist(strcat(segmentedPath,'\',outputName{1},'.mat'),'file')==0
        
        pixelWidth=1/unique([imgInfo.XResolution]);
        
        try
            extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
            extractingSpacing = extractingSpacing{2};
            extractingSpacing = strsplit(extractingSpacing, 'loop=');
            extractingSpacing = extractingSpacing{1};
            pixelDepth = str2num(extractingSpacing);
            
            z_Scale=pixelDepth/pixelWidth;
            pixel_Scale = pixelWidth;
            
            
            save(strcat(segmentedPath,'\',outputName{1},'.mat'),'z_Scale','pixel_Scale');
            
        catch
            disp('error')
            z_Scale=1;
            pixel_Scale=1;
            originalImage=imresize3(originalImage,[512 512 512],'nearest');
            segmentedImage=flip(segmentedImage,3);
        end
        
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

  
%     [segmentedImageResized] = relabelMulticutTiff(segmentedImageResized);
    

    cellProps = regionprops3(segmentedImageResized, "Centroid");

    
    for zIndex=1:size(segmentedImageResized,3)
       if max(max(max(segmentedImageResized(:,:,zIndex))))>0 
           break
       end
    end
    
    %% Select z distance to select valid cells
    
%     zDistance=142;
%     
    contactThreshold=0.5;
%     sliceFactor=round((zDistance+(zIndex)*z_Scale)/z_Scale); %Selecting zDistance from the first slice with cells because we selected that in the first movie 20200114_pos1 this space.
%     noValidCells=find(round(cellProps.Centroid(:,3))>sliceFactor);
%     
%     [indexEmpty,~]=find(isnan(cellProps.Centroid(:,3)));
%     noValidCells=unique([noValidCells; indexEmpty]);
%     
%     validCells=setdiff(1:max(max(max(segmentedImageResized))),noValidCells);
% 
if z_Scale>1 
    [basalLayer,apicalLayer,lateralLayer,labelledImage_realSize]=resizeTissue(segmentedPath,outputName{1},segmentedImageResized,z_Scale,1);
else
    labelledImage_realSize=segmentedImageResized;
end    

%     if exist(strcat(segmentedPath,'\','valid_cells.mat'),'file')==0
        zDistance=30; %30 microns
        zThreshold=(zDistance/pixel_Scale)+(zIndex*z_Scale); %Selecting zDistance from the first slice with cells
        cellProps = regionprops3(labelledImage_realSize, "Centroid");
        
        noValidCells=find(round(cellProps.Centroid(:,3))>zThreshold);
        
        [indexEmpty,~]=find(isnan(cellProps.Centroid(:,3)));
        noValidCells=unique([noValidCells; indexEmpty]);
        
        validCells=setdiff(1:max(max(max(labelledImage_realSize))),noValidCells);
        
%         save(fullfile(segmentedPath,'valid_cells.mat'),'validCells','noValidCells');
%     else
%         load(fullfile(segmentedPath,'valid_cells.mat'),'validCells','noValidCells');
%     end
if z_Scale>1  
    [allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage_realSize,apicalLayer,basalLayer,lateralLayer,segmentedPath,outputName{1},pixel_Scale,contactThreshold,validCells,noValidCells);
else
     [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(segmentedImageResized,segmentedPath);
     [scutoids_cells,validScutoids_cells,surfaceRatio3D]=calculateScutoidsAndSR(labelledImage,apicalLayer,basalLayer,lateralLayer,segmentedPath,outputName{1},2,5,validCells);
     allGeneralInfo = cell2table([{outputName{1}}, {surfaceRatio3D}, {length(validCells)},{max(max(max(labelledImage_realSize)))}],'VariableNames', {'ID_Glands', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total'});
     totalMeanCellsFeatures=cell2table([{mean(scutoids_cells)}, {mean(validScutoids_cells)}],'VariableNames', {'totalScutoids', 'validScutoids'});
    allTissues=[];
    totalStdCellsFeatures=[];
end
    
%     segmentedImageResizedValidCells=labelledImage_realSize;
%     
%     for nCell=1:length(noValidCells)
%         segmentedImageResizedValidCells(segmentedImageResizedValidCells==noValidCells(nCell))=0;
%     end
%     


 



    
    
end

