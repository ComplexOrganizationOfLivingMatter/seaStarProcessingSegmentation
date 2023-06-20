function [CellularFeaturesValidCells,CellularFeaturesAllCells, meanSurfaceRatio] = calculate_CellularFeatures(apicalLayer,basalLayer,labelledImage,totalLateralCellsArea,absoluteLateralContacts,noValidCells,validCells)
    %CALCULATE_CELLULARFEATURES Summary of this function goes here
    %   Detailed explanation goes here

    %% Calculate polygon distribution
%     [polygon_distribution_Apical] = calculate_polygon_distribution(cellfun(@length, apical3dInfo), validCells);
%     [polygon_distribution_Basal] = calculate_polygon_distribution(cellfun(@length, basal3dInfo), validCells);
%     [polygon_distribution_Lateral] = calculate_polygon_distribution(cellfun(@length, lateral3dInfo), validCells);
%     neighbours_data = table(apical3dInfo, basal3dInfo, lateral3dInfo);
% %     polygon_distribution = table(polygon_distribution_Apical, polygon_distribution_Basal,polygon_distribution_Lateral);
%     neighbours_data.Properties.VariableNames = {'Apical','Basal','Lateral'};
%     polygon_distribution.Properties.VariableNames = {'Apical','Basal','Lateral'};

    %%  Calculate number of neighbours of each cell
%     number_neighbours = table(cellfun(@length,(apical3dInfo)),cellfun(@length,(basal3dInfo)),cellfun(@length,(lateral3dInfo)));
%    
%     apicobasal_neighbours=cellfun(@(x,y)(unique(vertcat(x,y))), apical3dInfo, basal3dInfo, 'UniformOutput',false);
%     apicobasal_neighboursRecount= cellfun(@length ,apicobasal_neighbours);
    
    %%  Calculate area cells
    apical_area_cells=cell2mat(struct2cell(regionprops(apicalLayer,'Area'))).';
    basal_area_cells=cell2mat(struct2cell(regionprops(basalLayer,'Area'))).';
    lateral_area_cells = totalLateralCellsArea;
    
    if size(apical_area_cells,1) ~= size(lateral_area_cells,1)
        if size(apical_area_cells,1) < size(lateral_area_cells,1)
            for nCell=size(apical_area_cells,1)+1:size(lateral_area_cells,1)
                apical_area_cells(nCell,1)=0;
            end
        else
            for nCell=size(lateral_area_cells,1)+1:size(apical_area_cells,1)
                lateral_area_cells(nCell,1)=0;
            end
        end
    end
    
    if size(basal_area_cells,1) ~= size(lateral_area_cells,1)
        if size(basal_area_cells,1) < size(lateral_area_cells,1)
            for nCell=size(basal_area_cells,1)+1:size(lateral_area_cells,1)
                basal_area_cells(nCell,1)=0;
            end
        else
            for nCell=size(lateral_area_cells,1)+1:size(basal_area_cells,1)
                lateral_area_cells(nCell,1)=0;
            end
        end
    end
    
    average_lateral_wall = zeros(size(apical_area_cells,1),1);
    std_lateral_wall = zeros(size(apical_area_cells,1),1);
    
    meanSurfaceRatio = sum(basal_area_cells(validCells)) / sum(apical_area_cells(validCells));

    %%  Calculate volume cells
    volume_cells=table2array(regionprops3(labelledImage,'Volume'));

    %%  Determine if a cell is a scutoid or not
%     apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(y,x), setdiff(x,y)))), neighbours_data.Apical,neighbours_data.Basal);
%     scutoids_cells = double(apicoBasalTransitions>0);

    %% Calculate cell height
    cell_heights = calculateCellHeight(apicalLayer, basalLayer);
    
    if size(cell_heights,1) ~= size(lateral_area_cells,1)
        for nCell=size(cell_heights,1)+1:size(lateral_area_cells,1)
            cell_heights(nCell,1)=0;
        end
    end

    %%  Export to a excel file
    ID_cells=unique([validCells; noValidCells]);
    CellularFeaturesAllCells=table(ID_cells,apical_area_cells,basal_area_cells,lateral_area_cells, scutoids_cells,apicoBasalTransitions, volume_cells,cell_heights);
    CellularFeaturesAllCells.Properties.VariableNames = {'ID_Cell','Apical_area','Basal_area','Lateral_area','scutoids', 'apicoBasalTransitions', 'Volume','Cell_height'};
    
    CellularFeaturesValidCells = CellularFeaturesAllCells(validCells,:);
    
end

