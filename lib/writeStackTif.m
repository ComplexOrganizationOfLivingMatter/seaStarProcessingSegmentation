function writeStackTif(img,fileName)

if iscategorical(img)
    img=double(img);
    img(isnan(img))=0;
end

if exist(fileName,'file')
    delete(fileName)
    disp(['deleting pre-existing ' fileName])
end

%write a Tiff file, appending each image as a new page
    for ii = 1 : size(img, 3)
        imwrite(img(:,:,ii) ,fileName, 'WriteMode' , 'append') ;
    end

end