
%% cartoStar
% Code for cartographic representation of sea star features.
% It requires information in .mat files containing the features and valid cells.

% The output of this code consists of two images, one in BMP format and another in PNG format.
% These images represent: sea star top (random colors), sea star bottom (random colors),
% sea star bottom (colored based on volume), sea star bottom (colored based on solidity),
% sea star bottom (colored if scutoid).

%% Enter path to data, data to study and normalization type 

data = inputdlg({'Working directory', 'Folder to study [All, wt, animal wt, vegetal wt, animal comp, vegetal comp, animal, vegetal]', 'Feature Normalization [All, wt, animal wt, vegetal wt, animal comp, vegetal comp, byEmbryo byTimepoint]'},...
                 'Input data', [1 50;1 50; 1 50], {'/media/pedro/6TB/jesus/SEASTAR/forceInference/tree/128/', 'vegetal wt', 'vegetal wt'}); 

                       
%% tic/toc for measuring time             
tic

%% input data into variables
dataToStudy = data{2};
normalizationTypeFeatures = data{3};
path = data{1};

%% normalization (if required)
if ~strcmp(normalizationTypeFeatures, 'byEmbryo') && ~strcmp(normalizationTypeFeatures, 'byTimepoint')
    normalizationFeatureValues = normalizeFeaturesData(data{1}, normalizationTypeFeatures);
end

treeDir = dir(strcat(path));
    
%% 
if strcmp(dataToStudy, 'All')
    textToContain = '';
else
    textToContain = dataToStudy;
end

%% for loop looking for all folders containing 'textToContain'
for treeIx = 3:length(treeDir)
    treeId = treeDir(treeIx).name;
    if contains(treeId, textToContain)
        folderPath = strcat(path, treeId, '/cartoStar/'); 
        folderDir = dir(strcat(folderPath, '*.tif'));
        layout = uint8(zeros([413*size(folderDir, 1),570*5, 3]));
        
        for ix=1:size(folderDir)
            % initialize colours
            coloursRandom = [];
            coloursFeatures_volume = [];
            coloursFeatures_solidity = [];
            coloursFeatures_scutoids = [];
            
            fileName = folderDir(ix).name;
            labelledImage = readStackTif(strcat(folderPath, fileName));
            
            %% check normalization

            if strcmp(normalizationTypeFeatures, 'byEmbryo')
                auxFileName = strsplit(fileName, '_stk');
                normalizationFeatureValues = normalizeFeaturesDataByEmbryo(folderPath, auxFileName{1});
            end
            
            fileName = strsplit(fileName, '.tif');
            fileName = fileName{1};
            disp(fileName)

            load(strcat(folderPath, fileName, 'validCells.mat'));
            load(strcat(folderPath, fileName, 'features.mat'));

            cMap1 = interp1([0;0.5],[1 0.84 0.150; 1 0.28 0.65],linspace(0,0.5,50));
            cMap2 = interp1([0.5;1],[1 0.28 0.6; 0.41 0.28 0.55],linspace(0.5,1,50));

            cMap = [cMap1; cMap2]; 
            
            if ~strcmp(normalizationTypeFeatures, 'byTimepoint')
                maxValue_features_volume = max(normalizationFeatureValues.Volume);
                minValue_features_volume = min(normalizationFeatureValues.Volume);
                maxValue_features_solidity = max(normalizationFeatureValues.Solidity);
                minValue_features_solidity = min(normalizationFeatureValues.Solidity);
            else
                maxValue_features_volume = max(newCells3dFeatures.Volume);
                minValue_features_volume = min(newCells3dFeatures.Volume);
                maxValue_features_solidity = max(newCells3dFeatures.Solidity);
                minValue_features_solidity = min(newCells3dFeatures.Solidity);
            end

            uniqueLabels = unique(labelledImage);
            try
                for cellIx = 2:length(uniqueLabels)
                    cellId = uniqueLabels(cellIx);
