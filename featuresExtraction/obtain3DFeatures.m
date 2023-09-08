function [cells3dFeatures, tissue3dFeatures,numValidCells,numTotalCells, surfaceRatio3D, validCells] = obtain3DFeatures(labelledImage,outerLayer,innerLayer,lateralLayer,validCells,noValidCells,path2save)
    if ~exist(fullfile(path2save, 'morphological3dFeatures.mat'),'file')

        %% Cellular features       
        lateralLayerAux = lateralLayer;
        lateralLayerAux(labelledImage==0)=0;

        [~,totalLateralCellsArea,~] = getLateralContacts(lateralLayerAux,2,0.5);


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
        % Extract cell size and shape descriptors
        [cellularFeaturesValidCells,CellularFeaturesAllCells,surfaceRatio3D,totalOuterArea,totalInnerArea] = calculate_CellularFeatures(outerLayer,innerLayer,labelledImage,totalLateralCellsArea,noValidCells,validCells);

        %% Obtain Tissue descriptors
        validLabelledImage=labelledImage;
        for nCell=1:length(noValidCells)
            validLabelledImage(labelledImage==noValidCells(nCell))=0;
        end
        
        [tissue3dFeatures,~,~] = calculate_CellularFeatures([],[],validLabelledImage>0,[],[],1);
        tissue3dFeatures.ID_Cell = 'Tissue';
        tissueSurfaces=table(totalOuterArea,totalInnerArea);
        tissueSurfaces.Properties.VariableNames = {'outer_surfaceArea','inner_surfaceArea'};
        tissue3dFeatures=horzcat(tissue3dFeatures,tissueSurfaces);
        
        cells3dFeatures = cellularFeaturesValidCells;

        %% Save variables
        save(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'CellularFeaturesAllCells', 'numValidCells','numTotalCells', 'surfaceRatio3D');

    else
        load(fullfile(path2save, 'morphological3dFeatures.mat'), 'cells3dFeatures', 'tissue3dFeatures', 'numValidCells','numTotalCells', 'surfaceRatio3D');        
    end
end

