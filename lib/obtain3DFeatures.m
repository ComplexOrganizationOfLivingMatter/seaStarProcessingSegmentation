function [cells3dFeatures, tissue3dFeatures,numValidCells,numTotalCells, surfaceRatio3D, validCells, apicoBasalNeighs] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,validCells,noValidCells,path2save,contactThreshold)
    if ~exist(fullfile(path2save, 'morphological3dFeatures.mat'),'file')
       
        %% (default se = 3)
        dilatedVx = 4;
        [lateral3dInfo_total,totalLateralCellsArea,absoluteLateralContacts] = getLateralContacts(lateralLayer,dilatedVx,contactThreshold);

        %% Cellular features 
        [apical3dInfo] = calculateNeighbours3D(apicalLayer, dilatedVx, apicalLayer == 0);
        
        if size(apical3dInfo.neighbourhood,1) ~= size(lateral3dInfo_total',1)
            for nCell=size(apical3dInfo.neighbourhood,1)+1:size(lateral3dInfo_total',1)
                apical3dInfo.neighbourhood{nCell}=[];
                
            end
        end
        
        apical3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo_total,apical3dInfo.neighbourhood','UniformOutput',false);
        
        [basal3dInfo] = calculateNeighbours3D(basalLayer, dilatedVx, basalLayer == 0);
        
        if size(basal3dInfo.neighbourhood,1) ~= size(lateral3dInfo_total',1)
            for nCell=size(basal3dInfo.neighbourhood,1)+1:size(lateral3dInfo_total',1)
                basal3dInfo.neighbourhood{nCell}=[];
                
            end
        end
        
        
        basal3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo_total,basal3dInfo.neighbourhood','UniformOutput',false);
        
                
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
        noValidCells(ismember(noValidCells,missingCells))=[];
        numValidCells = length(validCells);

        
        %% Obtain cells descriptors
        % get apical, basal and lateral sides cells. Areas and cell Volume
        [cellularFeaturesValidCells,CellularFeaturesAllCells,surfaceRatio3D,apicoBasalNeighs] = calculate_CellularFeatures(apical3dInfo,basal3dInfo,lateral3dInfo,apicalLayer,basalLayer,labelledImage,totalLateralCellsArea,absoluteLateralContacts,noValidCells,validCells);
        %%Extract each cell and calculate 3D features
        [cells3dFeatures] = extract3dDescriptors(labelledImage, validCells);
        
%         polygon_distribution_basal= polygon_distribution.Basal;
%         polygon_distribution_apical = polygon_distribution.Apical;
%         polygon_distribution_lateral = polygon_distribution.Lateral;
        
        %% Obtain Lumen descriptors
%         [lumen3dFeatures] = extract3dDescriptors(lumenImage>0, 1);
%         lumen3dFeatures.ID_Cell = 'Lumen';

        %% Obtain Tissue descriptors
        [tissue3dFeatures] = extract3dDescriptors(labelledImage>0, 1);
        tissue3dFeatures.ID_Cell = 'Tissue';

        %% Obtain Tissue + Lumen descriptors
%         [tissue3dFeatures] = extract3dDescriptors(labelledImage>0|lumenImage>0, 1);
%         tissue3dFeatures.ID_Cell = 'Tissue and Lumen';

        
        %refactor purely voxels measurement to be compared with the surface
        %area extraction 
%         sumApicalAreas = sum(CellularFeaturesAllCells.Apical_area);
%         sumBasalAreas = sum(CellularFeaturesAllCells.Basal_area);
%         refactorBasalAreas = sumBasalAreas/tissue3dFeatures.SurfaceArea;
%         refactorApicalAreas = sumApicalAreas/lumen3dFeatures.SurfaceArea;
%         
%         lateralAreas = cells3dFeatures.SurfaceArea - (cellularFeaturesValidCells.Apical_area./refactorApicalAreas) - (cellularFeaturesValidCells.Basal_area./refactorBasalAreas);
%         refactorLateralAreas = cellularFeaturesValidCells.Lateral_area./lateralAreas;
%         
        cellAreaNeighsInfo = table(cellularFeaturesValidCells.Apical_sides, cellularFeaturesValidCells.Apical_area,cellularFeaturesValidCells.Basal_sides, cellularFeaturesValidCells.Basal_area,cellularFeaturesValidCells.Cell_height,cellularFeaturesValidCells.Lateral_sides, cellularFeaturesValidCells.Lateral_area,cellularFeaturesValidCells.Average_cell_wall_area,cellularFeaturesValidCells.Std_cell_wall_area,'VariableNames',{'apical_NumNeighs','apical_Area','basal_NumNeighs','basal_Area','cell_height','lateral_NumNeighs','lateral_Area','average_cell_wall_Area','std_cell_wall_Area'});
        cells3dFeatures = horzcat(cells3dFeatures,cellAreaNeighsInfo,table(cellularFeaturesValidCells.Scutoids, cellularFeaturesValidCells.apicoBasalTransitions,cellularFeaturesValidCells.Apicobasal_neighbours,'VariableNames',{'scutoids','apicoBasalTransitions','n3d_apicoBasalNeighbours'}));

        %% Save variables
        save(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'cellularFeaturesValidCells','CellularFeaturesAllCells', 'numValidCells','numTotalCells', 'surfaceRatio3D', 'apicoBasalNeighs', 'apical3dInfo','basal3dInfo','lateral3dInfo');

    else
        load(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures','cellularFeaturesValidCells','CellularFeaturesAllCells', 'numValidCells','numTotalCells', 'surfaceRatio3D','apicoBasalNeighs','apical3dInfo','basal3dInfo','lateral3dInfo');        
%         numValidCells = length(validCells);
%         cellularFeaturesValidCells = CellularFeaturesAllCells(validCells,:);  
%         save(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'cellularFeaturesValidCells', 'numValidCells','numTotalCells', 'surfaceRatio3D', 'apicoBasalNeighs', 'apical3dInfo','basal3dInfo','lateral3dInfo');
    end
end

