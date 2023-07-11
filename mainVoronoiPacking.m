
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');
outPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\animalEmbryos\20200114_pos1');

embryosFiles=dir(inPath);
dirEmbryos = [embryosFiles.isdir];
subDirs = embryosFiles(dirEmbryos); 
embryosFiles = subDirs(3:end);

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));
%     segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\512\*.tif*'));
%     originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\',embryosFiles(nEmbryos).name,'.mat'));
 embryoPath=strcat(outPath,'\',embryosFiles(nEmbryos).name);    
    if exist(embryoPath,'file') ~=7
        mkdir(outPath, embryosFiles(nEmbryos).name)
    end

    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    for nFiles=1:length(segmentedEmbryosFiles)

        originalImagePath = originalEmbryosFiles(nFiles).folder;
        segmentPath = segmentedEmbryosFiles(nFiles).folder;
        imageName=originalEmbryosFiles(nFiles).name;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'_itkws');
        fileName=strsplit(fileName{1},'.tif');
        
        %extract scale and resize tissue.
        [~,~,~,labelledImage,z_Scale,pixel_Scale,originalImage] = seaStarOnlyExtractValidCells(originalImagePath,segmentPath,imageName,segmentName);        
        
        %make Voronoi models
        [voronoiCyst]=makeVoronoiModels(originalImage,labelledImage,embryoPath,fileName{1}); %output Voronoi homogeneized but reduced x4
        [basalLayer,apicalLayer,lateralLayer,voronoiCyst]=resizeTissue(embryoPath,fileName{1},voronoiCyst,1,0);
        voronoiCystResized=imresize3(voronoiCyst,[size(originalImage,1:2) size(originalImage,3)*z_Scale],'nearest'); %Voronoi same size embryo
        
        %select valid cells
        [numberTotalCells,validCells,numberValidCells]=filterValidRegion(voronoiCystResized,pixel_Scale);
        
        %Quantify scutoids
        dilatedVx=2;
        contactThreshold=1;
        [scutoids_cells,validScutoids_cells,outerArea,innerArea,surfaceRatio3D]=calculateScutoidsAndSR(voronoiCyst,apicalLayer,basalLayer,lateralLayer,embryoPath,fileName{1},dilatedVx,contactThreshold,validCells,pixel_Scale); %input Voronoi homogeneised and reduced x4
        generalInfo= cell2table([{fileName(1)}, {surfaceRatio3D}, {numberValidCells},{numberTotalCells},{mean(scutoids_cells)},{mean(validScutoids_cells)},{outerArea},{innerArea}],'VariableNames', {'ID_Tissue', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total','Scutoids','valid_Scutoids','outer_Area','inner_Area'});
        allGeneralInfo{nFiles} = generalInfo;

        %export valid region and scutoids
        exportValidRegion(embryoPath,fileName{1},voronoiCyst,originalImage,validScutoids_cells,validCells)
        
        
    end
    
    summarizeAllTissuesProperties(allGeneralInfo,[],[],[],embryoPath,embryosFiles(nEmbryos).name,0);
    
end









