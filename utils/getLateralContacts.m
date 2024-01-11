function [neighsFiltered,totalLateralCellsArea,absoluteLateralContacts] = getLateralContacts(lateralLayer,dilatedPixels,contactThreshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    se = strel('sphere',dilatedPixels);
    cells=1:max(max(max(lateralLayer)));
    
    totalLateralCellsArea = zeros(length(cells),1);
    neighs_real=cell(length(cells),1);
    neighs2delete=cell(length(cells),1);
    percentageLateralContacts = cell(length(cells),1);
    absoluteLateralContacts = cell(length(cells),1);

    invalidRegion = lateralLayer==0;
   
    for numCell = 1 : length(cells)
        %Dilating cell of interest
        cellRegion =lateralLayer==cells(numCell);
        totalLateralCellsArea(numCell)=sum(sum(sum(cellRegion)));
        BW_dilate = imdilate(cellRegion, se);
        indxCellDilated = BW_dilate & ~invalidRegion & ~cellRegion;
%         [x,y,z]=ind2sub(size(BW_dilate),indxCellDilated);
%           shp=alphashape(x,y,z);
%           figure;plot(shp)
%         image3dInfo.cellDilated{numCell} = [uint16(x), uint16(y), uint16(z)];

        neighCellsLabels = lateralLayer(indxCellDilated);
        uniqueNeighs=unique(neighCellsLabels);
        uniqueNeighs(uniqueNeighs==0 | uniqueNeighs==cells(numCell))=[];
        neighs_real{cells(numCell), 1} = uniqueNeighs;
        
        percentageLateralContacts{numCell}=arrayfun(@(x) 100*(sum(neighCellsLabels==x)/length(neighCellsLabels)), uniqueNeighs);
        
        %%filter minimal contacts
        id2Filter = percentageLateralContacts{numCell}<contactThreshold;
        neighs2delete{cells(numCell), 1} = unique([neighs2delete{cells(numCell), 1};uniqueNeighs(id2Filter) ]);
        if ~isempty(neighs2delete{cells(numCell), 1})
            neighCellsLabels(ismember(neighCellsLabels,uniqueNeighs(id2Filter)))=[];
            uniqueNeighs=unique(neighCellsLabels);
            percentageLateralContacts{numCell}=arrayfun(@(x) 100*(sum(neighCellsLabels==x)/length(neighCellsLabels)), uniqueNeighs);
            for nCelAux = [neighs2delete{cells(numCell), 1}]'
                neighs2delete{cells(nCelAux), 1} = unique([neighs2delete{cells(nCelAux), 1};cells(numCell)]);
            end
        end
            
        absoluteLateralContacts{numCell}=arrayfun(@(x) totalLateralCellsArea(numCell)*(x/100), percentageLateralContacts{numCell});
        
    end
    
    neighsFiltered = cellfun(@(x,y) setxor(x,y),neighs_real,neighs2delete,'UniformOutput',false)';
end
