function validValues = normalizeFeaturesData(path, normalizationType)
    
    treeDir = dir(path);
    validValues = [];
    
    if strcmp(normalizationType, 'All') 
        textToContain = '';
    else
        textToContain = normalizationType;
    end
    
    
    for treeIx = 3:length(treeDir)
        treeId = treeDir(treeIx).name;
        if contains(treeId, textToContain)
            folderPath = strcat(path, treeId, '/cartoStar/');
            folderDir = dir(strcat(folderPath, '*features.mat'));

            for fileIx = 1:length(folderDir)

                    %% load and process foambryo info
                    fileName = folderDir(fileIx).name;
                    fileName = strsplit(fileName, 'features.mat');
                    fileName = fileName{1};
                    load(strcat(folderPath, fileName, 'features.mat'))
                    load(strcat(folderPath, fileName, 'validCells.mat'))

                    validValues = [validValues; newCells3dFeatures];
            end
        end
        
    end
    
    

end