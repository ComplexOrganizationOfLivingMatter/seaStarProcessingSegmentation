function [CellularFeaturesValidCells,CellularFeaturesAllCells, meanSurfaceRatio,totalOuterArea,totalInnerArea] = calculate_CellularFeatures(outerLayer,innerLayer,labelledImage,totalLateralCellsArea,noValidCells,validCells)
    %CALCULATE_CELLULARFEATURES 
    %   Input:
    % Outer, inner, lateral layers and the complete labelledImage
    % total lateral areas
    % valid and no valid cells
    %
    % OR
    %
    % Valid labelledImage
    %
    %  Output:
    % individual cell size (outer,inner and lateral areas, height,volume,
    % axes lengths)
    % total outer and inner areas and surface ratio of the valid region.
    % individual cell shape (aspect ratio, convexity)
    %
    % OR
    %
    % global tissue size and shape
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    meanSurfaceRatio=[]; 
    
    if size(unique(labelledImage),1) > 2 % Split between cell and tissue features
   
        %%  Calculate area cells
        outer_area_cells=cell2mat(struct2cell(regionprops(outerLayer,'Area'))).';
        inner_area_cells=cell2mat(struct2cell(regionprops(innerLayer,'Area'))).';
        lateral_area_cells = totalLateralCellsArea;
        
        if size(outer_area_cells,1)>size(inner_area_cells,1)
            inner_area_cells(size(inner_area_cells,1)+1:size(outer_area_cells,1))=0;
        elseif size(outer_area_cells,1)<size(inner_area_cells,1)
            outer_area_cells(size(outer_area_cells,1)+1:size(inner_area_cells,1))=0;
        end
        
        if size(lateral_area_cells,1)<size(inner_area_cells,1)
            lateral_area_cells(size(lateral_area_cells,1)+1:size(inner_area_cells,1))=0;
        elseif size(outer_area_cells,1)<size(lateral_area_cells,1)
            outer_area_cells(size(outer_area_cells,1)+1:size(lateral_area_cells,1))=0;
            inner_area_cells(size(inner_area_cells,1)+1:size(lateral_area_cells,1))=0;
        end
        
        totalInnerArea=sum(inner_area_cells(validCells));
        totalOuterArea=sum(outer_area_cells(validCells));
        meanSurfaceRatio =  totalOuterArea/totalInnerArea ;
        
        %% Calculate cell height
        cell_heights = calculateCellHeight(innerLayer, outerLayer);
        
        if size(cell_heights,1) ~= size(lateral_area_cells,1)
            for nCell=size(cell_heights,1)+1:size(lateral_area_cells,1)
                cell_heights(nCell,1)=0;
                warning('cell not found')
            end
        end
    end
    
    %%  Calculate volume and surface area
    volume_cells=table2array(regionprops3(labelledImage,'Volume'));
    surface_area_cells=table2array(regionprops3(labelledImage,'SurfaceArea'));
    
    %% Calculate shape descriptors
    convexityRatio_cells=table2array(regionprops3(labelledImage, 'Solidity'));
    cellsAxesLength=regionprops3(labelledImage, 'PrincipalAxisLength');
    aspectRatio = max(cellsAxesLength.PrincipalAxisLength,[],2) ./ min(cellsAxesLength.PrincipalAxisLength,[],2);

    %%  Export to a excel file
    ID_cells=unique([validCells; noValidCells]);
    
    CellularFeaturesAllCells=table(ID_cells,volume_cells,surface_area_cells,convexityRatio_cells,aspectRatio,cellsAxesLength.PrincipalAxisLength(:,1),cellsAxesLength.PrincipalAxisLength(:,2),cellsAxesLength.PrincipalAxisLength(:,3));
    CellularFeaturesAllCells.Properties.VariableNames = {'ID_Cell','Volume','SurfaceArea','Convexity_Ratio','Aspect_Ratio','MajorAxis_Length','2Axis_Length','MinorAxis_Length'};
    
    if size(unique(labelledImage),1) > 2
        heightAreaFeatures=table(outer_area_cells,inner_area_cells,lateral_area_cells,cell_heights);
        heightAreaFeatures.Properties.VariableNames = {'Outer_area','Inner_area','Lateral_area','Cell_height'};
        CellularFeaturesAllCells=horzcat(CellularFeaturesAllCells,heightAreaFeatures);
    end
    
    CellularFeaturesValidCells = CellularFeaturesAllCells(validCells,:);

end

