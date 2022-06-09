function [loadedImage, infoImage] = readStackTif(fileName)

    infoImage = imfinfo(fileName);
    loadedImage = uint8(zeros(infoImage(1).Height,infoImage(1).Width,size(infoImage,1)));
    for nZ = 1:size(infoImage,1)
        loadedImage(:,:,nZ) = imread(fileName,nZ);
    end
end