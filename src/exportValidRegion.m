function exportValidRegion(path2save,fileName,labelledImage,originalImage,valid_scutoids,validCells)



noValidCells=setdiff(labelledImage,validCells);
noValidCells(noValidCells==0)=[];
    if ismember(1,validCells)
        labelledImage(labelledImage==1)=max(max(max(labelledImage)))+1;
        [index]=find(validCells==1);
        validCells(index)=max(max(max(labelledImage)))+1;
    end
for nCell=1:length(noValidCells)
    labelledImage(labelledImage==noValidCells(nCell))=1;   
end

resizedLabelledImage=imresize3(labelledImage,size(originalImage),'nearest');
writeStackTif(uint16(resizedLabelledImage), strcat(path2save,'\','resized_',fileName,'.tif'));

for nCell=1:length(valid_scutoids)
    if valid_scutoids(nCell)==0
        resizedLabelledImage(resizedLabelledImage==validCells(nCell))=1;
    end
end

writeStackTif(uint16(resizedLabelledImage), strcat(path2save,'\','validScutoids_',fileName,'.tif'));


end

