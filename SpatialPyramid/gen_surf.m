function [features] = gen_surf(imageFName,params)
    I = sp_load_image(imageFName);

    [hgt wid] = size(I);
    if min(hgt,wid) > params.maxImageSize
        I = imresize(I, params.maxImageSize/min(hgt,wid), 'bicubic');
        fprintf('Loaded %s: original size %d x %d, resizing to %d x %d\n', ...
            imageFName, wid, hgt, size(I,2), size(I,1));
        [hgt wid] = size(I);
    end
    
    Options.upright=true;
    Options.tresh=0.0001;
    valid_points=OpenSurf(I,Options);
    
    features.data = [valid_points.descriptor].';
    features.x = [valid_points.x].';
    features.y = [valid_points.y].';
    features.wid = wid;
    features.hgt = hgt;
end