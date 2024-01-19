function [homogeneizedVoronoiCyst] = getSynthethicCyst_mask(originalImage,labelledImage,outPath,fileName, nCells, minimumSeparation)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INPUTS
    % mask: binary image where seeds will be located
    % nCells: Number of cells
    % minimumSeparation: Percentage of cellHeight between the 2 closest
    % seeds. PIXELS, NOT PERCENTAGE.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    labelledImage=imresize3(labelledImage,(size(labelledImage)/4),'nearest');
    
    %% specify mask
    mask=labelledImage>1;
    
    aux_mask = mask;
    
    
    se = strel('sphere',8);                             %% PARAMETER
    mask = imerode(mask, se);
    
    %     nCells = 269;                                       %% PARAMETER
    
    % xyz positions inside mask
    [x,y,z] = ind2sub(size(mask),find(mask==1));
    seeds = [];
    seedMatrix = zeros(size(mask));
    minimumSeparation = 10; %% half of the cell height? ? ?   %% PARAMETER
    
    iters = size(x, 1);
    
    % locate random seeds and check if it's inside the mask
    for i = 1:iters
        randomDotIx = round(rand(1)*size(x, 1));
        if randomDotIx == 0
            randomDotIx = randomDotIx+1;
        end
        randomDot = [x(randomDotIx), y(randomDotIx), z(randomDotIx)];
        x(randomDotIx) = [];
        y(randomDotIx) = [];
        z(randomDotIx) = [];
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
    voronoiCyst = VoronoizateCells(aux_mask,seeds_bw);
    
    
    %resize and save
    resizedVoronoiCyst=imresize3(voronoiCyst,size(originalImage),'nearest');
    writeStackTif(uint16(resizedVoronoiCyst), strcat(outPath,'\','voronoi_',fileName,'.tif'));
    
    %homogeneize throughout Lloyd algorithm
    centroids = regionprops3(voronoiCyst, 'Centroid');
    centroidSeeds = zeros(size(voronoiCyst));
    uniqueLabels = unique(voronoiCyst);
    
    % check that everything is ok
    if length(uniqueLabels)~=length(unique(voronoiCyst))
        warning('smth wrong with seeds');
    end
    
    % assign labels/centroids
    for seedIx=1:length(uniqueLabels)-1
        centroidSeeds(round(centroids.Centroid(seedIx, 2)), round(centroids.Centroid(seedIx, 1)), round(centroids.Centroid(seedIx, 3))) = seedIx;
    end
    
    se = strel('sphere',5);
    homogeneizedVoronoiCyst = imdilate(centroidSeeds,se);
    homogeneizedVoronoiCyst = VoronoizateCells(voronoiCyst>0, homogeneizedVoronoiCyst);
    resizedHomogeneizedVoronoiCyst=imresize3(homogeneizedVoronoiCyst,size(originalImage),'nearest');
    writeStackTif(uint16(resizedHomogeneizedVoronoiCyst), strcat(outPath,'\','homogeneizedVoronoi_',fileName,'.tif'));
    
end


