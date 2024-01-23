function [voronoiEmbryo]=getVoronoiFrom3dCentroids(labelledImage,outPath,fileName)

%work with smaller matrix
labelledImage=imresize3(labelledImage,(size(labelledImage)/4),'nearest');

%% specify mask
cellSpace=labelledImage>1;

%% calculate centroids
centroids=regionprops3(labelledImage,'Centroid');
centroids=centroids.Centroid;
[indexEmpty,~]=find(isnan(centroids(:,3)));
centroids(indexEmpty,:)=[];


%% make seeds
seedMatrix = zeros(size(cellSpace));

for nSeed=1:length(centroids)
    y=round(centroids(nSeed,1));
    x=round(centroids(nSeed,2));
    z=round(centroids(nSeed,3));
    seedMatrix(x,y,z)=1;  
end


seeds = bwlabeln(seedMatrix);

%% get Voronoi
voronoiEmbryo = VoronoizateCells(cellSpace,seeds);
%% save
writeStackTif(uint16(voronoiEmbryo), strcat(outPath,'\','voronoi_',fileName,'.tif'));

end
