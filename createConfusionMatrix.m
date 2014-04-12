function [ accuracy, averageAccuracy, confusionMat ] = createConfusionMatrix( predictedLabels, actualLabels, categories )
    numLabels = length(categories);
    confusionMat = zeros(numLabels,numLabels);
    accuracy = zeros(numLabels,1);
    for i=1:length(actualLabels)
        confusionMat( actualLabels(i), predictedLabels(i) ) = ...
                confusionMat( actualLabels(i), predictedLabels(i) ) + 1;
    end
    
    for i=1:numLabels
        accuracy(i) = confusionMat(i,i)/sum(confusionMat(i,:));
    end
    
    averageAccuracy = mean(accuracy(:));
    
    formattedMat = cell((numLabels+1),(numLabels+2));
    
    for i=1:numLabels
        formattedMat{1,i+1} = categories{i};
        formattedMat{i+1,1} = categories{i};
        for j=1:numLabels
            formattedMat{i+1,j+1} = confusionMat(i,j);
        end
    end
    
    formattedMat{1,numLabels+2} = 'Percent Correct';
    for i=1:length(accuracy)
        formattedMat{i+1,numLabels+2} = accuracy(i);
    end
    
    cell2csv('ConfusionMatrix.csv',formattedMat);

end

