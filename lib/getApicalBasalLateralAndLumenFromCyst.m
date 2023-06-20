function [apicalLayer,basalLayer,lateralLayer,lumenImage] = getApicalBasalLateralAndLumenFromCyst(labelledImage,path2saveLayers)
    basalLayer = zeros(size(labelledImage));
    apicalLayer = zeros(size(labelledImage));
    lateralLayer = zeros(size(labelledImage));
    
    cystFilled = imfill(labelledImage>0,'holes');
    perimCystFilled = bwperim(cystFilled);
    basalLayer(perimCystFilled) = labelledImage(perimCystFilled);
    
    apicalBasalLayer = bwperim(labelledImage>0);
    apicalLayer(apicalBasalLayer) = labelledImage(apicalBasalLayer);
    apicalLayer(perimCystFilled)=0;
    
    totalCells = unique(labelledImage(:))';
    totalCells(totalCells==0)=[];
    for nCell = totalCells
        perimLateralCell = bwperim(labelledImage==nCell);
        lateralLayer(perimLateralCell)=nCell;
    end
    
    lateralLayer(basalLayer>0 | apicalLayer>0) = 0; 
    
    lumenImage = labelledImage==0 & cystFilled;
    volumeLumen =regionprops3(bwlabeln(lumenImage),'Volume');
    if size(volumeLumen.Volume,1)>1
        [~,id] = max(volumeLumen.Volume);
        lumenImage = bwlabeln(lumenImage) == id;
    end
    
%     if ~isempty(path2saveLayers)
%         save(path2saveLayers, 'apicalLayer','basalLayer','lateralLayer','lumenImage','labelledImage','-v7.3')
%     end
end
