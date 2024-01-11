%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mainvoronoiPacking
% Whole voronoi packing processing for comparing voronoi models against
% real data.
% Uses makeVoronoiPacking function
%
% User must change some paths.
%
% Inside inPath directory, the scheme should be like this one:
%
% \Path\to\imageFolder\
%         > segmentedImages
%               >SegmentedImg1.tif
%               >SegmentedImg2.tif
%         > originalImages
%               >OriginalImg1.tif
%               >OriginalImg2.tif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Path\to\imageFolder\');
outPath = uigetdir('E:\Path\to\save\processed\images');

embryosFiles=dir(inPath);
dirEmbryos = [embryosFiles.isdir];
subDirs = embryosFiles(dirEmbryos);
embryosFiles = subDirs(3:end);

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));
    embryoPath=strcat(outPath,'\',embryosFiles(nEmbryos).name);
    if exist(embryoPath,'file') ~=7
        mkdir(outPath, embryosFiles(nEmbryos).name)
    end
    
    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    for nFiles=1:length(segmentedEmbryosFiles)

        % load embryos
        originalImagePath = originalEmbryosFiles(nFiles).folder;
        segmentPath = segmentedEmbryosFiles(nFiles).folder;
        imageName=originalEmbryosFiles(nFiles).name;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'_itkws');
        fileName=strsplit(fileName{1},'.tif');
        
        [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
        [originalImage,imgInfo] = readStackTif(strcat(originalImagePath,'\',imageName));
        
        %extract scale and resize tissue.
        pixelWidth=1/unique([imgInfo.XResolution]);
        extractingSpacing = strsplit(imgInfo(1).ImageDescription, 'spacing=');
        extractingSpacing = extractingSpacing{2};
        extractingSpacing = strsplit(extractingSpacing, 'loop=');
        extractingSpacing = extractingSpacing{1};
        pixelDepth = str2num(extractingSpacing);
        
        z_Scale=pixelDepth/pixelWidth;
        pixel_Scale = pixelWidth;
        
        %Check if lumen is segmented as a enormous cell. If so, remove it.
        labelsVolume = regionprops3(segmentedImage, 'Volume');
        
        uniqueLabels = unique(segmentedImage);
        invalidLabels = uniqueLabels(labelsVolume.Volume>1000000);
        
        for invalidLabelIx = 1:length(invalidLabels)
            invalidLabel = invalidLabels(invalidLabelIx);
            segmentedImage(segmentedImage==invalidLabel)=0;
        end
        
        segmentedImage=double(segmentedImage);
        
        if exist(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\','voronoi_',fileName{1},'.mat'),'file')~=2
            if exist(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\','voronoi_',fileName{1},'.tif'),'file')~=2
                % extract basal and apical layers
                segmentedImageResized= imresize3(segmentedImage, [size(originalImage,1),size(originalImage,2),size(originalImage,3)],'nearest');
                [basalLayer,apicalLayer,~,labelledImage]=getInnerOuterLateralFromEmbryos(embryoPath,fileName{1},segmentedImageResized,z_Scale,0);
                
                %make Voronoi models
                [voronoiCyst]=makeVoronoiModels(originalImage,labelledImage,apicalLayer,basalLayer,embryoPath,fileName{1}); %output Voronoi homogeneized but reduced x4
            else
                voronoiCyst=readStackTif(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\','voronoi_',fileName{1},'.tif'));
                voronoiCyst=imresize3(double(voronoiCyst),([size(originalImage,1) size(originalImage,2) size(originalImage,3)*z_Scale]/4),'nearest');
            end
            [basalLayer,apicalLayer,lateralLayer,voronoiCyst]=getInnerOuterLateralFromEmbryos(embryoPath,fileName{1},voronoiCyst,1,0);
            voronoiCystResized=imresize3(voronoiCyst,[size(originalImage,1:2) size(originalImage,3)*z_Scale],'nearest'); %Voronoi same size embryo
            
            %select valid cells
            [numberTotalCells,validCells,numberValidCells,~]=filterValidRegion(voronoiCystResized,pixel_Scale);
            save(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\','voronoi_',fileName{1},'.mat'),'numberTotalCells','validCells','numberValidCells','basalLayer','apicalLayer','lateralLayer','voronoiCyst')
        else
            load(strcat(outPath,'\',embryosFiles(nEmbryos).name,'\','voronoi_',fileName{1},'.mat'),'numberTotalCells','validCells','numberValidCells','basalLayer','apicalLayer','lateralLayer','voronoiCyst')
        end
        %Quantify scutoids
        dilatedVx=2;
        contactThreshold=3;
        [scutoids_cells,validScutoids_cells,outerArea,innerArea,surfaceRatio3D]=calculateScutoidsAndSR(voronoiCyst,apicalLayer,basalLayer,lateralLayer,embryoPath,fileName{1},dilatedVx,contactThreshold,validCells,pixel_Scale); %input Voronoi homogeneised and reduced x4
        generalInfo= cell2table([{fileName(1)}, {surfaceRatio3D}, {numberValidCells},{numberTotalCells},{mean(scutoids_cells)},{mean(validScutoids_cells)},{outerArea},{innerArea}],'VariableNames', {'ID_Tissue', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total','Scutoids','valid_Scutoids','outer_Area','inner_Area'});
        allGeneralInfo{nFiles} = generalInfo;
        
        %export valid region and scutoids
        exportValidRegion(embryoPath,fileName{1},voronoiCyst,originalImage,validScutoids_cells,validCells)

    end
    
    summarizeAllTissuesProperties(allGeneralInfo,[],[],[],embryoPath,embryosFiles(nEmbryos).name,0);
    
end









