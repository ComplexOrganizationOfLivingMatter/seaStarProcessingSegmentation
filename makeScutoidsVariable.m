
inPath=uigetdir('data');

featureFiles=dir(fullfile(inPath,'**','morphological3dFeatures.mat'));

for nFiles=1:size(featureFiles,1)
    load(fullfile(featureFiles(nFiles).folder,'morphological3dFeatures.mat'));
    a=zeros(length(cellularFeaturesValidCells.ID_Cell),1);
    scutoids=table(cellularFeaturesValidCells.ID_Cell,a,'VariableNames',{'ID_Cell','Scutoids'});
    
    save(fullfile(featureFiles(nFiles).folder,'scutoids.mat'), 'scutoids');
    
    
end
