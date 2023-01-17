function [allGeneralInfo,tissue3dFeatures,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,path2save,fileName,pixelScale,contactThreshold,validCells,noValidCells)

    if ~exist(path2save,'dir')
        mkdir(path2save)
    end
    
    if ~exist(fullfile(path2save, 'global_3dFeatures.mat'),'file')
        %defining all cells as valid cells
        if isempty(validCells)
            validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
            noValidCells = [];
        end
        
        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
        [cells3dFeatures, tissue3dFeatures,numValidCells,numTotalCells, surfaceRatio3D, validCells] = obtain3DFeatures(labelledImage,apicalLayer,basalLayer,lateralLayer,validCells,noValidCells,path2save,contactThreshold);
        
        %% Calculate mean and std of 3D features
        meanCellsFeatures = varfun(@(x) mean(x),cells3dFeatures(:, (2:end-2)));
        stdCellsFeatures = varfun(@(x) std(x),cells3dFeatures(:,(2:end-2)));

        % Voxels/Pixels to Micrometers
        [totalMeanCellsFeatures,totalStdCellsFeatures, tissue3dFeatures] = convertPixelsToMicrons(meanCellsFeatures,stdCellsFeatures, tissue3dFeatures,pixelScale);

%         allTissues = [tissue3dFeatures, cell2table(polygon_distribution_apical(2, :), 'VariableNames', strcat('apical_', polygon_distribution_apical(1, :))), cell2table(polygon_distribution_basal(2, :), 'VariableNames', strcat('basal_', polygon_distribution_basal(1, :))), cell2table(polygon_distribution_lateral(2, :), 'VariableNames', strcat('lateral_', polygon_distribution_lateral(1, :)))];
        allGeneralInfo = cell2table([{fileName}, {surfaceRatio3D}, {numValidCells},{numTotalCells}],'VariableNames', {'ID_Glands', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total'});

        save(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'tissue3dFeatures');
    else
        load(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'tissue3dFeatures');
    end
    
    

end

