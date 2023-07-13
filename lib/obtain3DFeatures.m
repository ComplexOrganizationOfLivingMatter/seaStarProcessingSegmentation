function [cells3dFeatures, tissue3dFeatures,numValidCells,numTotalCells, surfaceRatio3D, validCells] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,validCells,noValidCells,path2save)
    if ~exist(fullfile(path2save, 'morphological3dFeatures.mat'),'file')

        %% Cellular features       
        lateralLayerAux = lateralLayer;
        lateralLayerAux(labelledImage==0)=0;
        
        if ~isequal(lateralLayer, lateralLayerAux)
            %%the threshold is only applied in the full lateral surface
            [lateral3dInfoAux,totalLateralCellsArea,absoluteLateralContacts] = getLateralContacts(lateralLayerAux,dilatedVx,0);
            lateral3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo_total,lateral3dInfoAux,'UniformOutput',false);
        else
            lateral3dInfo = lateral3dInfo_total;
            clearvars lateral3dInfo_total lateralLayerAux
        end

        %check for non considered valid cells, and delete cells "0" volume
        missingCells = find(totalLateralCellsArea==0);
        validCells(ismember(validCells,missingCells))=[];
        cellsWithVolume = find(totalLateralCellsArea>0);
        numTotalCells=length(cellsWithVolume);
        extraValidCells = cellsWithVolume(~ismember(cellsWithVolume,unique([validCells(:);noValidCells(:)])));
        if ~isempty(extraValidCells)
            validCells=unique([validCells(:);extraValidCells(:)])';
            disp(['Added as valid cell: ' num2str([extraValidCells(:)]')])
        end
%         noValidCells(ismember(noValidCells,missingCells))=[];
        numValidCells = length(validCells);
        validCells=validCells';
        
        %% Obtain cells descriptors
        % get cell size descriptors
        [cellularFeaturesValidCells,CellularFeaturesAllCells,surfaceRatio3D] = calculate_CellularFeatures(apicalLayer,basalLayer,labelledImage,totalLateralCellsArea,absoluteLateralContacts,noValidCells,validCells);
        %%Extract cell shape descriptors
        [cells3dFeatures] = extract3dDescriptors(labelledImage, validCells);

        %% Obtain Tissue descriptors
        validLabelledImage=labelledImage;
        for nCell=1:length(noValidCells)
            validLabelledImage(labelledImage==noValidCells(nCell))=0;
        end
        [tissue3dFeatures] = extract3dDescriptors(validLabelledImage>0, 1);
        tissue3dFeatures.ID_Cell = 'Tissue';

        %refactor purely voxels measurement to be compared with the surface
        %area extraction 
        sumApicalAreas = sum(CellularFeaturesAllCells.Apical_area);
        sumBasalAreas = sum(CellularFeaturesAllCells.Basal_area);
        refactorBasalAreas = sumBasalAreas/tissue3dFeatures.SurfaceArea;
        refactorApicalAreas = sumApicalAreas/lumen3dFeatures.SurfaceArea;
        
        lateralAreas = cells3dFeatures.SurfaceArea - (cellularFeaturesValidCells.Apical_area./refactorApicalAreas) - (cellularFeaturesValidCells.Basal_area./refactorBasalAreas);
        refactorLateralAreas = cellularFeaturesValidCells.Lateral_area./lateralAreas;
        
        cellAreaNeighsInfo = table(cellularFeaturesValidCells.Apical_area,cellularFeaturesValidCells.Basal_area,cellularFeaturesValidCells.Cell_height,cellularFeaturesValidCells.Lateral_area./refactorLateralAreas,'VariableNames',{'apical_Area','basal_Area','cell_height','lateral_Area'});
        cells3dFeatures = horzcat(cells3dFeatures,cellAreaNeighsInfo);

        %% Save variables
        save(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'cellularFeaturesValidCells','CellularFeaturesAllCells', 'numValidCells','numTotalCells', 'surfaceRatio3D');

    else
        load(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures','cellularFeaturesValidCells','CellularFeaturesAllCells', 'numValidCells','numTotalCells', 'surfaceRatio3D');        
    end
end

