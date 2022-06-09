function [basalLayer] = getLayerFrom3DImage(labelledImage,zDirection)
%GETBASALFROM3DIMAGE Summary of this function goes here
%   Detailed explanation goes here
basalLayer=zeros(size(labelledImage));

totalXY=[];

for nZ=zDirection
    if max(max(labelledImage(:,:,nZ))) > 0
        
    [x,y]=find(labelledImage(:,:,nZ)>0);
    if isempty(totalXY)
        basalLayer(:,:,nZ)=labelledImage(:,:,nZ);
        totalXY=[totalXY;[x y]];
        continue
    end
    XYinSlice= setdiff([x y],totalXY, 'rows');
    totalXY=unique([totalXY;[x y]], 'rows');
    actualImg= labelledImage(:,:,nZ);
    
    xyIndex= sub2ind(size(actualImg),XYinSlice(:,1),XYinSlice(:,2));

    actualBasalLayer=basalLayer(:,:,nZ);
    actualBasalLayer(xyIndex)=actualImg(xyIndex);
    basalLayer(:,:,nZ)= actualBasalLayer;
    end
end

end