%                     disp(cellId)
                    if ismember(cellId, validCells)
                        
                        % add colo  to features. Need to be calculated here
                        % since only valid Cells are in newCells3dFeatures
                        % table
                        currentCellFeature_volume = newCells3dFeatures(strcmp(newCells3dFeatures.ID_Cell, strcat('cell_', num2str(cellId))), 'Volume').Volume;
                        currentCellFeature_solidity = newCells3dFeatures(strcmp(newCells3dFeatures.ID_Cell, strcat('cell_', num2str(cellId))), 'Solidity').Solidity;
                        currentCellFeature_scutoids = newCells3dFeatures(strcmp(newCells3dFeatures.ID_Cell, strcat('cell_', num2str(cellId))), 'Scutoids').Scutoids;

                        cMapIndexFeature_volume = round(100*(currentCellFeature_volume-minValue_features_volume)/(maxValue_features_volume-minValue_features_volume));
                        cMapIndexFeature_solidity = round(100*(currentCellFeature_solidity-minValue_features_solidity)/(maxValue_features_solidity-minValue_features_solidity));

                        if cMapIndexFeature_volume == 0 || isnan(cMapIndexFeature_volume)
                            cMapIndexFeature_volume = 1;
                        elseif cMapIndexFeature_volume>100
                            cMapIndexFeature_volume = 100;
                        end
                        
                        if cMapIndexFeature_solidity == 0 || isnan(cMapIndexFeature_solidity)
                            cMapIndexFeature_solidity = 1;
                        elseif cMapIndexFeature_solidity>100
                            cMapIndexFeature_solidity = 100;
                        end
                        
                        coloursRandom = [coloursRandom; rand(1,3)];
                        coloursFeatures_volume = [coloursFeatures_volume; cMap(cMapIndexFeature_volume, :)]; 
                        coloursFeatures_solidity = [coloursFeatures_solidity; cMap(cMapIndexFeature_solidity, :)]; 
                        
