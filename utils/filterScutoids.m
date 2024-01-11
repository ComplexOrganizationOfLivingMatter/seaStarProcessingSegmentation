function [newScutoids_cells,apical3dInfo,basal3dInfo,lateral3dInfo_total] = filterScutoids(apical3dInfo, basal3dInfo, lateral3dInfo_total, oldScutoids_cells,validCells)

    %% Re-calculate scutoids (as done in calcualte_CellularFeatures.m
    scutoids_cells=cellfun(@(x,y) double(~isequal(x,y)), apical3dInfo,basal3dInfo);
    newScutoids_cells = zeros(size(scutoids_cells));

    %% Get ids of scutoids
    cellIds = linspace(1,length(scutoids_cells),length(scutoids_cells));
    scutoid_ids = nonzeros(unique(cellIds.*scutoids_cells));
    
    lateral3dInfo_scutoids=cellfun(@(x,y) double(intersect(x,scutoid_ids)), lateral3dInfo_total, 'UniformOutput', false);

    apicoBasalTransitionsLabels = cellfun(@(x, y) unique(vertcat(setdiff(x, y), setdiff(y, x))), apical3dInfo, basal3dInfo, 'UniformOutput', false);
    
    %% For each presumed scutoid, check if both the aforementioned scutoid and its couple 
    %  have a common scutoid neighbor that intercalates with another common
    %  scutoid network. That is, check that scutoids are given in quartets.
    
    for scuIx=1:length(scutoid_ids)
        % Cell index
        cellIx = scutoid_ids(scuIx);
        % Get intersections between both the cells that intercalate w/ the
        % current cell and w/ theirs scutoid neighbors
        intersections = arrayfun(@(x) intersect(lateral3dInfo_scutoids{x}, lateral3dInfo_scutoids{cellIx}), apicoBasalTransitionsLabels{cellIx}, 'UniformOutput', false);
        % Check lengths since we need at least 2 scutoid neighs shared with both the
        % current cell and the one that intercalates with
        intersectionsLengths = cellfun(@(x) length(x), intersections)';
        % Check that those scutoids are intercalating with eachother
        % forming hence at least a 4-group scutoid
        crossedIntersections = cellfun(@(x) arrayfun(@(y) intersect(apicoBasalTransitionsLabels{y}, x), x, 'UniformOutput', false), intersections, 'UniformOutput', false);
        [crossedIntersectionsNonEmpty] = cellfun(@(x) sum(cell2mat(x)), crossedIntersections)';
        % Aforementioned final condition
        scutoidCondition = arrayfun(@(x, y) x>=1 && y>=2, crossedIntersectionsNonEmpty, intersectionsLengths);
        if sum(scutoidCondition)>=1
            newScutoids_cells(cellIx) = 1;
        end
    end
     
    wrongScutoids=arrayfun(@(x, y) setdiff(x,y), oldScutoids_cells, newScutoids_cells, 'UniformOutput', false);    
    wrongScutoids=wrongScutoids(validCells);
    %after remove wrong scutoids, update apical,basal and lateral
    %neighbours with the new scutoids
    for i=1:2
        for scuIx=1:length(wrongScutoids)
            if wrongScutoids{scuIx}==1
                %fix the neighbouring cells of wrong scutoid
                %                neighboursWrongScutoids=lateral3dInfo_total{scuIx};
                %                for nCell=1: length(neighboursWrongScutoids)
                %                    apical3dInfo{neighboursWrongScutoids(nCell)}=unique([apical3dInfo{neighboursWrongScutoids(nCell)}; scuIx]);
                %                    basal3dInfo{neighboursWrongScutoids(nCell)}=unique([basal3dInfo{neighboursWrongScutoids(nCell)}; scuIx]);
                %                end
                
                
                if size(apical3dInfo{scuIx},1) < size(basal3dInfo{scuIx},1)
                    %% Wrong Intercalation between neighbouring cells
                    %fix the neighbouring cells of each wrong scutoid
                    neighbourIx=setdiff(basal3dInfo{scuIx},apical3dInfo{scuIx});
                    for nCell=1:size(neighbourIx,1)
                        apical3dInfo{neighbourIx(nCell)}=unique([apical3dInfo{neighbourIx(nCell)}; scuIx]);
                    end
                    %fix neighbours of each wrong scutoid
                    apical3dInfo{scuIx}=basal3dInfo{scuIx};
                    lateral3dInfo_total{scuIx}=basal3dInfo{scuIx};
                    
                elseif size(basal3dInfo{scuIx},1) < size(apical3dInfo{scuIx},1)
                    %% Wrong Intercalation between Not neighbouring cells
                    %fix the neighbouring cells of each wrong scutoid
                    neighbourIx=setdiff(apical3dInfo{scuIx},basal3dInfo{scuIx});
                    for nCell=1:size(neighbourIx,1)
                        apical3dInfo{neighbourIx(nCell)}(apical3dInfo{neighbourIx(nCell)}==scuIx)=[];
                        lateral3dInfo_total{neighbourIx(nCell)}(lateral3dInfo_total{neighbourIx(nCell)}==scuIx)=[];
                    end
                    %fix neighbours of each wrong scutoid
                    apical3dInfo{scuIx}=basal3dInfo{scuIx};
                    lateral3dInfo_total{scuIx}=basal3dInfo{scuIx};
                end
            end
        end
        %     newScutoids_cells = newScutoids_cells(validCells);
    end