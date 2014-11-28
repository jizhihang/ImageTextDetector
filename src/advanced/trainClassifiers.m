%function [componentModel, chainModel] = trainClassifiers(trainingPath, imagePath noTrees)
    % This function trains classifiers for both components and chains
    %
    % Usage:
    % [componentModel, chainModel] = trainClassifiers(trainingPath, noTrees)
    %
    % Input : 
    % trainingPath = path to the training data that contains both the
    %               positive and negative examples to train random forests
    % imagePath = Path to the training images
    % noTrees = Number of bagged trees (trees in random forest)
    %
    % Output: 
    % componentModel = Random forest classifier for components
    % chainModel = Random forest classifier for chains
    
    trainingPath = '.'; noTrees = 200; imagePath = '../../MSRA-TD500/train';
    
    % Loading the dumped data for training
    load(fullfile(trainingPath, 'trainingData.mat'));
    fprintf('Training data loaded\n');
    % First augment and create dataX and dataY
    % dataX = Feature vector (Nobs x Nfeats)
    % dataY = labels for supervised learning
    
    % Component features
    % Contour shape, edge shape, occupation ratio, axial ratio, 
    % width variation, density
    
    % Positive components
    noChainsPos = length(posData);
    
    % Negative components
    noChainsNeg = length(negData);
    
    % Single pass to determine number of components, positive and negative
    noCompsPos = 0;
    for i = 1:noChainsPos
        noCompsPos = noCompsPos + length(posData{i}.compFeat);
    end
    noCompsNeg = 0;
    for i = 1:noChainsPos
        noCompsNeg = noCompsNeg + length(negData{i}.compFeat);
    end
    
    % 120 features for each component
    noCompFeatures = 120;
    XComponents = zeros(noCompsNeg + noCompsPos, noCompFeatures);
    
    % features for each chain
    noChainFeatures = 11;
    XChains = zeros(noChainsPos + noChainsNeg, noChainFeatures);
    
    curCompId = 1;
    for i = 1:noChainsPos
        % Each chain, get features for components
        for j = 1:length(posData{i}.compFeat)
            curComp = posData{i}.compFeat{j};
            % Extracting current component features
            XComponents(curCompId, :) = [curComp.contourShape, curComp.edgeShape, ...
                        curComp.occupationRatio, curComp.AxialRatio, ...
                        curComp.widthVariation, curComp.density];
            
            % Incrementing the component count
            curCompId = curCompId + 1;
        end
    end
    
    % Constructing the YComponents
    YComponents = ones(curCompId - 1, 1);
    
    
    for i = 1:noChainsNeg
        % Reading the corresponding part of the 
        
        % Each chain, get features for components
        for j = 1:length(negData{i}.compFeat)
            curComp = negData{i}.compFeat{j};
            % Extracting current component features
            XComponents(curCompId, :) = [curComp.contourShape, curComp.edgeShape, ...
                        curComp.occupationRatio, curComp.AxialRatio, ...
                        curComp.widthVariation, curComp.density];
            
            % Incrementing the component count
            curCompId = curCompId + 1;
        end
    end
    
    % Constructing the YComponents
    YComponents = [YComponents; zeros(curCompId - 1 -length(YComponents), 1)];
    
    fprintf('Training %d trees for the component forests\n', noTrees);
    % Train the models
    componentModel = TreeBagger(noTrees, XComponents, YComponents, ...
                    'Method', 'Classification');
    
    % Getting probabilities for all the training data
    %trainingProb = zeros(length(YComponents), 2);
    [trainingLabel, trainingProb] = componentModel.predict(XComponents);
    % Converting cell to mat
    trainingLabel = cell2mat(trainingLabel);
    
    fprintf('Training on components completed, accuracy : %f\n', ...
            sum(1 - xor(trainingLabel, YComponents))/length(trainingLabel));
    
    % Chain features
    % Candidate count, average probability, average turning angle
    % size variation, distance variation, average direction bias,
    % average axial ratio, average density, average width variation, 
    % average color self similarity, average structure self-similarity
    
    % Positive chains
    compCount = 1;
    
    for i = 1:noChainsPos
        % Reading the corresponding image
        image = imread(fullfile(imagePath, posData{i}.imageName));
        box = posData{i}.bboxes;
        
        % Evaluation of chain features
        % Takes in image, components, chains, compFeat, compProbabilities
        iterImage = image(box(1) : box(2), box(3):box(4), :);
        iterComponents = posData{i}.components;
        noComps = length(iterComponents);
        iterChains = {1:noComps};
        iterCompFeat = posData{i}.compFeat;
        iterProbabilities = trainingProb(compCount:(compCount + noComps -1), 2);
        compCount = compCount + noComps;
        
        feature = evaluateChainFeatures(iterImage, iterComponents, ...
                        iterChains, iterCompFeat, iterProbabilities);

        % Adding it to the pool
        XChains(i, :) = feature;
    end               
    
    % Y for these chains
    YChains = ones(noChainsPos, 1);
    
    % Negative chains picked up from negative examples
     
    for i = 1:noChainsNeg
        % Reading the corresponding image
        image = imread(fullfile(imagePath, negData{i}.imageName));
        box = negData{i}.bboxes;
        
        % Evaluation of chain features
        % Takes in image, components, chains, compFeat, compProbabilities
        iterImage = image(box(1) : box(2), box(3):box(4), :);
        iterComponents = negData{i}.components;
        noComps = length(iterComponents);
        iterChains = {1:noComps}; 
        iterCompFeat = negData{i}.compFeat;
        iterProbabilities = trainingProb(compCount:(compCount + noComps -1), 2);
        compCount = compCount + noComps;
        
        feature = evaluateChainFeatures(iterImage, iterComponents, ...
                        iterChains, iterCompFeat, iterProbabilities);

        % Adding it to the pool
        XChains(i, :) = feature;
    end
    
    % Updating the Y of chains
    YChains = [YChains; -1 * ones(noChainsNeg, 1)];
   
    % Building the chain classifier
    fprintf('Training %d trees for the chain forests\n', noTrees);
    
    % Training the random forest
    chainModel = TreeBagger(noTrees, XChains, YChains, ...
                    'Method', 'Classification');
    
%end

