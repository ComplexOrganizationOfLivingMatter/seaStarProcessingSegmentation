function [numberTotalCells,validCells,numberValidCells,basalLayer,apicalLayer,lateralLayer,voronoiCyst] = getVoronoiModels(outPath,originalEmbryosFiles,segmentedEmbryosFiles)

        % load embryos
        originalImagePath = originalEmbryosFiles.folder;
        segmentPath = segmentedEmbryosFiles.folder;
        imageName=originalEmbryosFiles.name;
        segmentName=segmentedEmbryosFiles.name;
        fileName=strsplit(segmentName,'_itkws');
        fileName=strsplit(fileName{1},'.tif');
        
        [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
        [originalImage,imgInfo] = readStackTif(strcat(originalImagePath,'\',imageName));
        
        %extract scale and resize tissue.
        try
        pixelWidth=1/unique([imgInfo.XResolution]);
        extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
        extractingSpacing = extractingSpacing{2};
        extractingSpacing = strsplit(extractingSpacing, 'loop=');
        extractingSpacing = extractingSpacing{1};
        pixelDepth = str2num(extractingSpacing);
        
        z_Scale=pixelDepth/pixelWidth;
        pixel_Scale = pixelWidth;
        catch
            disp('warning there are not pixel and z scales'); 
            z_Scale=1;
            pixel_Scale = 1;
        end
        
        if isempty(z_Scale)
            z_Scale=1;
        end
        %Check if lumen is segmented as a enormous cell. If so, remove it.
        labelsVolume = regionprops3(segmentedImage, 'Volume');
        
        uniqueLabels = unique(segmentedImage);
        invalidLabels = uniqueLabels(labelsVolume.Volume>1000000);
        
        for invalidLabelIx = 1:length(invalidLabels)
            invalidLabel = invalidLabels(invalidLabelIx);
            segmentedImage(segmentedImage==invalidLabel)=0;
        end
        
        segmentedImage=double(segmentedImage);

        if exist(strcat(outPath,'\','voronoi_',fileName{1},'.mat'),'file')~=2
            if exist(strcat(outPath,'\','voronoi_',fileName{1},'.tif'),'file')~=2
                % extract basal and apical layers
                segmentedImageResized= imresize3(segmentedImage, [size(originalImage,1),size(originalImage,2),size(originalImage,3)],'nearest');
                 [~,~,~,labelledImage]=getInnerOuterLateralFromEmbryos(outPath,fileName{1},segmentedImageResized,z_Scale,0);
                
                %get Voronoi models
%                 [voronoiCyst]=getVoronoiFrom3dCentroids(originalImage,labelledImage,embryoPath,fileName{1}); %output Voronoi homogeneized but reduced x4

nCells=298;
[voronoiCyst] = getSynthethicCyst_mask(originalImage,labelledImage,outPath,fileName{1}, nCells, 0.5);

            else
                voronoiCyst=readStackTif(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\','voronoi_',fileName{1},'.tif'));
                voronoiCyst=imresize3(double(voronoiCyst),([size(originalImage,1) size(originalImage,2) size(originalImage,3)*z_Scale]/4),'nearest');
            end
            [basalLayer,apicalLayer,lateralLayer,voronoiCyst]=getInnerOuterLateralFromEmbryos(outPath,fileName{1},voronoiCyst,1,0);
            voronoiCystResized=imresize3(voronoiCyst,[size(originalImage,1:2) size(originalImage,3)*z_Scale],'nearest'); %Voronoi same size embryo
            
            %select valid cells
            [numberTotalCells,validCells,numberValidCells,~]=filterValidRegion(voronoiCystResized,pixel_Scale);
% try
%             load(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\',fileName{1},'.mat'),'validCells')
% catch
% end
            save(strcat(outPath,'\','voronoi_',fileName{1},'.mat'),'numberTotalCells','validCells','numberValidCells','basalLayer','apicalLayer','lateralLayer','voronoiCyst')
        else
            load(strcat(outPath,'\','voronoi_',fileName{1},'.mat'),'numberTotalCells','validCells','numberValidCells','basalLayer','apicalLayer','lateralLayer','voronoiCyst')
        end


end

