clear all

inPath=uigetdir('data');
outPath=uigetdir('data');

featureFiles=dir(fullfile(inPath,'**','morphological3dFeatures.mat'));
allScutoids=table();
allNoScutoids=table();
for nFiles=1:size(featureFiles,1)
    
    fileName=featureFiles(nFiles).folder;
    fileName=split(fileName,'\');
    
    load(strcat(featureFiles(nFiles).folder,'\morphological3dFeatures.mat'),'cells3dFeatures','cellularFeaturesValidCells')
    load(strcat(featureFiles(nFiles).folder,'\scutoids.mat'),'scutoids')
    load(strcat(featureFiles(nFiles).folder,'\',fileName{end},'.mat'),'pixel_Scale')
    
    [cells3dFeatures,~,~] = convertPixelsToMicrons(cells3dFeatures,table([]), table([]), pixel_Scale);
    
    validCellsIndxs=~ismember(cellularFeaturesValidCells.ID_Cell,scutoids.ID_Cell);
    scutoidsIndxs=ismember(scutoids.ID_Cell,cellularFeaturesValidCells.ID_Cell);
    
    emptyRow= table(zeros(sum(validCellsIndxs),1));
    emptyRow2= table(zeros(sum(validCellsIndxs),1));
    emptyRow=renamevars(emptyRow,"Var1","ID_Cell");
    emptyRow.ID_Cell=cellularFeaturesValidCells.ID_Cell(validCellsIndxs);
    emptyRow2=renamevars(emptyRow2,"Var1","Scutoids");
    
    newScutoids=scutoids(scutoidsIndxs,:);
    scutoids=[newScutoids;[emptyRow emptyRow2]];
    
%         scutoids((size(cells3dFeatures,1)+1):end,:) = [];
%         scutoids.Scutoids=newScutoids;
%     scutoids.ID_Cell=cellularFeaturesValidCells.ID_Cell(newIndxs);
    
   
    newCells3dFeatures =[cells3dFeatures scutoids(:,2)];
    newCells3dFeatures = removevars(newCells3dFeatures, 'EquivDiameter');
    newCells3dFeatures = removevars(newCells3dFeatures, {'average_cell_wall_Area','std_cell_wall_Area'});
    %        save(strcat(featureFiles(nFiles).folder,'scutoids.mat'),'scutoids')
    newCells3dFeaturesScutoids=newCells3dFeatures(newCells3dFeatures.Scutoids==1,:);
    newCells3dFeaturesNoScutoids=newCells3dFeatures(newCells3dFeatures.Scutoids==0,:);
    newCells3dFeatures = [ newCells3dFeaturesScutoids;  newCells3dFeaturesNoScutoids];
    save(strcat(outPath,'\',fileName{end},'.mat'),'newCells3dFeatures')
    writetable(newCells3dFeatures, [outPath,'\local_3dFeatures_' fileName{7} '_' date '.xls'],'Sheet', strcat(fileName{5},'_',num2str(nFiles)),'Range','B2');
    
    allScutoids=[allScutoids; newCells3dFeaturesScutoids];
    allNoScutoids=[allNoScutoids; newCells3dFeaturesNoScutoids];
end

writetable(allScutoids, [outPath,'\local_3dFeatures_' fileName{5} '_' fileName{6} '_' date '.xls'],'Sheet', 'Scutoids','Range','B2');
writetable(allNoScutoids, [outPath,'\local_3dFeatures_' fileName{5} '_' fileName{6} '_' date '.xls'],'Sheet', 'No Scutoids','Range','B2');

