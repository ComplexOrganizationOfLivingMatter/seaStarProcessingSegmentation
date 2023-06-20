function newScutoids_cells = filterScutoids(apical3dInfo, basal3dInfo, lateral3dInfo_total, validCells)

    %% Re-calculate scutoids (as done in calcualte_CellularFeatures.m
    scutoids_cells=cellfun(@(x,y) double(~isequal(x,y)), apical3dInfo,basal3dInfo);
    newScutoids_cells = zeros(size(scutoids_cells));
    newScutoids_cells_ = zeros(size(scutoids_cells));

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
     
%     newScutoids_cells = newScutoids_cells(validCells);
end