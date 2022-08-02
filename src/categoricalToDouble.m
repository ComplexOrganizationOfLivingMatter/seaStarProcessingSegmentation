labels1=double(labels);
labels1(isnan(labels1))=0;
imagePredScaled=labels1;
imageMaskScaled=labelledImage;

imageAux =zeros(size(imagePredScaled));

centroids = regionprops3(imageMaskScaled,'Centroid');
centroids = round(centroids.Centroid);
for nCell = 1:length(centroids)
    if ~isnan(centroids(nCell,1))
        newLabel = imagePredScaled(centroids(nCell,2),centroids(nCell,1),centroids(nCell,3));
        imageAux(imagePredScaled==newLabel)=imageMaskScaled(centroids(nCell,2),centroids(nCell,1),centroids(nCell,3));
    end
end