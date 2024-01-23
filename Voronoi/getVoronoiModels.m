function [numberTotalCells,validCells,numberValidCells,innerLayer,outerLayer,lateralLayer,voronoiEmbryoResized,originalImage,fileName,pixel_Scale] = getVoronoiModels(outPath,originalEmbryosFiles,segmentedEmbryosFiles,indx)

        %% load embryos
        originalImagePath = originalEmbryosFiles.folder;
        segmentPath = segmentedEmbryosFiles.folder;
        imageName=originalEmbryosFiles.name;
        segmentName=segmentedEmbryosFiles.name;
        fileName=strsplit(segmentName,'_itkws');
        fileName=strsplit(fileName{1},'.tif');
        
        [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
        [originalImage,imgInfo] = readStackTif(strcat(originalImagePath,'\',imageName));
        
        %% extract scale.
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
                %% resize tissue 
                segmentedImageResized= imresize3(segmentedImage, [size(originalImage,1),size(originalImage,2),size(originalImage,3)*z_Scale],'nearest');
                
                %% get Voronoi models
                switch indx
                    case 1
                        [voronoiEmbryo]=getVoronoiFrom3dCentroids(segmentedImageResized,outPath,fileName{1}); %output Voronoi homogeneized but reduced x4
                        model='3D_Centroids';
                    case 2
                        nCells=182;
                        [voronoiEmbryo] = getSynthethicEmbryo_mask(segmentedImageResized,outPath,fileName{1}, nCells, 0.5);
                        model='Random';
                    case 3
                        [voronoiEmbryo]=getSegmentVoronoiFromApicalBasal(segmentedImageResized,outPath,fileName{1}); %output Voronoi homogeneized but reduced x4    
                        model='Segment Voronoi';
                end
            
            %% get inner, outer and lateral layers.    
            voronoiEmbryoResized=imresize3(voronoiEmbryo,size(voronoiEmbryo)*4,'nearest'); %Voronoi same size embryo
            [innerLayer,outerLayer,lateralLayer,~]=getInnerOuterLateralFromEmbryos(outPath,fileName{1},voronoiEmbryoResized,1,0);
            
            %% select valid region
            [numberTotalCells,validCells,numberValidCells,~]=filterValidRegion(voronoiEmbryoResized,pixel_Scale);

            %% save voronoi model, layers, valid region.
            save(strcat(outPath,'\','voronoi_',fileName{1},'.mat'),'numberTotalCells','validCells','numberValidCells','innerLayer','outerLayer','lateralLayer','voronoiEmbryoResized','model')
        else
            load(strcat(outPath,'\','voronoi_',fileName{1},'.mat'),'numberTotalCells','validCells','numberValidCells','innerLayer','outerLayer','lateralLayer','voronoiEmbryoResized')
        end


end