%                         disp(sum(newCells3dFeatures.Scutoids));
                        if currentCellFeature_scutoids == 1
                            coloursFeatures_scutoids = [coloursFeatures_scutoids; [1 0.84 0.150]]; 
                        else
                            coloursFeatures_scutoids = [coloursFeatures_scutoids; [0.5, 0.5, 0.5]]; 
                        end


                    else
                        coloursRandom = [coloursRandom; [0.8, 0.8, 0.8]];
                        coloursFeatures_volume = [coloursFeatures_volume; [0.8, 0.8, 0.8]];
                        coloursFeatures_solidity = [coloursFeatures_solidity; [0.8, 0.8, 0.8]];
                        coloursFeatures_scutoids = [coloursFeatures_scutoids; [0.8, 0.8, 0.8]];

                    end
                end
            catch
                continue
            end

            
            %% Plot random color
        %     labelledImage = imresize3(labelledImage, size(labelledImage)/5, 'nearest');            
            paint3D(labelledImage, uniqueLabels, coloursRandom, 3, 2);

            material([0.5 0.2 0.0 10 1])
            fig = get(groot,'CurrentFigure');
            fig.Color = [1 1 1];
            delete(findall(gcf,'Type','light'));
            camorbit(180, 0)
            camorbit(0, 90)
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            frame = getframe(fig);      % Grab the rendered frame
            renderedTopImage = frame.cdata;    % This is the rendered image
            renderedTopImage = imresize(renderedTopImage, [413, 570]);

            %% TOP
            delete(findall(gcf,'Type','light'));
            camorbit(0, 180)
            fig = get(groot,'CurrentFigure');
            fig.Color = [1 1 1];
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            frame = getframe(fig);      % Grab the rendered frame
            renderedBottomImage = frame.cdata;    % This is the rendered image
            renderedBottomImage = imresize(renderedBottomImage, [413, 570]);
            close(fig)

            %% Features (VOLUME)
            paint3D(labelledImage, uniqueLabels, coloursFeatures_volume, 3, 2);

            material([0.5 0.2 0.0 10 1])
            fig = get(groot,'CurrentFigure');
            fig.Color = [1 1 1];
            delete(findall(gcf,'Type','light'));
            camorbit(180, 0)
            camorbit(0, -90)
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            frame = getframe(fig);      % Grab the rendered frame
            renderedBottomImageFeature_volume = frame.cdata;    % This is the rendered image
            renderedBottomImageFeature_volume = imresize(renderedBottomImageFeature_volume, [413, 570]);
            close(fig)
            %% Features (SOLIDITY)
            paint3D(labelledImage, uniqueLabels, coloursFeatures_solidity, 3, 2);

            material([0.5 0.2 0.0 10 1])
            fig = get(groot,'CurrentFigure');
            fig.Color = [1 1 1];
            delete(findall(gcf,'Type','light'));
            camorbit(180, 0)
            camorbit(0, -90)
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            frame = getframe(fig);      % Grab the rendered frame
            renderedBottomImageFeature_solidity = frame.cdata;    % This is the rendered image
            renderedBottomImageFeature_solidity = imresize(renderedBottomImageFeature_solidity, [413, 570]);
            close(fig)
            
            
            %% Features (SCUTOIDS)
            paint3D(labelledImage, uniqueLabels, coloursFeatures_scutoids, 3, 2);

            material([0.5 0.2 0.0 10 1])
            fig = get(groot,'CurrentFigure');
            fig.Color = [1 1 1];
            delete(findall(gcf,'Type','light'));
            camorbit(180, 0)
            camorbit(0, -90)
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            camlight('headlight', 'infinite');
            frame = getframe(fig);      % Grab the rendered frame
            renderedBottomImageFeature_scutoids = frame.cdata;    % This is the rendered image
            renderedBottomImageFeature_scutoids = imresize(renderedBottomImageFeature_scutoids, [413, 570]);
            close(fig)
            
            %% Insert text
            renderedTopImage = insertText(renderedTopImage,[1, 20],strcat(fileName),'FontSize',10,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
            renderedTopImage = insertText(renderedTopImage,[1, 40],'random colors','FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
            renderedTopImage = insertText(renderedTopImage,[390, 1],'TOP','FontSize',18,'BoxOpacity',0.4,'TextColor','black', 'BoxColor', 'white');
%             renderedBackImage = insertText(renderedBackImage,[390, 1],'BACK','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
            renderedBottomImage = insertText(renderedBottomImage,[390, 1],'BOTTOM','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
            renderedBottomImageFeature_volume = insertText(renderedBottomImageFeature_volume,[390, 1],'BOTTOM-VOLUME','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
            renderedBottomImageFeature_solidity = insertText(renderedBottomImageFeature_solidity,[390, 1],'BOTTOM-SOLIDITY','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');
            renderedBottomImageFeature_scutoids = insertText(renderedBottomImageFeature_scutoids,[390, 1],'BOTTOM-SCUTOIDS','FontSize',18,'BoxOpacity',0.4,'TextColor','black',  'BoxColor', 'white');

            layout(413*(ix-1)+1:413*(ix),1:570,:) = renderedTopImage;
            layout(413*(ix-1)+1:413*(ix), 571:570*2, :) = renderedBottomImage;
            layout(413*(ix-1)+1:413*(ix), 570*2+1:570*3, :) = renderedBottomImageFeature_volume;
            layout(413*(ix-1)+1:413*(ix), 570*3+1:570*4, :) = renderedBottomImageFeature_solidity;
            layout(413*(ix-1)+1:413*(ix), 570*4+1:end, :) = renderedBottomImageFeature_scutoids;



            imwrite(layout, strcat(path, '/showing-', dataToStudy, '_tree-', treeId, '_FeatNorm_', normalizationTypeFeatures,'.bmp'),'bmp');
            imwrite(layout, strcat(path, '/showing-', dataToStudy, '_tree-', treeId, '_FeatNorm_', normalizationTypeFeatures,'.png'),'png');
        end
    end
    
end
toc
