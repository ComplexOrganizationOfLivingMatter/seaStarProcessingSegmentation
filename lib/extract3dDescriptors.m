function [cells3dFeatures] = extract3dDescriptors(labelledImage, validCells)
%EXTRACT3DDESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here
cells3dFeatures=[];

for indexCell = 1:length(validCells)
    actualImg = bwlabeln(labelledImage==validCells(indexCell));
    oneCell3dFeatures = regionprops3(actualImg, 'PrincipalAxisLength', 'Volume', 'ConvexVolume', 'Solidity', 'SurfaceArea', 'EquivDiameter');
    if size(oneCell3dFeatures, 1) > 0
        indMax = 1;
        if size(oneCell3dFeatures, 1) > 1
            [~,indMax] = max(oneCell3dFeatures.Volume);
            oneCell3dFeatures = oneCell3dFeatures(indMax,:);
        end
        
%         [x, y, z] = ind2sub(size(labelledImage), find(actualImg==indMax));
%         [~, convexVolume] = convhull(x, y, z);
%         oneCell3dFeatures.ConvexVolume = convexVolume;
%         oneCell3dFeatures.Solidity = sum(actualImg(:)==indMax) / convexVolume;
        aspectRatio = max(oneCell3dFeatures.PrincipalAxisLength,[],2) ./ min(oneCell3dFeatures.PrincipalAxisLength,[],2);
        sphereArea = 4 * pi .* ((oneCell3dFeatures.EquivDiameter) ./ 2) .^ 2;
        sphericity = sphereArea ./ oneCell3dFeatures.SurfaceArea;
        normalizedVolume = oneCell3dFeatures.Volume;
        irregularityShapeIndex = sqrt(oneCell3dFeatures.SurfaceArea)./(oneCell3dFeatures.Volume.^(1/3));
        cells3dFeatures = [cells3dFeatures; horzcat(oneCell3dFeatures, table(aspectRatio, sphericity, normalizedVolume,irregularityShapeIndex))];
    end
end
cells3dFeatures.normalizedVolume = arrayfun(@(x) x/mean(cells3dFeatures.Volume), cells3dFeatures.normalizedVolume);


columnIDs = table('Size', size([validCells(:)]), 'VariableTypes', {'string'});
columnIDs.Properties.VariableNames = {'ID_Cell'};
columnIDs.ID_Cell = arrayfun(@(x) strcat('cell_', num2str(x)), [validCells(:)], 'UniformOutput', false);
cells3dFeatures = horzcat(columnIDs, cells3dFeatures);
end

