function [ pyramid_all ] = CompilePyramid( imageFileList, dataBaseDir, textonSuffix, params, canSkip, pfig )
%function [ pyramid_all ] = CompilePyramid( imageFileList, dataBaseDir, textonSuffix, params, canSkip )
%
% Generate the pyramid from the texton lablels
%
% For each image the texton labels are loaded. Then the histograms are
% calculated for the finest level. The rest of the pyramid levels are
% generated by combining the histograms of the higher level.
%
% imageFileList: cell of file paths
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image file
% textonSuffix: this is the suffix appended to the image file name to
%  denote the data file that contains the textons indices and coordinates. 
%  Its default value is '_texton_ind_%d.mat' where %d is the dictionary
%  size.
% params.dictionarySize: size of descriptor dictionary (200 has been found to be
%  a good size)
% params.pyramidLevels: number of levels of the pyramid to build
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Spatial Pyramid\n\n');

%% parameters

if(~exist('params','var'))
    params.maxImageSize = 1000;
    params.gridSpacing = 8;
    params.patchSize = 16;
    params.dictionarySize = 200;
    params.numTextonImages = 50;
    params.pyramidLevels = 3;
end
if(~isfield(params,'maxImageSize'))
    params.maxImageSize = 1000;
end
if(~isfield(params,'gridSpacing'))
    params.gridSpacing = 8;
end
if(~isfield(params,'patchSize'))
    params.patchSize = 16;
end
if(~isfield(params,'dictionarySize'))
    params.dictionarySize = 200;
end
if(~isfield(params,'numTextonImages'))
    params.numTextonImages = 50;
end
if(~isfield(params,'pyramidLevels'))
    params.pyramidLevels = 3;
end
if(~exist('canSkip','var'))
    canSkip = 1;
end

binsHigh = 2^(params.pyramidLevels-1);

if(exist('pfig','var'))
    %tic;
end
pyramid_all = zeros(length(imageFileList),params.dictionarySize*sum((2.^(0:(params.pyramidLevels-1))).^2));
for f = 1:length(imageFileList)


    %% load image
    imageFName = imageFileList{f};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    
    if(mod(f,100)==0 && exist('pfig','var'))
        sp_progress_bar(pfig,4,4,f,length(imageFileList),'Compiling Pyramid:');
    end
    outFName = fullfile(dataBaseDir, sprintf('%s_pyramid_%d_%d.mat', baseFName, params.dictionarySize, params.pyramidLevels));
    if(size(dir(outFName),1)~=0 && canSkip)
        %fprintf('Skipping %s\n', imageFName);
        load(outFName, 'pyramid');
        pyramid_all(f,:) = pyramid;
        continue;
    end
    
    %% load texton indices
    in_fname = fullfile(dataBaseDir, sprintf('%s%s', baseFName, textonSuffix));
    load(in_fname, 'texton_ind');
    
    %% get width and height of input image
    wid = texton_ind.wid;
    hgt = texton_ind.hgt;

    %fprintf('Loaded %s: wid %d, hgt %d\n', imageFName, wid, hgt);
    sp_progress_bar(pfig,4,4,f,length(imageFileList),'Compiling Pyramid:');
    
    %% compute histogram at the finest level
    pyramid_cell = cell(params.pyramidLevels,1);
    pyramid_cell{1} = zeros(binsHigh, binsHigh, params.dictionarySize);

    for i=1:binsHigh
        for j=1:binsHigh

            % find the coordinates of the current bin
            x_lo = floor(wid/binsHigh * (i-1));
            x_hi = floor(wid/binsHigh * i);
            y_lo = floor(hgt/binsHigh * (j-1));
            y_hi = floor(hgt/binsHigh * j);
            
            texton_patch = texton_ind.data( (texton_ind.x > x_lo) & (texton_ind.x <= x_hi) & ...
                                            (texton_ind.y > y_lo) & (texton_ind.y <= y_hi));
            
            % make histogram of features in bin
            pyramid_cell{1}(i,j,:) = hist(texton_patch, 1:params.dictionarySize)./length(texton_ind.data);
        end
    end

    %% compute histograms at the coarser levels
    num_bins = binsHigh/2;
    for l = 2:params.pyramidLevels
        pyramid_cell{l} = zeros(num_bins, num_bins, params.dictionarySize);
        for i=1:num_bins
            for j=1:num_bins
                %max pooling instead of sum pooling
                pyramid_cell{l}(i,j,:) = max([ ...
                                                pyramid_cell{l-1}(2*i-1,2*j-1,:); ...
                                                pyramid_cell{l-1}(2*i,2*j-1,:); ...
                                                pyramid_cell{l-1}(2*i-1,2*j,:); ...
                                                pyramid_cell{l-1}(2*i,2*j,:) ...
                                            ],[],1);
                %pyramid_cell{l}(i,j,:) = ...
                %pyramid_cell{l-1}(2*i-1,2*j-1,:) + pyramid_cell{l-1}(2*i,2*j-1,:) + ...
                %pyramid_cell{l-1}(2*i-1,2*j,:) + pyramid_cell{l-1}(2*i,2*j,:);
            end
        end
        num_bins = num_bins/2;
    end

    %% stack all the histograms with appropriate weights
    pyramid = [];
    for l = 1:params.pyramidLevels-1
        pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
    end
    pyramid = [pyramid pyramid_cell{params.pyramidLevels}(:)' .* 2^(1-params.pyramidLevels)];

    % save pyramid
    sp_make_dir(outFName);
    save(outFName, 'pyramid');

    pyramid_all(f,:) = pyramid;

end % f

outFName = fullfile(dataBaseDir, sprintf('pyramids_all_%d_%d.mat', params.dictionarySize, params.pyramidLevels));
%save(outFName, 'pyramid_all');


end
