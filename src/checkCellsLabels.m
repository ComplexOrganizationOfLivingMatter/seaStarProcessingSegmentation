%% split cells with the same label
actualImg = bwlabeln(segmentedImage==255);
newCell=255;
for nCell=1:max(max(max(actualImg)))
    [x, y, z] = ind2sub(size(segmentedImage), find(actualImg==nCell));
    for nIndex=1:size(x,1)
        segmentedImage(x(nIndex,1),y(nIndex,1),z(nIndex,1))=1;
    end
    newCell=newCell+1;
end

%% Check if all cels have an unique label and each one is one object
for nCell=1:max(max(max(segmentedImage)))
    actualImg = bwlabeln(segmentedImage==nCell);
    oneCell3dFeatures = regionprops3(actualImg, 'Volume');
    if size(oneCell3dFeatures,1)>1
        disp(nCell)
    end
end

%% Replace label cells only in some slice
for zIndex=87:119
   actualImg=segmentedImage(:,:,zIndex);
   actualImg(actualImg==43)=180;
   segmentedImage(:,:,zIndex)=actualImg;
end
