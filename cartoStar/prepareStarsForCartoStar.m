
%% prepareStarsForCartoStar
%Preprocessing code. Removes background and lumen labels if necessary, and relabels cells from 1 to max.

%%
path = '/media/pedro/6TB/jesus/SEASTAR/forceInference/tree/512/vegetal comp/';


disp(path)
dirImages = dir(strcat(path, '*.tiff'));

if ~exist(strcat(path, 'cartoStar'), 'dir')
    mkdir(strcat(path, 'cartoStar'));
end

for imIx = 1:length(dirImages)
    fileName = dirImages(imIx).name;
    labelledImage = readStackTif(strcat(path, fileName));
    
    shape = size(labelledImage);
    
    allVolumes = regionprops3(labelledImage(labelledImage>3), 'Volume');
    volume1 = regionprops3(labelledImage(labelledImage==1), 'Volume');
    volume2 = regionprops3(labelledImage(labelledImage==2), 'Volume');
    
    if max(volume1.Volume) > 2*max(allVolumes.Volume)
      labelledImage(labelledImage==1)=0;
    end
    
    if max(volume2.Volume) > 2*max(allVolumes.Volume)
      labelledImage(labelledImage==2)=0;
    end
    
%     allVolumes = regionprops3(labelledImage, 'Volume');
%     labelsToRemove = find(allVolumes.Volume>1E5);
    
%     for labelIx = 1:length(labelsToRemove)
%        labelId = labelsToRemove(labelIx);
%        labelledImage(labelledImage==labelId) = 0;
%     end
   
    
    %% RELABEL from 0 to #uniqueCells
    idLabels = unique(labelledImage);
    imgRelabel = zeros(size(labelledImage));
    for id = 1:length(idLabels)-1
        imgRelabel(labelledImage==idLabels(id+1))= id;
    end
    
    labelledImage = imgRelabel;
    
    %% clean
%     mask = labelledImage>0;
%     se = strel('sphere', 5);
%     erodedMask = imerode(mask, se);
%     CC = bwconncomp(erodedMask,6);
%     volumes = regionprops3(CC, erodedMask);
%     if size(volumes.Volume, 1)>1
%         numPixels = cellfun(@numel,CC.PixelIdxList);
%         [~,idx] = max(numPixels);
%         filtered_vol = false(size(mask));
%         filtered_vol(CC.PixelIdxList{idx}) = true;
%         labelledImage2 = labelledImage.*filtered_vol;
%         uniqueLabels2 = unique(labelledImage2);
%         labelledImage(~ismember(labelledImage, uniqueLabels2)) = 0;
%     end    
    
    fileName_timepoint = fileName(1:8);
    fileName_embryo =  fileName(10:end);
    fileName_embryo = strsplit(fileName_embryo, '.tiff');
    fileName_embryo = fileName_embryo{1};
    
    if contains(fileName_embryo, '_itkws')
        fileName_embryo = strsplit(fileName_embryo, '_itkws');
        fileName_embryo = fileName_embryo{1};
    end

    newFileName = strcat(fileName_embryo, '_', fileName_timepoint, '.tif');
    newFileNameMatPath = strcat(path, 'cartoStar/', fileName_embryo, '_', fileName_timepoint, 'validCells.mat');
    fileNameMatPath = strcat(path, fileName_embryo, '_', fileName_timepoint, 'validCells.mat');
    
    if ~exist(newFileNameMatPath, 'file')
        movefile(fileNameMatPath, newFileNameMatPath);
    end
    
    newFileNameMatFeaturesPath = strcat(path, 'cartoStar/', fileName_embryo, '_', fileName_timepoint, 'features.mat');
    fileNameMatFeaturesPath = strcat(path, fileName_timepoint, '_', fileName_embryo, 'features.mat');

    if ~exist(newFileNameMatFeaturesPath, 'file')
        movefile(fileNameMatFeaturesPath, newFileNameMatFeaturesPath);
    end
    
    if exist(strcat(path, 'cartoStar', '/', newFileName), 'file')
        delete(strcat(path, 'cartoStar', '/', newFileName))
    end
    writeStackTif(uint16(labelledImage), strcat(path, 'cartoStar', '/', newFileName));
end
    
    
    
