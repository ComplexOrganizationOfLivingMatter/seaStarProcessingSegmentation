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
    outerLayerResized=imresize3(outerLayer,size(outerLayer)/2,'nearest');
    innerLayerResized=imresize3(innerLayer,size(innerLayer)/2,'nearest');
    lateralLayerResized=imresize3(lateralLayer,size(lateralLayer)/2,'nearest');
    
    %defining all cells as valid cells
    if isempty(validCells)
        validCells = find(table2array(regionprops3(labelledImage,'Volume'))>0);
    end

    %% Filter lateral contacts
    [lateral3dInfo,totalLateralCellsArea,~] = getLateralContacts(lateralLayerResized,dilatedVx,contactThreshold);
    
    if exist(strcat(path2save,'\','packing_',fileName,'.mat'),'file')~=2
        %% calculate neighbours
        [outer3dInfo] = calculateNeighbours3D(outerLayerResized, dilatedVx, outerLayerResized == 0);
        if size(outer3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
            for nCell=size(outer3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
                outer3dInfo.neighbourhood{nCell}=[];
            end
        elseif size(outer3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
            outer3dInfo.neighbourhood=outer3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
        end
        
        
        [inner3dInfo] = calculateNeighbours3D(innerLayerResized, dilatedVx, innerLayerResized == 0);
        if size(inner3dInfo.neighbourhood,1) < size(lateral3dInfo',1)
            for nCell=size(inner3dInfo.neighbourhood,1)+1:size(lateral3dInfo',1)
                inner3dInfo.neighbourhood{nCell}=[];
            end
            
        elseif size(inner3dInfo.neighbourhood,1) > size(lateral3dInfo',1)
            inner3dInfo.neighbourhood=inner3dInfo.neighbourhood(1:size(lateral3dInfo,2),1);
        end
        save(strcat(path2save,'\','packing_',fileName,'.mat'),'outer3dInfo','inner3dInfo')
    else
        load(strcat(path2save,'\','packing_',fileName,'.mat'),'outer3dInfo','inner3dInfo')
    end

    
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

    
    fixedOuter3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,outer3dInfo.neighbourhood','UniformOutput',false);
    fixedInner3dInfo = cellfun(@(x,y) intersect(x,y),lateral3dInfo,inner3dInfo.neighbourhood','UniformOutput',false);

    neighbours_data = table(fixedOuter3dInfo, fixedInner3dInfo, lateral3dInfo);
    neighbours_data.Properties.VariableNames = {'Outer','Inner','Lateral'};

    %%  Calculate inner, outer areas and surface ratio
    outer_area_cells=cell2mat(struct2cell(regionprops(outerLayer,'Area'))).';
    inner_area_cells=cell2mat(struct2cell(regionprops(innerLayer,'Area'))).';

    outerArea=sum(outer_area_cells(validCells)*pixel_Scale^2);
    innerArea=sum(inner_area_cells(validCells)*pixel_Scale^2);
    surfaceRatio3D = outerArea / innerArea;

    %%
    OuterIndx=cellfun(@(x) isempty(x),fixedOuter3dInfo);
    InnerIndx=cellfun(@(x) isempty(x),fixedInner3dInfo);
    emptyInner=find(OuterIndx<InnerIndx);
    emptyOuter=find(OuterIndx>InnerIndx);
    if ~isempty(emptyInner)
        for nCell=1:size(emptyInner)
            fixedInner3dInfo{emptyInner(nCell)}=fixedOuter3dInfo{emptyInner(nCell)};
            neighbourCells=fixedOuter3dInfo{emptyInner(nCell)};
            for neighbour=1:size(fixedInner3dInfo{emptyInner(nCell)},1)
                indxCell=fixedOuter3dInfo{neighbourCells(neighbour)};
                indxCell(indxCell==emptyInner(nCell))=[];
                fixedOuter3dInfo{neighbourCells(neighbour)}=indxCell;
            end
        end
    end
    
    if ~isempty(emptyOuter)
        for nCell=1:size(emptyOuter)
            fixedOuter3dInfo{emptyOuter(nCell)}=fixedInner3dInfo{emptyOuter(nCell)};
            neighbourCells=fixedInner3dInfo{emptyOuter(nCell)};
            for neighbour=1:size(fixedInner3dInfo{emptyOuter(nCell)},1)
                indxCell=fixedInner3dInfo{neighbourCells(neighbour)};
                indxCell(indxCell==emptyOuter(nCell))=[];
                fixedInner3dInfo{neighbourCells(neighbour)}=indxCell;
            end
        end
    end
    %%  Determine if a cell is a scutoid or not
    apicoBasalTransitions = cellfun(@(x, y) length(unique(vertcat(setdiff(y,x), setdiff(x,y)))), fixedInner3dInfo,fixedOuter3dInfo);
    scutoids_cells = double(apicoBasalTransitions>0);

    %% Filter Scutoids
    [scutoids_cells,fixedInner3dInfo,fixedOuter3dInfo,~] = filterScutoids(fixedInner3dInfo,fixedOuter3dInfo, neighbours_data.Lateral, scutoids_cells,validCells);
    
    %% Correct apicoBasalTransitions
    apicoBasalTransitions = cellfun(@(x, y) unique(vertcat(setdiff(y,x), setdiff(x,y))), fixedOuter3dInfo,fixedInner3dInfo,'UniformOutput',false);

    validScutoids_cells=scutoids_cells(validCells);
    disp(mean(validScutoids_cells))

    packingFeatures=table(validCells, validScutoids_cells','VariableNames',{'ID_valid_cells' 'Valid_Scutoids'});
    %% Save variables
    save(fullfile(path2save, strcat(fileName,'_scutoids.mat')), 'scutoids_cells','packingFeatures','apicoBasalTransitions','lateral3dInfo','fixedInner3dInfo', 'fixedOuter3dInfo', 'contactThreshold');

end

