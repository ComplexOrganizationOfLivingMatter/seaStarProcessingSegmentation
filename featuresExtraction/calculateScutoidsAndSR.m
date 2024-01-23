function [scutoids_cells,validScutoids_cells,outerArea,innerArea,surfaceRatio3D]=calculateScutoidsAndSR(labelledImage,innerLayer,outerLayer,lateralLayer,path2save,fileName,dilatedVx,contactThreshold,validCells,pixel_Scale)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculateScutoidsAndSR
    % Function to calculate all scutoids in the sea star embryo
    % as well as SurfaceRatio of each cell
    %
    % INPUTS: 
    %
    % labelledImage: segmented image
    % outerLayer: extracted from getInnerOuterLateralFromEmbryos
    % innerLayer: extracted from getInnerOuterLateralFromEmbryos
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
    
    %downsampling to optimize calculate 3D neighbours
    outerLayerResized=imresize3(outerLayer,size(outerLayer)*4,'nearest');
    innerLayerResized=imresize3(innerLayer,size(innerLayer)*4,'nearest');
    lateralLayerResized=imresize3(lateralLayer,size(lateralLayer)*4,'nearest');
    
    %defining all cells as valid cells
    if isempty(validCells)
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
    end

    %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
    %         dilatedVx = 2;
    %         contactThreshold=0.5;

    [lateral3dInfo,totalLateralCellsArea,~] = getLateralContacts(lateralLayerResized,dilatedVx,contactThreshold);

    %% Cellular features
    [outer3dInfo] = calculateNeighbours3D(outerLayerResized, dilatedVx, outerLayerResized == 0);
    if size(outer3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
        for nCell=size(outer3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
            outer3dInfo.neighbourhood{nCell}=[];
        end
    elseif size(outer3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
        outer3dInfo.neighbourhood=outer3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
    end
    outer3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,outer3dInfo.neighbourhood','UniformOutput',false);

    [inner3dInfo] = calculateNeighbours3D(innerLayerResized, dilatedVx, innerLayerResized == 0);
    if size(inner3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
        for nCell=size(inner3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
            inner3dInfo.neighbourhood{nCell}=[];
        end

    elseif size(inner3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
        inner3dInfo.neighbourhood=inner3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
    end
    inner3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,inner3dInfo.neighbourhood','UniformOutput',false);

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


    neighbours_data = table(outer3dInfo, inner3dInfo, lateral3dInfo);
    neighbours_data.Properties.VariableNames = {'Outer','Inner','Lateral'};

    %%  Calculate surface ratio
    outer_area_cells=cell2mat(struct2cell(regionprops(outerLayer,'Area'))).';
    inner_area_cells=cell2mat(struct2cell(regionprops(innerLayer,'Area'))).';

    outerArea=sum(outer_area_cells(validCells)*pixel_Scale^2);
    innerArea=sum(inner_area_cells(validCells)*pixel_Scale^2);
    surfaceRatio3D = outerArea / innerArea;

    %%  Determine if a cell is a scutoid or not
    apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(y,x), setdiff(x,y)))), neighbours_data.Apical,neighbours_data.Basal);
    scutoids_cells = double(apicoBasalTransitions>0);

    %% Filter Scutoids
    [scutoids_cells,outer3dInfo,inner3dInfo,~] = filterScutoids(neighbours_data.Outer, neighbours_data.Inner, neighbours_data.Lateral, scutoids_cells,validCells);
    %% Correct apicoBasalTransitions
    apicoBasalTransitions = cellfun(@(x, y) unique(vertcat(setdiff(y,x), setdiff(x,y))), outer3dInfo,inner3dInfo,'UniformOutput',false);

    validScutoids_cells=scutoids_cells(validCells);
    disp(mean(validScutoids_cells))

    packingFeatures=table(validCells, validScutoids_cells','VariableNames',{'ID_valid_cells' 'Valid_Scutoids'});
    %% Save variables
    save(fullfile(path2save, strcat(fileName,'_scutoids.mat')), 'scutoids_cells','packingFeatures','apicoBasalTransitions');

end

