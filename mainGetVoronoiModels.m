%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mainGetVoronoiModels
% Whole voronoi packing processing for comparing voronoi models against
% real data.
% Uses GetVoronoiModels function
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

% Select which type of Voronoi model you want to make from embryos
% segmented regions.
[indx,~] = listdlg('PromptString',{'Select a mode'},'SelectionMode','single','ListString',{'3D Centroids','RandomSeeds','SegmentVoronoi'});

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));
    embryoPath=strcat(outPath,'\',embryosFiles(nEmbryos).name);
    if exist(embryoPath,'file') ~=7
        mkdir(outPath, embryosFiles(nEmbryos).name)
    end
    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    for nFiles=1:length(segmentedEmbryosFiles)
        %Get Voronoi From imaged embryo
        [numberTotalCells,validCells,numberValidCells,innerLayer,outerLayer,lateralLayer,voronoiCyst,originalImage,fileName,pixel_Scale] = getVoronoiModels(embryoPath,originalEmbryosFiles(nFiles),segmentedEmbryosFiles(nFiles),indx);
        
        %Quantify scutoids
        dilatedVx=2;
        contactThreshold=1;
        disp(numberTotalCells)
        [scutoids_cells,validScutoids_cells,outerArea,innerArea,surfaceRatio3D]=calculateScutoidsAndSR(voronoiCyst,innerLayer,outerLayer,lateralLayer,embryoPath,fileName{1},dilatedVx,contactThreshold,validCells,pixel_Scale); %input Voronoi homogeneised and reduced x4
        generalInfo= cell2table([{fileName(1)}, {surfaceRatio3D}, {numberValidCells},{numberTotalCells},{mean(scutoids_cells)},{mean(validScutoids_cells)},{outerArea},{innerArea}],'VariableNames', {'ID_Tissue', 'SurfaceRatio3D_areas', 'NCells_valid','NCells_total','Scutoids','valid_Scutoids','outer_Area','inner_Area'});
        allGeneralInfo{nFiles} = generalInfo;
        
        %export valid region and scutoids
        exportValidRegion(embryoPath,fileName{1},voronoiCyst,originalImage,validScutoids_cells,validCells)
    end
    
    summarizeAllTissuesProperties(allGeneralInfo,[],[],[],embryoPath,embryosFiles(nEmbryos).name,0);

end









