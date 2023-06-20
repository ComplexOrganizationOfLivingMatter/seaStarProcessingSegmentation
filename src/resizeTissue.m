function [basalLayer,apicalLayer,lateralLayer,labelledImage_realSize]=resizeTissue(segmentedPath,fileName,correctLabelledImage,z_Scale)

if exist(fullfile(segmentedPath,strcat(fileName,'.mat')), 'file') == 0
    
    %% Step 1: Creating image with its real size
%     load(strcat(segmentedPath,'/',fileName,'.mat'),'z_Scale');
    
    labelledImage_realSize  = imresize3(correctLabelledImage, [size(correctLabelledImage,1) size(correctLabelledImage,2) z_Scale*size(correctLabelledImage,3)], 'nearest');
    lateralLayer = zeros(size(labelledImage_realSize));
    
    %binarize
    binaryLabels = (labelledImage_realSize>0);
    
    %Voy hacer un troncho de valor 1 para 'rellenar' la parte superior del
    %paraboloide o semiesfera
    
    binaryChunk = binaryLabels;
    
    %rellenar todos los Z superiores a cada punto con información
    for x=1:size(binaryLabels, 1)
        for y=1:size(binaryLabels, 2)
            if sum(binaryLabels(x,y,:))>0
                zpos = find(binaryLabels(x, y, :), 1, 'last');
                binaryChunk(x, y, zpos:end) = 1;
            end
        end
    end
    
    binaryChunk = imfill(binaryChunk, 'holes');
    apicalChunk = binaryChunk - binaryLabels;
    
    % dilato
    se = strel('sphere',2);
    dilatedApicalChunk = imdilate(apicalChunk, se);
    
    % comparo con labels
    apicalLayer = dilatedApicalChunk.*binaryLabels;
    
    % basal: hacer inversa y volver a hacer lo mismo
    %inversa
    inverseBinaryChunk = ones(size(binaryChunk))-binaryChunk;
    
    % dilato
    se = strel('sphere',2);
    dilatedInverseBinaryChunk = imdilate(inverseBinaryChunk, se);
    basalLayer = dilatedInverseBinaryChunk.*binaryLabels;
    
    apicalLayer = apicalLayer.*labelledImage_realSize;
    basalLayer = basalLayer.*labelledImage_realSize;
    
    totalCells = unique(labelledImage_realSize)';
    for nCell = totalCells
        perimLateralCell = bwperim(labelledImage_realSize==nCell);
        lateralLayer(perimLateralCell)=nCell;
    end
    
    lateralLayer(basalLayer>0 | apicalLayer>0) = 0;
    
    save(fullfile(segmentedPath,strcat(fileName,'.mat')), 'labelledImage_realSize','apicalLayer','basalLayer','lateralLayer', '-v7.3');
    
else
    load(fullfile(segmentedPath,strcat(fileName,'.mat')))
end

end