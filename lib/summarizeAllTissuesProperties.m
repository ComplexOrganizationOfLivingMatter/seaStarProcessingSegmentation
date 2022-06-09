function summarizeAllTissuesProperties(allGeneralInfo,allTissues,totalMeanCellsFeatures,totalStdCellsFeatures,path2save)

    allGeneralInfo = vertcat(allGeneralInfo{:});
    allTissues = vertcat(allTissues{:});
    totalMeanCellsFeatures = vertcat(totalMeanCellsFeatures{:});
    totalStdCellsFeatures = vertcat(totalStdCellsFeatures{:});
    
    allTissues.Properties.VariableNames = cellfun(@(x) strcat('Tissue_', x), allTissues.Properties.VariableNames, 'UniformOutput', false);
    totalMeanCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('AverageCell_', x(5:end)), totalMeanCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
    totalStdCellsFeatures.Properties.VariableNames = cellfun(@(x) strcat('STDCell_', x(5:end)), totalStdCellsFeatures.Properties.VariableNames, 'UniformOutput', false);
    
    %%Global parameters
    globalFeatures = [allGeneralInfo(:,[1,4,3]),allTissues(:,[4,8]),allGeneralInfo(:,[2,5,6]),allTissues(:,[6,2,5,7,9,11])];
    writetable(globalFeatures, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'globalFeatures','Range','B2');
    %%Polygon distribtutions
%     polDistributions = [allGeneralInfo(:,1),allTissues(:,12:35)];
%     writetable(polDistributions, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'polygonDistributions','Range','B2');
    %%Celullar parameters
    cellularParameter_mean = [allGeneralInfo(:,1),totalMeanCellsFeatures(:,[12,14,15,17,18,19,1,11,13,16,end,4,5,6,8,3,7,10])];
    writetable(cellularParameter_mean, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'meanCellParameters','Range','B2');

    %%Std parameters
    cellularParameter_std = [allGeneralInfo(:,1),totalStdCellsFeatures(:,[12,14,15,17,18,19,1,11,13,16,end,4,5,6,8,3,7,10])];
    writetable(cellularParameter_std, [path2save,'global_3dFeatures_' date '.xls'],'Sheet', 'stdCellParameters','Range','B2');   
end

