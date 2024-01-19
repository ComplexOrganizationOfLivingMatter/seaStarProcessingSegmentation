function [voronoiCyst]=getVoronoiFrom3dCentroids(originalImage,labelledImage,outPath,fileName)

if exist(strcat(outPath,'\','voronoi_',fileName,'.tif'),'file')~=2

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

%% make Voronoi
voronoiCyst = VoronoizateCells(cellSpace,seeds);

resizedVoronoiCyst=imresize3(voronoiCyst,size(originalImage),'nearest');
writeStackTif(uint16(resizedVoronoiCyst), strcat(outPath,'\','voronoi_',fileName,'.tif'));
else
voronoiCyst=readStackTif(strcat(outPath,'\','voronoi_',fileName,'.tif'));
voronoiCyst=imresize3(double(voronoiCyst),(size(labelledImage)/4),'nearest');
end
