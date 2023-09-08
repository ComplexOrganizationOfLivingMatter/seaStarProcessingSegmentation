function cell_heights = calculateCellHeight(innerLayer, outerLayer)
   
    centroidsApical = table2array(regionprops3(innerLayer,'Centroid'));
   	centroidsBasal = table2array(regionprops3(outerLayer,'Centroid'));
    
    centroidsApicalAux = centroidsApical;
    centroidsBasalAux = centroidsBasal;
    
    cell_heights = nan(size(centroidsApical,1),1);
    
    if size(centroidsBasal,1)<size(centroidsApical,1)
        for nCell=size(centroidsBasal,1)+1:size(centroidsApical,1)
             centroidsBasal=[centroidsBasal;NaN NaN NaN];
        end
    end
    
    if size(centroidsApical,1)<size(centroidsBasal,1)
        for nCell=size(centroidsApical,1)+1:size(centroidsBasal,1)
             centroidsApical=[centroidsApical;NaN NaN NaN];
        end
    end

    for idCell = 1:length(cell_heights)
        if ~isnan(centroidsApical(idCell,1)) && ~isnan(centroidsBasal(idCell,1))
            %get all apical cell voxels
            idsApical = find(innerLayer==idCell);
            [rowApical, colApical, zApical] = ind2sub(size(innerLayer),idsApical);
            
            %calculate the closest apical pixel to the calculated apical centroid
            distCoord = pdist2([colApical,rowApical, zApical],centroidsApical(idCell,:));
            [~,idSeedMin]=min(distCoord);
            centroidsApicalAux(idCell,:)= [colApical(idSeedMin),rowApical(idSeedMin), zApical(idSeedMin)];
            
            %get all basal cell voxels
            idsBasal = find(outerLayer==idCell);
            [rowBasal, colBasal, zBasal] = ind2sub(size(outerLayer),idsBasal);
            
            %calculate the closest basal voxel to the calculated basal centroid
            distCoord = pdist2([colBasal,rowBasal, zBasal],centroidsBasal(idCell,:));
            [~,idSeedMin]=min(distCoord);
            centroidsBasalAux(idCell,:)= [colBasal(idSeedMin),rowBasal(idSeedMin), zBasal(idSeedMin)];
            
            %measure distance between the two "centroids" to infere the
            %cell height
            cell_heights(idCell) = pdist2(centroidsApicalAux(idCell,:),centroidsBasalAux(idCell,:));
            
        end
        
    end
    
    
end