%% Images 3D

function SeaStar3DNucleiSegmentation(inPath, imageName, outputPath, outputName, scale)

    if nargin < 4
        scale = 1;
    end

    [originalImage,imgInfo] = readStackTif(strcat(inPath,'\',imageName));
    
    
%     fileName=strsplit(imageName,'_2');
%     fileName=strcat('2',fileName{2});
    fileName=erase(imageName,'.tif');
    
%     if exist(strcat('pixelMicronsFactors/',fileName,'.mat'),'file')==0
%     
%         pixelWidth=1/unique([imgInfo.XResolution]);
%         
%         extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
%         extractingSpacing = extractingSpacing{2};
%         extractingSpacing = strsplit(extractingSpacing, 'loop=');
%         extractingSpacing = extractingSpacing{1};
%         pixelDepth = str2num(extractingSpacing);
%         
%         z_Scale=pixelDepth/pixelWidth;
%         pixel_Scale = unique([imgInfo.XResolution]);
%         
%         save(strcat(outputPath,'/pixelMicronsFactors/',fileName),'z_Scale','pixel_Scale');
%     end
    
    originalImage2 = imresize3(originalImage, "Scale", scale, "Method", "nearest");

    
    BW = imbinarize(originalImage2, "global");
    binaryImage = imfill(BW, 'holes');

    binaryImage = bwareaopen(binaryImage, 10, 26);
    
    se = strel('sphere', 3);
    labeledImage = bwlabeln(binaryImage, 26); %Conectivity = 26
    labeledImage2 = labeledImage;
    
    uniqueLables = unique(labeledImage); 
    
    for cellIx = 2:length(uniqueLables) % 1 = image background
        cellId = uniqueLables(cellIx);
        if size(unique(labeledImage2 == cellId), 1) == 2
            cellProps = regionprops3(labeledImage2 == cellId, "Volume", "Centroid");
            labeledImage2(labeledImage2 == cellId) = 0; 
    
            if cellProps.Volume < 120
                continue
            end
    
            y = round(cellProps.Centroid(1));
            x = round(cellProps.Centroid(2));
            z = round(cellProps.Centroid(3));
            labeledImage2(x, y, z) = cellId;
        end
    end
    dilatedImage2 = imdilate(labeledImage2, se);
    
    dilatedImage2 = imresize3(dilatedImage2,[size(originalImage)], "Method", "nearest");
    
    
    
    
    writeStackTif(double(dilatedImage2), strcat(outputPath,'/', outputName));

end