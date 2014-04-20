clear; clc; close all;
addpath('./SpatialPyramid');
addpath('./liblinear-1.94/windows');
addpath('./cell2csv');
addpath('./SubFunctions');

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
filesInCategory = {};
totalNumFiles = 0;

for i=1:length(categories)
    c_dir = strcat(image_dir, '/', categories{i});
    fnames = dir(fullfile(c_dir, '*.jpg'));
    num_files = size(fnames,1);
    filesInCategory{i} = num_files;

    for f = 1:num_files
        filenames{totalNumFiles+1} = strcat(categories{i}, '/', fnames(f).name);
        fileCategory{totalNumFiles+1} = i;
        totalNumFiles = totalNumFiles+1;
    end
end

% return pyramid descriptors for all files in filenames
params.dictionarySize = 200;
pyramid_all = BuildPyramid(filenames,image_dir,data_dir,params);
%pyramid_all = BuildPyramid(filenames,image_dir,data_dir,params,1,0,1);

% partition the data
[ trainingSet, trainingLabels, testingSet, testingLabels ] = divideSets(pyramid_all, fileCategory, filesInCategory, 100 );


trainingSet = sparse(trainingSet);
model = train(trainingLabels,trainingSet);

testingSet = sparse(testingSet);
[predicted_label, accuracy, decision_values] = predict(testingLabels, testingSet, model);

[ acc, averageAccuracy, confusionMat ] = createConfusionMatrix( predicted_label, testingLabels, categories);