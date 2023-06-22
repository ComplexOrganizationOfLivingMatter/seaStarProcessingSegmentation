function [numberTotalCells,validCells,numberValidCells]=filterValidRegion(labelledImage,pixel_Scale)
for zIndex=1:size(labelledImage,3)
    if max(max(max(labelledImage(:,:,zIndex))))>0
        break
    end
end
    
    %% Select z distance to select valid cells  
    zDistance=30; %30 microns
    zThreshold=(zDistance/pixel_Scale)+zIndex; %Selecting zDistance from the first slice with cells
    cellProps = regionprops3(labelledImage, "Centroid");
    
    noValidCells=find(round(cellProps.Centroid(:,3))>zThreshold);
    
    [indexEmpty,~]=find(isnan(cellProps.Centroid(:,3)));
    noValidCells=unique([noValidCells; indexEmpty]);
    
    validCells=setdiff(1:max(max(max(labelledImage))),noValidCells);
    
    numberValidCells=length(validCells);
    numberTotalCells=max(max(max(labelledImage)))-length(indexEmpty);
    
    
end