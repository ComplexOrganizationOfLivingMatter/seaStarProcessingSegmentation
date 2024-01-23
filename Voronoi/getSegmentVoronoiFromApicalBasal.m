function [voronoiEmbryo]=getSegmentVoronoiFromApicalBasal(labelledImage,outPath,fileName)
[basalLayer,apicalLayer,~,labelledImage]=getInnerOuterLateralFromEmbryos('','',labelledImage,1,0);
labelledImage=imresize3(labelledImage,(size(labelledImage)/4),'nearest');
apicalLayer=imresize3(apicalLayer,(size(apicalLayer)/4),'nearest');
basalLayer=imresize3(basalLayer,(size(basalLayer)/4),'nearest');

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
    auxApicalLayer = apicalLayer==cellId;
    auxBasalLayer = basalLayer==cellId;
    
    centroid = regionprops3(labelledImage==cellId, 'centroid');
    centroid = centroid.Centroid;
    centroid = mean(centroid,  1);
    apicalCentroid = regionprops3(auxApicalLayer, 'centroid');
    apicalCentroid = mean(apicalCentroid.Centroid,1);
    basalCentroid = regionprops3(auxBasalLayer, 'centroid');
    basalCentroid = mean(basalCentroid.Centroid,1);
    
    if isempty(basalCentroid)
        try
        basalCentroid=centroid+(centroid-apicalCentroid);
        if basalCentroid(3)> size(labelledImage,3)
            basalCentroid(3)=size(labelledImage,3);
        elseif basalCentroid(2)> size(labelledImage,1)
            basalCentroid(2)=size(labelledImage,1);
        elseif basalCentroid(1)> size(labelledImage,2)
            basalCentroid(1)=size(labelledImage,2);
        elseif basalCentroid(2)<0
            basalCentroid(2)=1;
        elseif basalCentroid(1)<0
            basalCentroid(1)=1;
        end
        catch
            continue
        end
    elseif isempty(apicalCentroid)
        apicalCentroid=centroid+(centroid-basalCentroid);
        if apicalCentroid(3)> size(labelledImage,3)
            apicalCentroid(3)=size(labelledImage,3);
        elseif apicalCentroid(2)> size(labelledImage,1)
            apicalCentroid(2)=size(labelledImage,1);
        elseif apicalCentroid(1)> size(labelledImage,2)
            apicalCentroid(1)=size(labelledImage,2);
        elseif apicalCentroid(2)<0
            apicalCentroid(2)=1;
        elseif apicalCentroid(1)<0
            apicalCentroid(1)=1;
        end
    end

    ypoints = [round(linspace(apicalCentroid(1), centroid(1), 5)), round(linspace(centroid(1), basalCentroid(1), 5));];
    xpoints = [round(linspace(apicalCentroid(2), centroid(2), 5)), round(linspace(centroid(2), basalCentroid(2), 5));];
    zpoints = [round(linspace(apicalCentroid(3), centroid(3), 5)), round(linspace(centroid(3), basalCentroid(3), 5));];
    
    for ix = linspace(1,10,10)
        segmentSeedMatrix(xpoints(ix),ypoints(ix),zpoints(ix))=cellId;
    end
end

%% get Voronoi models
voronoiEmbryo = VoronoizateCells(cellSpace,segmentSeedMatrix);

%% save Voronoi models
writeStackTif(uint16(voronoiEmbryo), strcat(outPath,'\','voronoi_',fileName,'.tif'));
end
