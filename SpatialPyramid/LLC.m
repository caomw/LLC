% B is the codebook
% X is the list of feature vectors
function [ C ] = LLC( X, B )

    K = 5; % The number of nearest neighbors
    numFeatures = size(X,1); % The number features
    dims = size(X,2);  % number of dimensions in each feature
    codebookSize = size(B,1);
    
    %find the k-nearest neighbors for each feature
    [knnInd, knnDist] = knnsearch(B,X,'K',5);
    knnDist = knnDist.^2; % convert from Eucl dist to squared Eucl distance
    
    C = zeros(numFeatures,codebookSize);
    for i =1:numFeatures
        %NOTE: Step through this and make sure the dimensions work out
        x = X(i,:); % the feature we're working with
        ind = knnInd(i,:); % the indicies of the k-nearest neighbors
        Bi = B(ind,:); % the new set of codebook entries
        
        %setup the matrix to solve the linear system 
        one = ones(K,1);
        B_1x = Bi - one*x;
        c = B_1x * B_1x'; 
        
        c_hat = c \ one; % calculate the new code
        c_hat = chat / sum(c_hat); % normalize
        
        C(i,ind) = c_hat; %check dims o this too
    end
end

