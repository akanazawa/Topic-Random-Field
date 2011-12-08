function preProSegFeatsAndSave(dataFolder,neighNameStem,trainList, neighName, dataSet, params,mainDataSet)

%trainList = trainList(1:maxTrainImg);
if ~exist('allData','var')
    for i = 1:length(trainList)
        allData{i} = load([dataFolder trainList{i} '.mat']);
    end
end

%%%%%%%%%%%%%%%%%%%
% 'whiten' inputs (each feature separately) to mean 0
if strcmp(dataSet,'train')
    allFeats = [];
    for i = 1:length(allData)
        allFeats = [allFeats ; allData{i}.feat2];
    end
    meanAll = mean(allFeats);
    stdAll  = std(allFeats);
else
    neighNameTrain = [neighNameStem '_train.mat'];
    load(neighNameTrain ,'meanAll','stdAll');
end


%%%%%%%%%%%%%%%%%%%
% normalize features
for i = 1:length(allData)
    featsNow = allData{i}.feat2;
    featsNow = bsxfun(@minus, featsNow, meanAll);
    % Truncate to +/-3 standard deviations and scale to -1 to 1
    pstd = 3 * stdAll;
    featsNow = bsxfun(@max,bsxfun(@min,featsNow,pstd),-pstd);
    featsNow = bsxfun(@times,featsNow,1./pstd);
    if strcmp(params.actFunc,'sigmoid')
        % Rescale from [-1,1] to [0.1,0.9]
        featsNow = (featsNow + 1) * 0.4 + 0.1;
    end
    allData{i}.feat2 = featsNow;
end

%%%%%%%%%%%%%%%%%%%
% assign each segment a label (by pixel majority vote from the annotated regions in labels)
for i = 1:length(allData)
    labelRegs = allData{i}.labels;
    segs = allData{i}.segs2;
    numSegs = max(segs(:));
    segLabels = zeros(numSegs,1);
    for r = 1:numSegs
        segLabels(r) = mode(labelRegs(segs==r));
    end
    allData{i}.segLabels = segLabels;
end

% collect all good and bad segment pairs
% pre-allocate (and later delete empty rows)
if strcmp(mainDataSet,'msrc')
    upperBoundSegPairsNum = length(allData) * 600*10;
else
    upperBoundSegPairsNum = length(allData) * 150*5;
end
goodPairsL = zeros(params.numFeat+1,upperBoundSegPairsNum);
goodPairsR = zeros(params.numFeat+1,upperBoundSegPairsNum);
badPairsL = zeros(params.numFeat+1,upperBoundSegPairsNum);
badPairsR = zeros(params.numFeat+1,upperBoundSegPairsNum);
startBoth = 1;
startBad = 1;

onlyGoodL = zeros(params.numFeat+1,upperBoundSegPairsNum);
onlyGoodR = zeros(params.numFeat+1,upperBoundSegPairsNum);
onlyGoodLabels = zeros(1,upperBoundSegPairsNum);
startOnlyGood = 1;

allSegs = zeros(params.numFeat+1,upperBoundSegPairsNum);
allSegLabels =  zeros(1,upperBoundSegPairsNum);
startAllSegs = 1;

for i = 1:length(allData)
    segs = allData{i}.segs2;
    feats = allData{i}.feat2;
    segLabels = allData{i}.segLabels;
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % find neighbors!
    adjHigher = getAdjacentSegments(segs);%getAdjacentSegments(segs,1)
    adj = adjHigher|adjHigher';
    allData{i}.adj = adj;
    % compute only all pairs and train to merge or not
    for s = 1:length(segLabels)
        % save all segs and their labels for pre-training
        if segLabels(s)>0
            allSegs(:,startAllSegs)= [feats(s,:)' ;1];
            allSegLabels(startAllSegs) = segLabels(s);
            startAllSegs=startAllSegs+1;
        end
        
        neighbors = find(adj(s,:));
        sameLabelNeigh = segLabels(neighbors)==segLabels(s);
        goodNeighbors = neighbors(sameLabelNeigh);
        badNeighbors = neighbors(~sameLabelNeigh);
        numGood = length(goodNeighbors);
        numBad = length(badNeighbors);
        numGBPairs = numGood * numBad;
        
        % never train on void segments: !
        if segLabels(s)>0
            for g = 1:numGood
                onlyGoodL(:,startOnlyGood:startOnlyGood+numGood-1)= [repmat(feats(s,:)',1,numGood ) ;ones(1,numGood)];
                onlyGoodR(:,startOnlyGood:startOnlyGood+numGood-1)= [feats(goodNeighbors,:)' ;ones(1,numGood)];
                onlyGoodLabels(startOnlyGood:startOnlyGood+numGood-1) = segLabels(s);
            end
            startOnlyGood = startOnlyGood + numGood;
        end
        
        if numGood>0 && numBad>0
            gbPairNums = cartprod(goodNeighbors,badNeighbors);
            % these are the inputs to Wbot
            goodPairsL(:,startBoth:startBoth+numGBPairs-1)= [repmat(feats(s,:)',1,numGBPairs) ;ones(1,numGBPairs)];
            goodPairsR(:,startBoth:startBoth+numGBPairs-1)= [feats(gbPairNums(:,1),:)' ;ones(1,numGBPairs)];
            
            badPairsL(:,startBoth:startBoth+numGBPairs-1)= [repmat(feats(s,:)',1,numGBPairs) ;ones(1,numGBPairs)];
            badPairsR(:,startBoth:startBoth+numGBPairs-1)= [feats(gbPairNums(:,2),:)' ;ones(1,numGBPairs)];
            
            startBoth = startBoth+numGBPairs;
        end
        
    end
    if mod(i,20)==0, disp([num2str(i) '/' num2str(length(allData))]);end
end

numAllSegs = startAllSegs-1;
allSegs= allSegs(:,1:numAllSegs);
allSegLabels= allSegLabels(1:numAllSegs);

numOnlyGood = startOnlyGood-1;
onlyGoodL = onlyGoodL(:,1:numOnlyGood);
onlyGoodR = onlyGoodR(:,1:numOnlyGood);
onlyGoodLabels= onlyGoodLabels(1:numOnlyGood);

numGBPairsAll = startBoth-1;
% delete trailing zeros in pre-allocated matrix
goodPairsL = goodPairsL(:,1:numGBPairsAll);
goodPairsR = goodPairsR(:,1:numGBPairsAll);
badPairsL = badPairsL(:,1:numGBPairsAll);
badPairsR = badPairsR(:,1:numGBPairsAll);



save(neighName,'allData','goodPairsL','goodPairsR','badPairsL','badPairsR','meanAll','stdAll','onlyGoodL','onlyGoodR','onlyGoodLabels','allSegs','allSegLabels');
