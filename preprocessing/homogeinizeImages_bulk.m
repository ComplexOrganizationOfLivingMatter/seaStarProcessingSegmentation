%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% homogeinizeImages_bulk
% Main code for scaling all 3 dimensions of the image
% so it can be seen with the correct proportions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rgStackPath = strcat('D:\pathTo\RawImage\stacks\');
savePath = strcat('D:\pathTo\save\images\');

rgStackDir = dir(strcat(rgStackPath, '*.tif'));

for index = 1:size(rgStackDir, 1)

    fileName = rgStackDir(index).name;
    fileName = strsplit(fileName, '.tif');
    fileName = fileName{1};
    disp(fileName);
    
    try
        [originalImage, imgInfo] = readStackTif(strcat(rgStackPath, fileName, '.tif'));
    catch
        [originalImage, imgInfo] = readStackTif(strcat(rgStackPath, fileName, '.tif.tif'));
    end
    
    %% Extract pixel-micron relation
    xResolution = imgInfo(1).XResolution;
    yResolution = imgInfo(1).YResolution;
    extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
    extractingSpacing = extractingSpacing{2};
    extractingSpacing = strsplit(extractingSpacing, 'loop=');
    extractingSpacing = extractingSpacing{1};
    z_pixel = str2num(extractingSpacing);
    x_pixel = 1/xResolution;
    y_pixel = 1/yResolution;

    %% Get original image size
    shape = size(originalImage);

    %% Make homogeneous
    numRows = shape(1);
    numCols = shape(2);
    numSlices = round(shape(3)*(z_pixel/x_pixel));

    originalImage = imresize3(originalImage, [numRows, numCols, numSlices]);

    homoOriginalReduced = imresize3(originalImage, 0.3);

    writeStackTif(homoOriginalReduced, strcat(savePath, fileName, '.tif'));

end
