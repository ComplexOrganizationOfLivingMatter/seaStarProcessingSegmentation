function [scutoids_cells,validScutoids_cells]=calculateOnlyScutoids(labelledImage,apicalLayer,basalLayer,lateralLayer,path2save,fileName,pixelScale,contactThreshold,validCells,noValidCells)

%     if ~exist(path2save,'dir')
%         mkdir(path2save)
%     end
    
        %defining all cells as valid cells
        if isempty(validCells)
            validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
            noValidCells = [];
        end
        
        %% Obtain 3D features from Cells, Tissue, Lumen and Tissue+Lumen
               
                %% (default se = 3)
        dilatedVx = 2;
        contactThreshold=2;
        
        [lateral3dInfo_total,totalLateralCellsArea,absoluteLateralContacts] = getLateralContacts(lateralLayer,dilatedVx,contactThreshold);

        %% Cellular features 
        [apical3dInfo] = calculateNeighbours3D(apicalLayer, dilatedVx, apicalLayer == 0);
        
        if size(apical3dInfo.neighbourhood,1) < size(lateral3dInfo_total',1)
            for nCell=size(apical3dInfo.neighbourhood,1)+1:size(lateral3dInfo_total',1)
                apical3dInfo.neighbourhood{nCell}=[];
                
            end
        elseif size(apical3dInfo.neighbourhood,1) > size(lateral3dInfo_total',1)
            apical3dInfo.neighbourhood=apical3dInfo.neighbourhood(1:size(lateral3dInfo_total,2),1);
        end
      
        apical3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo_total,apical3dInfo.neighbourhood','UniformOutput',false);
        
        [basal3dInfo] = calculateNeighbours3D(basalLayer, dilatedVx, basalLayer == 0);
        
        if size(basal3dInfo.neighbourhood,1) < size(lateral3dInfo_total',1)
            for nCell=size(basal3dInfo.neighbourhood,1)+1:size(lateral3dInfo_total',1)
                basal3dInfo.neighbourhood{nCell}=[]; 
            end
            
        elseif size(basal3dInfo.neighbourhood,1) > size(lateral3dInfo_total',1)
            basal3dInfo.neighbourhood=basal3dInfo.neighbourhood(1:size(lateral3dInfo_total,2),1);
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
%         noValidCells(ismember(noValidCells,missingCells))=[];
        numValidCells = length(validCells);

        validCells=validCells';
        %% Obtain cells descriptors
        % get apical, basal and lateral sides cells. Areas and cell Volume
        %% Calculate polygon distribution
%     [polygon_distribution_Apical] = calculate_polygon_distribution(cellfun(@length, apical3dInfo), validCells);
%     [polygon_distribution_Basal] = calculate_polygon_distribution(cellfun(@length, basal3dInfo), validCells);
%     [polygon_distribution_Lateral] = calculate_polygon_distribution(cellfun(@length, lateral3dInfo), validCells);
    neighbours_data = table(apical3dInfo, basal3dInfo, lateral3dInfo);
%     polygon_distribution = table(polygon_distribution_Apical, polygon_distribution_Basal,polygon_distribution_Lateral);
    neighbours_data.Properties.VariableNames = {'Apical','Basal','Lateral'};
%     polygon_distribution.Properties.VariableNames = {'Apical','Basal','Lateral'};

    %%  Calculate number of neighbours of each cell
%     number_neighbours = table(cellfun(@length,(apical3dInfo)),cellfun(@length,(basal3dInfo)),cellfun(@length,(lateral3dInfo)));
   
    apicobasal_neighbours=cellfun(@(x,y)(unique(vertcat(x,y))), apical3dInfo, basal3dInfo, 'UniformOutput',false);
    apicobasal_neighboursRecount= cellfun(@length ,apicobasal_neighbours);
    
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
    
%     average_lateral_wall = zeros(size(apical_area_cells,1),1);
%     std_lateral_wall = zeros(size(apical_area_cells,1),1);
    
    surfaceRatio3D = sum(basal_area_cells(validCells)) / sum(apical_area_cells(validCells));

    %%  Calculate volume cells
%     volume_cells=table2array(regionprops3(labelledImage,'Volume'));
%     disp(mean(volume_cells))
    %%  Determine if a cell is a scutoid or not
    apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(y,x), setdiff(x,y)))), neighbours_data.Apical,neighbours_data.Basal);
    scutoids_cells = double(apicoBasalTransitions>0);
    
    %% Filter Scutoids
    scutoids_cells = filterScutoids(apical3dInfo, basal3dInfo, lateral3dInfo, validCells);
    
    %% Correct apicoBasalTransitions
    apicoBasalTransitions = apicoBasalTransitions.*scutoids_cells;

    %% Calculate cell height
%     cell_heights = calculateCellHeight(apicalLayer, basalLayer);
%     
%     if size(cell_heights,1) ~= size(lateral_area_cells,1)
%         for nCell=size(cell_heights,1)+1:size(lateral_area_cells,1)
%             cell_heights(nCell,1)=0;
%         end
%     end

    %%  Export to a excel file
%     ID_cells=unique([validCells; noValidCells]);
%     CellularFeaturesAllCells=table(ID_cells,apical_area_cells,basal_area_cells,lateral_area_cells, scutoids_cells, apicoBasalTransitions, volume_cells,cell_heights);
%     CellularFeaturesAllCells.Properties.VariableNames = {'ID_Cell','Apical_area','Basal_area','Lateral_area','scutoids_cells', 'apicoBasalTransitions', 'Volume','Cell_height'};
%     
%     CellularFeaturesValidCells = CellularFeaturesAllCells(validCells,:);        
      disp(fileName)

      
      for nCell=1:max(max(max(labelledImage)))
          if scutoids_cells(nCell)==0
              labelledImage(labelledImage==nCell)=513;
          end 
      end
      writeStackTif(uint16(labelledImage),fullfile(path2save,strcat(fileName,'.tiff')))
      validScutoids_cells=scutoids_cells(validCells);
      disp(mean(scutoids_cells)) 
      dis(mean(validScutoids_cells))
%       disp(length(scutoids_cells))   
        %% Save variables
        save(fullfile(path2save, strcat(fileName,'_scutoids.mat')), 'scutoids_cells','validCells');
% 
%     
    

end

