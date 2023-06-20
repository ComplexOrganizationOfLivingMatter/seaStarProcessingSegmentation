function [img2] = relabelMulticutTiff(img)

uniqueLabels = unique(img);

img2=img;
img2(~ismember(img, uniqueLabels))=0;

relabels = 0:1:length(uniqueLabels)-1;

for nLab = relabels
    img2(img==uniqueLabels(nLab+1))=nLab;
end

end

            