function [allGeneralInfo,tissue3dFeatures,totalMeanCellsFeatures,totalStdCellsFeatures]=calculate3DMorphologicalFeatures(labelledImage,innerLayer,outerLayer,lateralLayer,path2save,fileName,pixelScale,validCells,noValidCells)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate3DMorphologicalFeatures
    % Function to calculate 3D morphological features
    %
    % INPUTS
    % labelledImage: Segmented image
    % innerLayer: Extracted from getInnerOuterLateralFromEmbryos function
    % outerLayer: Extracted from getInnerOuterLateralFromEmbryos function
    % lateralLayer: Extracted from getInnerOuterLateralFromEmbryos function
    % path2save: path to save output data
    % fileName: fileName to save output data
    % pixelScale: Ratio pixe to micron
    % validCells: Cells that are gonna be measured
    % noValidCells: Cells that are gonna be ommited
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        [cells3dFeatures, tissue3dFeatures,numValidCells,numTotalCells, surfaceRatio3D, ~] = obtain3DFeatures(labelledImage,innerLayer,outerLayer,lateralLayer,validCells,noValidCells,path2save);
        
        %% Calculate mean and std of 3D features
        meanCellsFeatures = varfun(@(x) mean(x),cells3dFeatures(:, (2:end-2)));
        stdCellsFeatures = varfun(@(x) std(x),cells3dFeatures(:,(2:end-2)));

        % Voxels/Pixels to Micrometers
        [totalMeanCellsFeatures,totalStdCellsFeatures, tissue3dFeatures] = convertPixelsToMicrons(meanCellsFeatures,stdCellsFeatures, tissue3dFeatures,pixelScale);

        allGeneralInfo = cell2table([{fileName}, {surfaceRatio3D}, {numValidCells},{numTotalCells}],'VariableNames', {'ID_Glands', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total'});
        save(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'tissue3dFeatures');
    else
        load(fullfile(path2save, 'global_3dFeatures.mat'), 'allGeneralInfo', 'totalMeanCellsFeatures','totalStdCellsFeatures', 'tissue3dFeatures');
    end
    
    

end

