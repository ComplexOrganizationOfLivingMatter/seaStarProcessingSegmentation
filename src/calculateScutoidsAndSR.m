function [scutoids_cells,validScutoids_cells,outerArea,innerArea,surfaceRatio3D]=calculateScutoidsAndSR(labelledImage,apicalLayer,basalLayer,lateralLayer,path2save,fileName,dilatedVx,contactThreshold,validCells,pixel_Scale)

%defining all cells as valid cells
if isempty(validCells)
    validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
    noValidCells = [];
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
lateral_area_cells = totalLateralCellsArea;

outerArea=sum(basal_area_cells(validCells));
innerArea=sum(apical_area_cells(validCells));
surfaceRatio3D = outerArea / innerArea;

%%  Determine if a cell is a scutoid or not
apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(y,x), setdiff(x,y)))), neighbours_data.Apical,neighbours_data.Basal);
scutoids_cells = double(apicoBasalTransitions>0);

%% Filter Scutoids
scutoids_cells = filterScutoids(apical3dInfo, basal3dInfo, lateral3dInfo, validCells);

%% Correct apicoBasalTransitions
apicoBasalTransitions = apicoBasalTransitions.*scutoids_cells;

validScutoids_cells=scutoids_cells(validCells);
disp(mean(validScutoids_cells))

packingFeatures=table(validCells, validScutoids_cells','VariableNames',{'ID_valid_cells' 'Valid_Scutoids'});
%% Save variables
save(fullfile(path2save, strcat(fileName,'_scutoids.mat')), 'scutoids_cells','packingFeatures');

end

