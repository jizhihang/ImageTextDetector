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
    XComponents = [];
    XChains = [];
    
    % Positive components
    noChains = length(posData);
    
    for i = 1:noChains
        % Each chain, get features for components
        for j = 1:length(posData{i}.compFeat)
            curComp = posData{i}.compFeat{j};
            % Extracting current component features
            feature = [curComp.contourShape, curComp.edgeShape, ...
                        curComp.occupationRatio, curComp.AxialRatio, ...
                        curComp.widthVariation, curComp.density];
            
            % Adding it to the pool
            XComponents = [XComponents; feature];
        end
    end
    
    % Constructing the YComponents
    YComponents = ones(size(XComponents, 1), 1);
    
    % Negative components
    noChains = length(negData);
    
    for i = 1:noChains
        % Reading the corresponding part of the 
        
        % Each chain, get features for components
        for j = 1:length(negData{i}.compFeat)
            curComp = negData{i}.compFeat{j};
            % Extracting current component features
            feature = [curComp.contourShape, curComp.edgeShape, ...
                        curComp.occupationRatio, curComp.AxialRatio, ...
                        curComp.widthVariation, curComp.density];
            
            % Adding it to the pool
            XComponents = [XComponents; feature];
        end
    end
    
    % Constructing the YComponents
    YComponents = [YComponents; zeros(size(XComponents, 1)-length(YComponents), 1)];
    
    fprintf('Training %d trees for the component forests\n', noTrees);
    % Train the models
    componentModel = TreeBagger(noTrees, XComponents, YComponents, ...
                    'Method', 'Classification');
    
    % Building the chain classifier
    fprintf('Training %d trees for the chain forests\n', noTrees);
    
    % Getting probabilities for all the training data
    %trainingProb = zeros(length(YComponents), 2);
    [trainingLabel, trainingProb] = componentModel.predict(XComponents);
    % Converting cell to mat
    trainingLabel = cell2mat(trainingLabel);
    
    fprintf('Training on components completed, accuracy : %f\n', ...
            sum(1 - xor(trainingLabel, YComponents))/length(trainingLabel));
    
    return
    
    % Chain features
    % Contour shape, edge shape, occupation ratio, axial ratio, 
    % width variation, density
    XChains = [];
    
    % Positive components
    noChains = length(posData);
    
    for i = 1:noChains
        % Reading the corresponding image
        image = imread();
        % Each chain, get features for components
        for j = 1:length(posData{i}.compFeat)
            curComp = posData{i}.compFeat{j};
            % Extracting current component features
            feature = [curComp.contourShape, curComp.edgeShape, ...
                        curComp.occupationRatio, curComp.AxialRatio, ...
                        curComp.widthVariation, curComp.density];
            
            % Adding it to the pool
            XComponents = [XComponents; feature];
        end
    end               
    
    chainModel = 1;
    
%end

