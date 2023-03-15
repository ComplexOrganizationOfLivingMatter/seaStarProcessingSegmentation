function [holeArea,holesOnImage] = extractEmbryoArea(labelledImage)



 %binarize
binaryLabels = (labelledImage>0);

newImage=zeros(size(binaryLabels,1:2));

[x, y, ~] = ind2sub(size(labelledImage), find(labelledImage>0));

for nX=1:size(x)
    newImage(x(nX),y(nX))=1;
end


newImageFilled=imfill(newImage,'holes');
holesOnImage=bwlabeln(newImageFilled-newImage);

oneCell3dFeatures = regionprops(holesOnImage>0, 'Area');

holeArea= max([oneCell3dFeatures.Area]);
% holeArea=oneCell3dFeatures * pixelScale^2;

end

