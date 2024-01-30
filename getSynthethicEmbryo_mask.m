function [homogeneizedVoronoiEmbryo] = getSynthethicEmbryo_mask(labelledImage,outPath,fileName, nCells, minimumSeparation)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INPUTS
    % mask: binary image where seeds will be located
    % nCells: Number of cells
    % centerAccuracy: allowed Z variation in the seed position
    % minimumSeparation: Percentage of cellHeight between the 2 closest.
    % 5 means 2.5 range both up and down.
    % seeds. PIXELS, NOT PERCENTAGE.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    labelledImage=imresize3(labelledImage,(size(labelledImage)/4),'nearest');
    
    %% specify mask
    mask=labelledImage>1;
    
    aux_mask = mask;
    
    xyproject = sum(mask, 3);
    xyproject = xyproject>5; %% JUST TO ENSURE THAT THERE'S NOTA SINGLE DOT. ITS AT LEAT 6PX TALL CELL
    
    centerAccuracy = 5; 

%     nCells = 269;                                       %% PARAMETER
%     
    % xyz positions inside mask
    [x,y] = ind2sub(size(xyproject),find(xyproject==1));
    seeds = [];
    seedMatrix = zeros(size(mask));
%     minimumSeparation = 10; %% half of the cell height seems to work nice   %% PARAMETER
    
    iters = size(x, 1);
    
    % locate random seeds and check if it's inside the mask
    for i = 1:iters
        randomDotIx = round(rand(1)*size(x, 1));
        
        if randomDotIx == 0
            randomDotIx = randomDotIx+1;
        end
        randomDot = [x(randomDotIx), y(randomDotIx)];
        x(randomDotIx) = [];
        y(randomDotIx) = [];
        
        first1 = find(mask(randomDot(1), randomDot(2), :), 1, 'first');
        last1 = find(mask(randomDot(1), randomDot(2), :), 1, 'last');
                
        randomDotZ = round((first1+last1)/2);
        randomDotZ = round(randomDotZ+(-0.5+rand(1))*centerAccuracy);
        
        randomDot = [randomDot(1), randomDot(2), randomDotZ];
    
        if isempty(seeds)
            seeds = [seeds;randomDot];
        end
        
        if min(pdist2(randomDot,seeds)) <= minimumSeparation
            continue
        else
            seeds = [seeds;randomDot];
            seedMatrix((randomDot(1)), randomDot(2), randomDot(3))=1;  %!! DO NOT CHANGE X Y Z IS CORRECT
        end
        
        if size(seeds,1)==nCells
            break
        end
            
    end
    
    %%
    
    seeds_bw = bwlabeln(seedMatrix);
    se = strel('sphere',5);
    seeds_bw = imdilate(seeds_bw,se);
    
    %Voronoi from mask and seeds
    voronoiEmbryo = VoronoizateCells(aux_mask,seeds_bw);
    
    %resize and save
    writeStackTif(uint16(voronoiEmbryo), strcat(outPath,'\','voronoi_',fileName,'.tif'));
    
    %homogeneize throughout Lloyd algorithm
    centroids = regionprops3(voronoiEmbryo, 'Centroid');
    centroidSeeds = zeros(size(voronoiEmbryo));
    uniqueLabels = unique(voronoiEmbryo);
    
    % check that everything is ok
    if length(uniqueLabels)~=length(unique(voronoiEmbryo))
        warning('smth wrong with seeds');
    end
    
    % assign labels/centroids
    for seedIx=1:length(uniqueLabels)-1
        centroidSeeds(round(centroids.Centroid(seedIx, 2)), round(centroids.Centroid(seedIx, 1)), round(centroids.Centroid(seedIx, 3))) = seedIx;
    end
    
    se = strel('sphere',5);
    homogeneizedVoronoiEmbryo = imdilate(centroidSeeds,se);
    homogeneizedVoronoiEmbryo = VoronoizateCells(voronoiEmbryo>0, homogeneizedVoronoiEmbryo);
%     resizedHomogeneizedvoronoiEmbryo=imresize3(homogeneizedvoronoiEmbryo,size(originalImage),'nearest');
    writeStackTif(uint16(homogeneizedVoronoiEmbryo), strcat(outPath,'\','homogeneizedVoronoi_',fileName,'.tif'));
    
end


