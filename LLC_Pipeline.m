clear; clc; close all;
addpath('./SpatialPyramid');
addpath('./liblinear-1.94/matlab');

% Example of how to use the BuildPyramid function
% set image_dir and data_dir to your actual directories
image_dir = 'scene_categories'; 
data_dir = 'data';

% get all the scene categories
d = dir(image_dir);
categories = cell(length(d)-2,1);
j = 1;
for i=1:length(d)
    if (not(or(strcmp(d(i).name,'.'), strcmp(d(i).name,'..'))))
        categories{j} = d(i).name;
        j = j + 1;
    end
end

filenames = {};
fileCategory = {};
totalNumFiles = 0;

for i=1:length(categories)
    c_dir = strcat(image_dir, '/', categories{i});
    fnames = dir(fullfile(c_dir, '*.jpg'));
    num_files = size(fnames,1);
    % filenames = cell(num_files,1);

    for f = 1:num_files
        filenames{totalNumFiles+1} = strcat(categories{i}, '/', fnames(f).name);
        fileCategory{totalNumFiles+1} = i;
        totalNumFiles = totalNumFiles+1;
    end
end

% for other parameters, see BuildPyramid


% return pyramid descriptors for all files in filenames
pyramid_all = BuildPyramid(filenames,image_dir,data_dir);

% % build a pyramid with a different dictionary size without re-generating the
% % sift descriptors.
% params.dictionarySize = 400
% pyramid_all2 = BuildPyramid(filenames,image_dir,data_dir,params,1);
% 
% %control all the parameters
% params.maxImageSize = 1000
% params.gridSpacing = 1
% params.patchSize = 16
% params.dictionarySize = 200
% params.numTextonImages = 300
% params.pyramidLevels = 2
% pyramid_all3 = BuildPyramid(filenames,image_dir,[data_dir '2'],params,1);

% compute histogram intersection kernel
K = hist_isect(pyramid_all, pyramid_all); 

% for faster performance, compile and use hist_isect_c:
% K = hist_isect_c(pyramid_all, pyramid_all);


model = train(training_label_vector,pyramid_all);