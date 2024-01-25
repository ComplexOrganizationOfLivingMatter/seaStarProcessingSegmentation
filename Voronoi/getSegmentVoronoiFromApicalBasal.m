function [voronoiEmbryo]=getSegmentVoronoiFromApicalBasal(labelledImage,outPath,fileName)
[innerLayer,outerLayer,~,labelledImage]=getInnerOuterLateralFromEmbryos('','',labelledImage,1,0);
labelledImage=imresize3(labelledImage,(size(labelledImage)/4),'nearest');
outerLayer=imresize3(outerLayer,(size(outerLayer)/4),'nearest');
innerLayer=imresize3(innerLayer,(size(innerLayer)/4),'nearest');

%% specify mask
cellSpace=labelledImage>1;

%% calculate centroids
% centroids=regionprops3(labelledImage,'Centroid');
% centroids=centroids.Centroid;
% [indexEmpty,~]=find(isnan(centroids(:,3)));
% centroids(indexEmpty,:)=[];


%% make seeds
% seedMatrix = zeros(size(cellSpace));
% 
% for nSeed=1:length(centroids)
%     y=round(centroids(nSeed,1));
%     x=round(centroids(nSeed,2));
%     z=round(centroids(nSeed,3));
%     seedMatrix(x,y,z)=1;  
% end
% 
% 
% seeds = bwlabeln(seedMatrix);

uniqueLabels = unique(labelledImage);

segmentSeedMatrix = zeros(size(labelledImage));

for cellIx = 2:length(uniqueLabels)
    cellId = uniqueLabels(cellIx);
    auxOuterLayer = outerLayer==cellId;
    auxInnerLayer = innerLayer==cellId;
    
    centroid = regionprops3(labelledImage==cellId, 'centroid');
    centroid = centroid.Centroid;
    centroid = mean(centroid,  1);
    outerCentroid = regionprops3(auxOuterLayer, 'centroid');
    outerCentroid = mean(outerCentroid.Centroid,1);
    innerCentroid = regionprops3(auxInnerLayer, 'centroid');
    innerCentroid = mean(innerCentroid.Centroid,1);
    
    if isempty(innerCentroid)
        try
        innerCentroid=centroid+(centroid-outerCentroid);
        if innerCentroid(3)> size(labelledImage,3)
            innerCentroid(3)=size(labelledImage,3);
        elseif innerCentroid(2)> size(labelledImage,1)
            innerCentroid(2)=size(labelledImage,1);
        elseif innerCentroid(1)> size(labelledImage,2)
            innerCentroid(1)=size(labelledImage,2);
        elseif innerCentroid(2)<0
            innerCentroid(2)=1;
        elseif innerCentroid(1)<0
            innerCentroid(1)=1;
        end
        catch
            continue
        end
    elseif isempty(outerCentroid)
        outerCentroid=centroid+(centroid-innerCentroid);
        if outerCentroid(3)> size(labelledImage,3)
            outerCentroid(3)=size(labelledImage,3);
        elseif outerCentroid(2)> size(labelledImage,1)
            outerCentroid(2)=size(labelledImage,1);
        elseif outerCentroid(1)> size(labelledImage,2)
            outerCentroid(1)=size(labelledImage,2);
        elseif outerCentroid(2)<0
            outerCentroid(2)=1;
        elseif outerCentroid(1)<0
            outerCentroid(1)=1;
        end
    end

    ypoints = [round(linspace(outerCentroid(1), centroid(1), 5)), round(linspace(centroid(1), innerCentroid(1), 5));];
    xpoints = [round(linspace(outerCentroid(2), centroid(2), 5)), round(linspace(centroid(2), innerCentroid(2), 5));];
    zpoints = [round(linspace(outerCentroid(3), centroid(3), 5)), round(linspace(centroid(3), innerCentroid(3), 5));];
    
    for ix = linspace(1,10,10)
        segmentSeedMatrix(xpoints(ix),ypoints(ix),zpoints(ix))=cellId;
    end
end

%% get Voronoi models
voronoiEmbryo = VoronoizateCells(cellSpace,segmentSeedMatrix);

%% save Voronoi models
writeStackTif(uint16(voronoiEmbryo), strcat(outPath,'\','voronoi_',fileName,'.tif'));
end
