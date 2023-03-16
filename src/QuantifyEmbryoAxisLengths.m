function [embryoAxisLength, allAxis]=QuantifyEmbryoAxisLengths(segmentedImage,originalImage,z_Scale)

segmentedImage=imresize3(segmentedImage,[size(originalImage,1) size(originalImage,2) size(originalImage,3)*z_Scale],'nearest');
index=0;
allAxis=[];
for zIndex=1:size(segmentedImage,3)
    axisLengths=regionprops(segmentedImage(:,:,zIndex)>1,"MajorAxisLength","MinorAxisLength");
    
    if isempty(axisLengths)==0
        index=index+1;
        allAxis(index,1)=zIndex;
        allAxis(index,2)=axisLengths.MajorAxisLength;
        allAxis(index,3)=axisLengths.MinorAxisLength;
    end
end


IndexSemiSphere=find(allAxis(:,2)==max(allAxis(:,2)));

zRadius=allAxis(max(IndexSemiSphere),1) - allAxis(1,1);

zDiameter=zRadius*2;

embryoAxisLength=[allAxis(max(IndexSemiSphere),2:3) zDiameter];

OuterCentroid=regionprops(segmentedImage(:,:,allAxis(1,1))>1,'Centroid');
InnerCentroid=regionprops(segmentedImage(:,:,allAxis(max(IndexSemiSphere),1))>1,'Centroid');

centroid1=[OuterCentroid(2).Centroid allAxis(1,1)];
centroid2=[InnerCentroid.Centroid allAxis(max(IndexSemiSphere),1)];

zRadius2=pdist2(centroid1,centroid2);
end