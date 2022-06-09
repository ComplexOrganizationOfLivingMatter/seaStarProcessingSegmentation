function labelledSequenceOnlyValidCells(labelledImage,outPath,noValidCells)

    if exist(fullfile(outPath, 'labelledSequenceValidCells')) ~=7
        mkdir(outPath, 'labelledSequenceValidCells')
    end
    
    if size(dir(strcat(outPath,'/','labelledSequenceValidCells')),1)<3
        outputDir = strcat(outPath,'/','labelledSequenceValidCells');

        if exist('colours')==0
            colours=rand(size(unique(labelledImage),1)-1,3);
        end
        
        for indexCell=1:length(noValidCells)
            labelledImage(labelledImage==noValidCells(indexCell,1))=0;
        end

        exportAsImageSequence(labelledImage, outputDir, colours);
    end
    
end