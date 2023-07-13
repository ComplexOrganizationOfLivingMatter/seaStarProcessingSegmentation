function [voronoiCyst] = VoronoizateCells(binaryMask,imgCells)
%     imgCells = readStackTif('/media/pedro/6TB/jesus/methodology_naturalVariation/unet_dani/per_image_instances/4d.3B.5_1.tif');
%     binaryMask = readStackTif('/media/pedro/6TB/jesus/methodology_naturalVariation/unet_dani/4d.3B.5_1_mask.tif');
%     binaryMask = imbinarize(binaryMask);
    %Multiply to remove cells out of tissue
    voronoiCyst=imgCells.*cast(binaryMask,class(imgCells));

    perimCells=bwperim(voronoiCyst>0);
    
    %Get bounded valid pixels
    idsToFill = find(binaryMask==1 & imgCells==0);
    [row, col, z] = ind2sub(size(binaryMask),idsToFill);
    labelPerId = zeros(size(idsToFill));
    
    idsPerim = find(perimCells==1);
    [rowPer, colPer, zPer] = ind2sub(size(binaryMask),idsPerim);
    labelsPerimIds = voronoiCyst(perimCells);
    
    %From valid pixels get closest seed (add this value)
    %tic
%     disp('generating 3D Voronoi')
    if isempty(gcp('nocreate'))
        for nId = 1:length(idsToFill)
            distCoord = pdist2([col(nId),row(nId), z(nId)],[colPer,rowPer, zPer]);
            [~,idSeedMin]=min(distCoord);
            labelPerId(nId) = labelsPerimIds(idSeedMin);
        end
        poolobj = gcp('nocreate');
        delete(poolobj);
    else
        for nId = 1:length(idsToFill)
            distCoord = pdist2([col(nId),row(nId), z(nId)],[colPer,rowPer, zPer]);
            [~,idSeedMin]=min(distCoord);
            labelPerId(nId) = labelsPerimIds(idSeedMin);
        end
    end
    %toc
    voronoiCyst(idsToFill)=labelPerId;
end

