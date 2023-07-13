function [outerLayer,innerLayer,lateralLayer,labelledImage_realSize]=getApicalBasalLateralFromEmbryos(segmentedPath,fileName,correctLabelledImage,z_Scale,saveRequest)

if exist(fullfile(segmentedPath,strcat(fileName,'.mat')), 'file') == 0
    
    %% Step 1: Resize image stacks
    labelledImage_realSize  = imresize3(correctLabelledImage, [size(correctLabelledImage,1) size(correctLabelledImage,2) z_Scale*size(correctLabelledImage,3)], 'nearest');
    lateralLayer = zeros(size(labelledImage_realSize));
    
    %% Step 2: Get Apical and Basal Layers
    binaryLabels = (labelledImage_realSize>0);
    binaryChunk = binaryLabels;
    %Voy hacer un troncho de valor 1 para 'rellenar' la parte superior del
    %paraboloide o semiesfera
    
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
    innerChunk = binaryChunk - binaryLabels;
    
    % Dilate and compare labels
    se = strel('sphere',2);
    dilatedApicalChunk = imdilate(innerChunk, se);
    innerLayer = dilatedApicalChunk.*binaryLabels;
    
    % To get apical layer, make inverse matrix and repeat the process
    inverseBinaryChunk = ones(size(binaryChunk))-binaryChunk;
    se = strel('sphere',2);
    dilatedInverseBinaryChunk = imdilate(inverseBinaryChunk, se);
    outerLayer = dilatedInverseBinaryChunk.*binaryLabels;
    
    innerLayer = innerLayer.*labelledImage_realSize;
    outerLayer = outerLayer.*labelledImage_realSize;
    
    %% STEP 3: Get Lateral Layer and save information.
    totalCells = unique(labelledImage_realSize)';
    for nCell = totalCells
        perimLateralCell = bwperim(labelledImage_realSize==nCell);
        lateralLayer(perimLateralCell)=nCell;
    end
    lateralLayer(outerLayer>0 | innerLayer>0) = 0;
    
    if saveRequest==1
        save(fullfile(segmentedPath,'realSize3dLayers.mat'), 'labelledImage_realSize','apicalLayer','basalLayer','lateralLayer', '-v7.3');
    end
else
    load(fullfile(segmentedPath,'realSize3dLayers.mat'), 'labelledImage_realSize','apicalLayer','basalLayer','lateralLayer')
end

end