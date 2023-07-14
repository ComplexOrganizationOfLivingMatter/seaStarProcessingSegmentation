function summarizeAllTissuesProperties(allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures,path2save,fileName,featuresRequested)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % summarizeAllTissuesProperties
    % Function to summarize all properties
    % and store them in a table.
    %
    % INPUTS
    % allGeneralInfo: extracted using seaStarPostProcessing.m
    % allTissues: extracted using seaStarPostProcessing.m
    % totalMeanCellsFeatures: extracted using seaStarPostProcessing.m
    % totalStdCellsFeatures: extracted using seaStarPostProcessing.m
    % path2save: Path to save the table
    % fileName: table filename to be saved
    % featuresRequested: Boolean to have all variables or just the neccessary
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if featuresRequested==1
    if size(allGeneralInfo{1,1},2)==size(allGeneralInfo{end,1},2)
        allGeneralInfo = vertcat(allGeneralInfo{:});
        allTissues = vertcat(allTissues{:});
        totalMeanCellsFeatures = vertcat(totalMeanCellsFeatures{:});
        totalStdCellsFeatures = vertcat(totalStdCellsFeatures{:});
    else
        for nFile=1:size(allGeneralInfo,1)
            if size(allGeneralInfo{nFile,1},2)~=4
            allGeneralInfo{nFile,1}=allGeneralInfo{nFile,1}(:,1:4);
            totalMeanCellsFeatures{nFile, 1} = removevars(totalMeanCellsFeatures{nFile, 1}, {'Fun_apical_NumNeighs','Fun_basal_NumNeighs','Fun_lateral_NumNeighs','Fun_n3d_apicoBasalNeighbours','Fun_average_cell_wall_Area','Fun_std_cell_wall_Area'});
            totalStdCellsFeatures{nFile, 1} = removevars(totalStdCellsFeatures{nFile, 1}, {'Fun_apical_NumNeighs','Fun_basal_NumNeighs','Fun_lateral_NumNeighs','Fun_n3d_apicoBasalNeighbours','Fun_average_cell_wall_Area','Fun_std_cell_wall_Area'});
            end
        end

        allGeneralInfo = vertcat(allGeneralInfo{:});
        allTissues = vertcat(allTissues{:});
        totalMeanCellsFeatures = vertcat(totalMeanCellsFeatures{:});
        totalStdCellsFeatures = vertcat(totalStdCellsFeatures{:});
    end
        allTissues.Properties.VariableNames = cellfun(@(x) strcat('Tissue_', x), allTissues.Properties.VariableNames, 'UniformOutput', false);
        totalMeanCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('AverageCell_', x(5:end)), totalMeanCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
        totalStdCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('STDCell_', x(5:end)), totalStdCellsFeatures.Properties.VariableNames, 'UniformOutput', false);

        %%Global parameters
        globalFeatures = [allGeneralInfo(:,[1,4,3]),allTissues(:,[4,8]),allGeneralInfo(:,[2]),allTissues(:,[6,2,5,7,9,11])];
        writetable(globalFeatures, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'globalFeatures','Range','B2');
        %%Polygon distribtutions
    %     polDistributions = [allGeneralInfo(:,1),allTissues(:,12:35)];
    %     writetable(polDistributions, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'polygonDistributions','Range','B2');
       try
        %%Celullar parameters
        cellularParameter_mean = [allGeneralInfo(:,1),totalMeanCellsFeatures(:,[12,14,1,11,13,4,5,6,8,3,7,10])];
        writetable(cellularParameter_mean, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'meanCellParameters','Range','B2');

        %%Std parameters
        cellularParameter_std = [allGeneralInfo(:,1),totalStdCellsFeatures(:,[12,14,1,11,13,4,5,6,8,3,7,10])];
        writetable(cellularParameter_std, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'stdCellParameters','Range','B2');   

       catch
            %%Celullar parameters
        cellularParameter_mean = [allGeneralInfo(:,1),totalMeanCellsFeatures(:,[12,1,11,4,5,6,8,3,7,10])];
        writetable(cellularParameter_mean, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'meanCellParameters','Range','B2');

        %%Std parameters
        cellularParameter_std = [allGeneralInfo(:,1),totalStdCellsFeatures(:,[12,1,11,9,2,4,5,6,8,3,7,10])];
        writetable(cellularParameter_std, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'stdCellParameters','Range','B2');   


       end
    else
       allGeneralInfo = vertcat(allGeneralInfo{:});
       writetable(allGeneralInfo, strcat(path2save,'global_3dFeatures_', fileName,'_',date,'.xls'),'Sheet', 'meanParameters','Range','B2');
    end
   
end

