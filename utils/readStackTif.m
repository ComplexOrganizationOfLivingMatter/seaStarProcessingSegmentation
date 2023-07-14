function [loadedImage, infoImage] = readStackTif(fileName)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % readStackTif
    % Function to read tif file stack images.
    % INPUTS:
    % fileName: full path (including fileName and '.tif')
    % OUTPUTS:
    % loadedImage: stack image
    % infoImage: Image metadata
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    infoImage = imfinfo(fileName);
    loadedImage = uint16(zeros(infoImage(1).Height,infoImage(1).Width,size(infoImage,1)));
    for nZ = 1:size(infoImage,1)
        loadedImage(:,:,nZ) = imread(fileName,nZ);
    end
end
