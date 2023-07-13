function [perimImage] = calculatePerimOf3DImage(img3d, img3dComplete)
%CALCULATEPERIMOF3DIMAGE Summary of this function goes here
%   Detailed explanation goes here
    perimImage = img3d;
    pixelSizeThreshold = 10;
    closingPxAreas2D = 10;
    for coordZ = 1 : size(img3d,3)
        if sum(sum(img3d(:, :, coordZ) > 0)) < pixelSizeThreshold || sum(sum(img3d(:, :, coordZ))) < pixelSizeThreshold
            continue
        end

        closedZFrame = imclose(img3d(:, :, coordZ)>0, strel('disk', round(closingPxAreas2D)));
        img3d(:, :, coordZ) = fill0sWithCells(img3d(:, :, coordZ), img3dComplete(:, :, coordZ), closedZFrame==0);

        %% Remove pixels surrounding the boundary
        rng(1); %%We put this rng to ensure that we are going to get the same filledImage if we run the function twice. This is because tspo_ga is a non-determinitic function (i.e. it might give different outputs even if you put the same input values).
        [filledImage] = createCompleteSection(img3d, coordZ, img3dComplete);
        %figure, imshow(filledImage);
        %figure, imshow(bwperim(filledImage));
        perimImage(:, :, coordZ) = double(bwperim(filledImage)) .* img3d(:, :, coordZ);
        %close all
    end
end

