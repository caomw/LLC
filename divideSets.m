function [ trainingSet, trainingLabels, testingSet, testingLabels ] = divideSets( allData, dataCategories, filesInCat, trainingSetSize )

    trainSize = trainingSetSize * length(filesInCat);
    testSize = size(allData,1) - trainSize;
    trainingSet = zeros(trainSize,size(allData,2));
    trainingLabels = zeros(trainSize,1);
    testingSet = zeros(testSize,size(allData,2));
    testingLabels = zeros(testSize,1);
    
    allCount = 0;
    trainCount = 1;
    testCount = 1;
    
    for i=1:length(filesInCat) % for each categoroy
        r = randperm(filesInCat{i}); % create a random permutation of the data
        
        % divide up this category into the test set and training set
        for j=1:trainingSetSize % training set
            trainingSet(trainCount,:) = allData((allCount + r(j)),:);
            trainingLabels(trainCount,1) = dataCategories{(allCount + r(j))};
            trainCount = trainCount + 1;
        end
        
        for j=(trainingSetSize+1):filesInCat{i} % test set
            testingSet(testCount,:) = allData((allCount + r(j)),:);
            testingLabels(testCount,1) = dataCategories{(allCount + r(j))};
            testCount = testCount + 1;
        end
        
        allCount = allCount + filesInCat{i};
    end



end

