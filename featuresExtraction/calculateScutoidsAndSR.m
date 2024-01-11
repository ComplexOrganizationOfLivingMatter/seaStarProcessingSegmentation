function [scutoids_cells,validScutoids_cells,outerArea,innerArea,surfaceRatio3D]=calculateScutoidsAndSR(labelledImage,apicalLayer,basalLayer,lateralLayer,path2save,fileName,dilatedVx,contactThreshold,validCells,pixel_Scale)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculateScutoidsAndSR
    % Function to calculate all scutoids in the sea star embryo
    % as well as SurfaceRatio of each cell
    %
    % INPUTS: 
    %
    % labelledImage: segmented image
    % apicalLayer: extracted from getInnerOuterLateralFromEmbryos
    % basalLayer: extracted from getInnerOuterLateralFromEmbryos
    % lateralLayer: extracted from getInnerOuterLateralFromEmbryos
    % path2save: path to save the info
    % dilatedVx: dilatation of the cells to calculate neighbour per
    % overlapping
    % contactThreshold: Threshold to decide if a cell is scutoid
    % validCells: Cells that are gonna be measured
    % pixel_Scale: pixel to micron ratio
    %
    % OUTPUTS:
    % 
    % scutoids_cells: id of cells which are scutoids
    % validScutoids_cells: ids of cells which are valid scutoids
    % outerArea: outer area of cells
    % innerArea: inner area of cells
    % surfaceRatio3D: Surface Ratio of each cell
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %defining all cells as valid cells
    if isempty(validCells)
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
    end

    %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
    %         dilatedVx = 2;
    %         contactThreshold=0.5;

    [lateral3dInfo,totalLateralCellsArea,~] = getLateralContacts(lateralLayer,dilatedVx,contactThreshold);

    %% Cellular features
    [apical3dInfo] = calculateNeighbours3D(apicalLayer, dilatedVx, apicalLayer == 0);
    if size(apical3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
        for nCell=size(apical3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
            apical3dInfo.neighbourhood{nCell}=[];
        end
    elseif size(apical3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
        apical3dInfo.neighbourhood=apical3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
    end
    apical3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,apical3dInfo.neighbourhood','UniformOutput',false);

    [basal3dInfo] = calculateNeighbours3D(basalLayer, dilatedVx, basalLayer == 0);
    if size(basal3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
        for nCell=size(basal3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
            basal3dInfo.neighbourhood{nCell}=[];
        end

    elseif size(basal3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
        basal3dInfo.neighbourhood=basal3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
    end
    basal3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,basal3dInfo.neighbourhood','UniformOutput',false);

    %check for non considered valid cells, and delete cells "0" volume
    missingCells = find(totalLateralCellsArea==0);
    validCells(ismember(validCells,missingCells))=[];
    cellsWithVolume = find(totalLateralCellsArea>0);
    noValidCells=setdiff(labelledImage,validCells);
    extraValidCells = cellsWithVolume(~ismember(cellsWithVolume,unique([validCells(:);noValidCells(:)])));
    if ~isempty(extraValidCells)
        validCells=unique([validCells(:);extraValidCells(:)])';
        disp(['Added as valid cell: ' num2str([extraValidCells(:)]')])
    end
    %         noValidCells(ismember(noValidCells,missingCells))=[];
    validCells=validCells';


    neighbours_data = table(apical3dInfo, basal3dInfo, lateral3dInfo);
    neighbours_data.Properties.VariableNames = {'Apical','Basal','Lateral'};

    %%  Calculate surface ratio
    apicalLayerResized=imresize3(apicalLayer,size(apicalLayer)*4,'nearest');
    basalLayerResized=imresize3(basalLayer,size(basalLayer)*4,'nearest');
    apical_area_cells=cell2mat(struct2cell(regionprops(apicalLayerResized,'Area'))).';
    basal_area_cells=cell2mat(struct2cell(regionprops(basalLayerResized,'Area'))).';

    outerArea=sum(basal_area_cells(validCells));
    innerArea=sum(apical_area_cells(validCells));
    surfaceRatio3D = outerArea / innerArea;

    %%  Determine if a cell is a scutoid or not
    apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(y,x), setdiff(x,y)))), neighbours_data.Apical,neighbours_data.Basal);
    scutoids_cells = double(apicoBasalTransitions>0);

    %% Filter Scutoids
    [scutoids_cells,apical3dInfo,basal3dInfo,~] = filterScutoids(neighbours_data.Apical, neighbours_data.Basal, neighbours_data.Lateral, scutoids_cells,validCells);
    %% Correct apicoBasalTransitions
    apicoBasalTransitions = cellfun(@(x, y) unique(vertcat(setdiff(y,x), setdiff(x,y))), apical3dInfo,basal3dInfo,'UniformOutput',false);

    validScutoids_cells=scutoids_cells(validCells);
    disp(mean(validScutoids_cells))

    packingFeatures=table(validCells, validScutoids_cells','VariableNames',{'ID_valid_cells' 'Valid_Scutoids'});
    %% Save variables
    save(fullfile(path2save, strcat(fileName,'_scutoids.mat')), 'scutoids_cells','packingFeatures','apicoBasalTransitions');

end

