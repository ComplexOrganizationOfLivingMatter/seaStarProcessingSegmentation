%% First pipeline to modify mistakes on S. Glands
addpath(genpath('src'))
addpath(genpath('lib'))

clear all
close all

inPath = uigetdir('E:\Antonio\SeaStar Proyect\SeaStar_Segmentation\128\20200114_pos1');

embryosFiles=dir(inPath);
dirEmbryos = [embryosFiles.isdir];
subDirs = embryosFiles(dirEmbryos); 
embryosFiles = subDirs(3:end);
colours=rand(500,3);
colours=vertcat([0.9 0.9 0.9],colours); 

for nEmbryos=1:length(embryosFiles)
    segmentedEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\segmentedImages\*.tif*'));
    originalEmbryosFiles = dir(strcat(embryosFiles(nEmbryos).folder,'\',embryosFiles(nEmbryos).name,'\originalImages\*.tif*'));

    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),1);
    allGeneralInfo = cell(size(segmentedEmbryosFiles,1),3);
    allTissues = cell(size(segmentedEmbryosFiles,1),1);
    allMeanCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);
    allStdCellsFeatures = cell(size(segmentedEmbryosFiles,1),1);

    layout = uint8(zeros([413*size(segmentedEmbryosFiles, 1),570*3, 3]));
    
    originalImagePath = originalEmbryosFiles.folder;
    segmentPath = segmentedEmbryosFiles.folder;
    if exist(fullfile(segmentPath,strcat('segmentedImageResized_',date))) ~=7
        mkdir(segmentPath,strcat('segmentedImageResized_',date));
    end
    outPath=strcat(segmentPath,'\segmentedImageResized_',date,'\');
    
    for nFiles=1:length(segmentedEmbryosFiles)

        imageName=originalEmbryosFiles(nFiles).name;
        segmentName=segmentedEmbryosFiles(nFiles).name;
        fileName=strsplit(segmentName,'_itkws');

        if exist(fullfile(segmentPath, fileName{1})) ~=7
            fileName=strsplit(segmentName,'_itkws');
            mkdir(segmentPath, fileName{1})

        end
        [totalCells,numberValidCells,validCells,segmentedImageResized,z_Scale,pixel_Scale] = seaStarOnlyExtractValidCells(originalImagePath,segmentPath,imageName,segmentName);
        
       allGeneralInfo{nFiles,1} =  fileName{1};
       allGeneralInfo{nFiles,2} = totalCells;
       allGeneralInfo{nFiles,3} = numberValidCells;
       disp(numberValidCells)
       segmentedImageOriginalStack=imresize3(segmentedImageResized, [size(segmentedImageResized,1) size(segmentedImageResized,2) (size(segmentedImageResized,3)/z_Scale)],'nearest');
       writeStackTif(uint16(segmentedImageOriginalStack),fullfile(outPath,strcat(fileName{1},'.tiff')))
       
%        segmentedImageResized=relabelMulticutTiff(segmentedImageResized);
       segmentedImageResized=imresize3(segmentedImageResized,[size(segmentedImageResized,1)/4 size(segmentedImageResized,2)/4 size(segmentedImageResized,3)/4],'nearest');
       
        paint3D(segmentedImageResized, numberValidCells,colours, 3);
        material([0.5 0.2 0.0 10 1])
        fig = get(groot,'CurrentFigure');
        fig.Color = [1 1 1];
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
       
        %first render
        frame = getframe(fig);      % Grab the rendered frame
        renderedFrontImage = frame.cdata;    % This is the rendered image
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        renderedFrontImage = imresize(renderedFrontImage, [413, 570]);

        %second render
        camorbit(180, 0)
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        frame = getframe(fig);      % Grab the rendered frame
        renderedBackImage = frame.cdata;    % This is the rendered image
        renderedBackImage = imresize(renderedBackImage, [413, 570]);

        %third render
        camorbit(0, -90)
        delete(findall(gcf,'Type','light'));
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        camlight('headlight', 'infinite');
        frame = getframe(fig);      % Grab the rendered frame
        renderedBottomImage = frame.cdata;    % This is the rendered image
        renderedBottomImage = imresize(renderedBottomImage, [413, 570]);

        %% Insert text
        renderedFrontImage = insertText(renderedFrontImage,[1, 1],fileName{1},'FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedFrontImage = insertText(renderedFrontImage,[390, 1],'FRONT','FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
        renderedBackImage = insertText(renderedBackImage,[390, 1],'BACK','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
        renderedBottomImage = insertText(renderedBottomImage,[390, 1],'BOTTOM','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');

        layout(413*(nFiles-1)+1:413*(nFiles),1:570,:) = renderedFrontImage;
        layout(413*(nFiles-1)+1:413*(nFiles), 571:570*2, :) = renderedBackImage;
        layout(413*(nFiles-1)+1:413*(nFiles), 570*2+1:end, :) = renderedBottomImage;

        close(fig)
       
       
    end
    
%     imwrite(layout, strcat(outPath, '/', embryosFiles(nEmbryos).name, '.bmp'),'bmp');
    imwrite(layout, strcat(outPath, '/', embryosFiles(nEmbryos).name,'.png'),'png');
%     save(strcat(outPath, '/', embryosFiles(nEmbryos).name,'.mat'), 'layout');
    
    
    
    
end
% embryoName=strsplit(string(inPath),'\');
% allGeneralInfo=cell2table(allGeneralInfo,'VariableNames',{'ID', 'totalCells','validCells'});
% writetable(allGeneralInfo,[inPath,'global_validCells_' date '.xls'],'Sheet', 'allGeneralInfo','Range','B2');

