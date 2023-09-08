function [meanFeatures,stdFeatures, tissue3dFeatures] = convertPixelsToMicrons(meanFeatures,stdFeatures, tissue3dFeatures, pixelScale)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    volumeSubstring={'Volume','volume'};
    areaSubstring={'Area', 'area'};
    lengthSubstring={'length','Length','height','Height'};
    heightSubstring={'height','Height'};


    %% VolumeFeatures
    CellsFeaturesVolumeIndexs = contains(meanFeatures.Properties.VariableNames,volumeSubstring);
    TissueFeaturesVolumeIndexs = contains(tissue3dFeatures.Properties.VariableNames,"Volume");

    meanFeatures(:,CellsFeaturesVolumeIndexs) = splitvars(table(table2array(meanFeatures(:,CellsFeaturesVolumeIndexs)) * pixelScale^3),1);
    stdFeatures(:,CellsFeaturesVolumeIndexs) = splitvars(table(table2array(stdFeatures(:,CellsFeaturesVolumeIndexs)) * pixelScale^3),1);
    tissue3dFeatures(:,TissueFeaturesVolumeIndexs) = splitvars(table(table2array(tissue3dFeatures(:,TissueFeaturesVolumeIndexs)) * pixelScale^3),1);
%     lumen3dFeatures(:,TissueFeaturesVolumeIndexs) = splitvars(table(table2array(lumen3dFeatures(:,TissueFeaturesVolumeIndexs)) * pixelScale^3),1);
%     hollowTissue3dFeatures(:,TissueFeaturesVolumeIndexs) = splitvars(table(table2array(hollowTissue3dFeatures(:,TissueFeaturesVolumeIndexs)) * pixelScale^3),1);
% 
    %% Area Features
    CellsFeaturesAreaIndexs = contains(meanFeatures.Properties.VariableNames,areaSubstring);
    TissueFeaturesAreaIndexs = contains(tissue3dFeatures.Properties.VariableNames,areaSubstring);

    meanFeatures(:,CellsFeaturesAreaIndexs) = splitvars(table(table2array(meanFeatures(:,CellsFeaturesAreaIndexs)) * pixelScale^2),1);
    stdFeatures(:,CellsFeaturesAreaIndexs) = splitvars(table(table2array(stdFeatures(:,CellsFeaturesAreaIndexs)) * pixelScale^2),1);
    tissue3dFeatures(:,TissueFeaturesAreaIndexs) = splitvars(table(table2array(tissue3dFeatures(:,TissueFeaturesAreaIndexs)) * pixelScale^2),1);
%     lumen3dFeatures(:,TissueFeaturesAreaIndexs) = splitvars(table(table2array(lumen3dFeatures(:,TissueFeaturesAreaIndexs)) * pixelScale^2),1);
%     hollowTissue3dFeatures(:,TissueFeaturesAreaIndexs) = splitvars(table(table2array(hollowTissue3dFeatures(:,TissueFeaturesAreaIndexs)) * pixelScale^2),1);

    %% Length Features
    CellsFeaturesLengthIndexs = contains(meanFeatures.Properties.VariableNames,lengthSubstring);
    TissueFeaturesLengthIndexs = contains(tissue3dFeatures.Properties.VariableNames,lengthSubstring);

    meanFeatures(:,CellsFeaturesLengthIndexs) = splitvars(table(table2array(meanFeatures(:,CellsFeaturesLengthIndexs)) * pixelScale),1);
    stdFeatures(:,CellsFeaturesLengthIndexs) = splitvars(table(table2array(stdFeatures(:,CellsFeaturesLengthIndexs)) * pixelScale),1);
    tissue3dFeatures(:,TissueFeaturesLengthIndexs) = splitvars(table(table2array(tissue3dFeatures(:,TissueFeaturesLengthIndexs)) * pixelScale),1);
%     lumen3dFeatures(:,TissueFeaturesLengthIndexs) = table(table2array(lumen3dFeatures(:,TissueFeaturesLengthIndexs)) * pixelScale);
%     hollowTissue3dFeatures(:,TissueFeaturesLengthIndexs) = table(table2array(hollowTissue3dFeatures(:,TissueFeaturesLengthIndexs)) * pixelScale);

end

