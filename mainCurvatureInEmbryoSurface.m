function [] = mainCurvatureInEmbryoSurface(condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mainCurvatureInEmbryoSurface
% Main code for curvature analysis of the SeaStar embryo.
% Coordinates of outter layer cell centroids and inner layer
% cell centroids are needed.
% Inner layer and outer layer can be
% extracted using getInnerOuterLateralFromEmbryos
% An excell file with estimated info of all 3 principal axes of the embryo
% are needed as well as estimated mean cell height. This was done
% manually using FIJI.
% 
% inPath directory should have a folder for each movie. Inside those
% folders, a folder for each one of the 3 stages.
% Then, inside those folders, all timepoints (.tif) and a .mat file with
% relevant information of the original images. This can be extracted using
% mainSegmentation.m
% 
% EXAMPLE:
% 
% D:\Path\to\curvatureAnalysis\data    
%   excelFile.xls
%   > movie1
%       originalImageName.mat
%       > stage128
%              timepoint1.tif
%              timepoint2.tif
%              ...
%       > stage256
%              ...
%       > stage512
%              ...
% > movie2
%       ...
% > movie3
%       ...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


addpath(genpath('src'))
addpath(genpath('lib'))

close all

inPath = uigetdir('D:\Path\to\curvatureAnalysis\data');

% ui to select table
[excelTableName, excelPath] = uigetfile('D:\Path\to\curvatureAnalysis\data\', 'Select excel table');
disp(excelTableName)
excelPath = strcat(excelPath, excelTableName);

%% Load table
excelTable = readtable(excelPath);
allGeneralInfo=excelTable.ID_Tissue;
allApicalAxis=[excelTable.Major_Axis/2 excelTable.Major_Axis_2/2 excelTable.Minor_Axis/2];
allCellHeight=excelTable.Avg_CellHeight;
allBasalAxis=[(excelTable.Major_Axis/2)-allCellHeight (excelTable.Major_Axis_2/2)-allCellHeight (excelTable.Minor_Axis/2)-allCellHeight];
allCurvatureInputs={};

embryosFiles=dir(inPath);
dirEmbryos = [embryosFiles.isdir];
subDirs = embryosFiles(dirEmbryos);
embryosFiles = subDirs(3:end);

if isnumeric(condition)
    condition=num2str(condition);
end

maxFile=0;

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\',condition,'\*.tif*'));
    originalImageName=strsplit(embryosFiles(nEmbryos).name,'_2');
    originalImageName=strcat('2',originalImageName{2});
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\',originalImageName,'.mat'));
    
    load(strcat(originalEmbryosFiles.folder,'\',originalEmbryosFiles.name),'z_Scale','pixel_Scale');
    
    for nFiles=1:length(segmentedEmbryosFiles)
        
        segmentPath = segmentedEmbryosFiles(nFiles).folder;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'.tif');
        if exist(fullfile(segmentPath, strcat(fileName{1},'_curvatureAB.mat')))==0
            
            [segmentedImage] = readStackTif(strcat(segmentPath,'\',segmentName));
            [apicalLayer,basalLayer,~,~]=getInnerOuterLateralFromEmbryos(segmentPath,fileName{1},double(segmentedImage),z_Scale,0);% inverse apical and basal layers
            
            %% Calculate centroids of apical and basal validRegions
            apicalCentroids=regionprops3(apicalLayer,'Centroid');
            basalCentroids=regionprops3(basalLayer,'Centroid');
            
            apicalCentroids=apicalCentroids.Centroid;
            [indexEmpty,~]=find(isnan(apicalCentroids(:,3)));
            apicalCentroids(indexEmpty,:)=[];
            
            basalCentroids=basalCentroids.Centroid;
            [indexEmpty,~]=find(isnan(basalCentroids(:,3)));
            basalCentroids(indexEmpty,:)=[];
            
            %% define embryo radii
            apicalA=allApicalAxis(maxFile+nFiles,1);
            apicalB=allApicalAxis(maxFile+nFiles,2);
            apicalC=allApicalAxis(maxFile+nFiles,3);
            
            basalA=allBasalAxis(maxFile+nFiles,1);
            basalB=allBasalAxis(maxFile+nFiles,2);
            basalC=allBasalAxis(maxFile+nFiles,3);
            
            generalInfo=table(zeros(length(apicalCentroids)-1,1),zeros(length(apicalCentroids)-1,1),zeros(length(apicalCentroids)-1,1),zeros(length(apicalCentroids)-1,1),zeros(length(apicalCentroids)-1,1),'VariableNames',{'anisotropyCurvatureRatio', 'R1Apical','R2Apical','R1Basal', 'R2Basal'});

            for nCentroid=2:length(apicalCentroids) %remove centroid row 1 because it is the invalid region
                            
            xA=apicalCentroids(nCentroid,2)*pixel_Scale; 
            yA=apicalCentroids(nCentroid,1)*pixel_Scale;
            zA=apicalCentroids(nCentroid,3)*pixel_Scale;
            
            xB=basalCentroids(nCentroid,2)*pixel_Scale;
            yB=basalCentroids(nCentroid,1)*pixel_Scale;
            zB=basalCentroids(nCentroid,3)*pixel_Scale;
            
            %% calculate curvatures
           
            [R1Apical,R2Apical,k1Apical,k2Apical] = calculateCurvatureInEllipsoidCoordinate(xA,yA,zB,apicalA,apicalB,apicalC);
            
            [R1Basal,R2Basal,k1Basal,k2Basal] = calculateCurvatureInEllipsoidCoordinate(xB,yB,zA,basalA,basalB,basalC);
            
            
            SR1=R1Apical/R1Basal;
            SR2=R2Apical/R2Basal;
            
            anisotropyCurvatureRatio=(SR2/SR1)-1;
            
            if anisotropyCurvatureRatio<0
                anisotropyCurvatureRatio=(SR1/SR2)-1;           
            end

            generalInfo.anisotropyCurvatureRatio(nCentroid-1)=anisotropyCurvatureRatio;
            generalInfo.R1Apical(nCentroid-1)=R1Apical;
            generalInfo.R2Apical(nCentroid-1)=R2Apical;
            generalInfo.R1Basal(nCentroid-1)=R1Basal;
            generalInfo.R2Basal(nCentroid-1)=R2Basal;
         
            end
            
            meanCurvFeatures=[mean(generalInfo.anisotropyCurvatureRatio) mean(generalInfo.R1Apical) mean(generalInfo.R2Apical) mean(generalInfo.R1Basal) mean(generalInfo.R2Basal)];
            tissueGeneralInfo{maxFile+nFiles,2} = meanCurvFeatures;
            save(fullfile(segmentPath, strcat(fileName{1},'_curvatureAB.mat')), 'generalInfo','meanCurvFeatures');
            writetable(generalInfo, strcat(segmentPath,'\',fileName{1},'_individual_curvatureAnalysis_', condition,'_',date,'.xls'),'Sheet', 'rawData','Range','B2');
        else
            load(fullfile(segmentPath, strcat(fileName{1},'_curvatureAB.mat')), 'meanCurvFeatures');
            tissueGeneralInfo{maxFile+nFiles,2} = meanCurvFeatures;     
        end
    end
    
    maxFile=nEmbryos*length(segmentedEmbryosFiles);
    
    
end

% allGeneralInfo = vertcat(allGeneralInfo{:});
allCurvatureInputs = vertcat(tissueGeneralInfo{:,2});
curvatureTable=table(allGeneralInfo(:),allCurvatureInputs(:,1),allCurvatureInputs(:,2),allCurvatureInputs(:,3),allCurvatureInputs(:,4),allCurvatureInputs(:,5),'VariableNames',{'ID_Tissue','anisotropyCurvatureRatio', 'R1Apical','R2Apical','R1Basal', 'R2Basal'});
writetable(curvatureTable, strcat(inPath,'\global_curvatureAnalysis_', condition,'_',date,'.xls'),'Sheet', 'curvatureParameters','Range','B2');
end


