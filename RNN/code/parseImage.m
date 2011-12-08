function thisTree = parseImage(topCorr,Wbot,W,Wout,Wcat,adj,feat,segLabels,params)
% topCorr:
%           0 - highest scoring tree (best) without training loss penalty!
%           1 - highest scoring tree with training loss
%           2 - correct tree (with random choices inside regions)

numSegs= size(feat,1);
segsHid = params.f(Wbot * [feat' ;ones(1,numSegs)]);


allPairs = zeros(2*params.numHid,1000);
allPairsNum = zeros(2,1000);
pairGood = zeros(1,1000);
startNum=1;
for s = 1:size(adj,1)
    neighbors = find(adj(s,:));
    numN = length(neighbors);
    allPairs(:,startNum:startNum+numN-1) = [repmat(segsHid(:,s),1,numN); segsHid(:,neighbors)];
    allPairsNum(:,startNum:startNum+numN-1) = [repmat(s,1,numN); neighbors];
    
    % if topCorr==2, we care about whether this is a good collapse (segs have same label)
    pairGood(startNum:startNum+numN-1) = segLabels(s)==segLabels(neighbors);
    
    startNum=startNum+numN;
end
numPairsAll = startNum-1;
% delete trailing zeros in pre-allocated matrix
allPairs= allPairs(:,1:numPairsAll);
allPairsNum=allPairsNum(:,1:numPairsAll);
pairGood=pairGood(1:numPairsAll);

% forward prop those pairs
pairHid = params.f(W * [allPairs; ones(1,numPairsAll)]);
scores = Wout*pairHid;

if topCorr==1
    % add structure loss penalization for incorrect decisions (to chose them and decrease their scores)
    addPenToScores = params.LossPerError * ~pairGood;
    scores = scores+addPenToScores;
end
%%%%%%%%%%%%%%%%%%%%%%%%
% init tree with pp, features
numTotalSegs = size(adj,1);
numTotalSuperSegs = numTotalSegs+numTotalSegs-1;

adj = [adj zeros(numTotalSegs,numTotalSegs-1); zeros(numTotalSegs-1,numTotalSuperSegs)];

thisTree = tree();
thisTree.pp = zeros(numTotalSuperSegs,1); % we have numRemSegs many leaf nodes and numRemSegs-1 many nonterminals
thisTree.kids = zeros(numTotalSuperSegs,2);
thisTree.nodeNames =  [1:numTotalSegs -ones(1,numTotalSegs-1)];
thisTree.nodeFeatures = [segsHid zeros(size(segsHid,1),numTotalSegs-1)];
thisTree.leafFeatures = feat;


% delete void regions from category/label training!!!!
nonVoidSegs = segLabels>0;
nonVoidSegsInd = find(nonVoidSegs);
thisTree.nodeLabels = sparse(segLabels(nonVoidSegs),nonVoidSegsInd,ones(1,length(nonVoidSegsInd)),params.numLabels,numTotalSuperSegs,numTotalSegs);
thisTree.nodeLabels = full(thisTree.nodeLabels);

% here we only train the category classifier on the correct tree!

% compute cost for kids cats
thisTree.catAct = Wcat*[ segsHid ;ones(1,numSegs)];
thisTree.catOut = softmax(thisTree.catAct);
[catProbs cats] = max(thisTree.catOut);
if size(cats,2) ==1
    cats=cats';
end
thisTree.nodeCatsRight = cats==segLabels';

thisTree.catAct = [thisTree.catAct zeros(params.numLabels,numTotalSegs-1)];
thisTree.catOut = [thisTree.catOut zeros(params.numLabels,numTotalSegs-1)];
% compute the actual predicted category (and CEE... what to do with )
thisTree.nodeCat = [cats zeros(1,numTotalSegs-1)];
thisTree.nodeCatsRight = [thisTree.nodeCatsRight zeros(1,numTotalSegs-1)];

if topCorr==2
    catCEE = -sum(sum(thisTree.nodeLabels(:,nonVoidSegs).*log(thisTree.catOut(:,nonVoidSegs))));
    % minimize this cost/error later
    thisTree.cost = catCEE;
end

newParentIndex = numTotalSegs+1;
while newParentIndex<=numTotalSuperSegs
    
    if topCorr<2
        [thisScore ind] = max(scores);
        
    else%if topCorr==2
        stillGoodCollapses = any(pairGood);
        if stillGoodCollapses
            scores(~pairGood) = -Inf;
        end
        [thisScore ind] = max(scores);
    end
    
    % add to score which we want to maximize
    thisTree.score = thisTree.score+thisScore;
    newSegHid = pairHid(:,ind);
    
    % find kids of best merge
    kids = allPairsNum(:,ind);
    
    % add parent to tree datastructure
    thisTree.pp(kids) = newParentIndex ;
    thisTree.kids(newParentIndex,:) = kids';
    thisTree.nodeNames(newParentIndex) = newParentIndex;
    thisTree.nodeFeatures(:,newParentIndex) = newSegHid;
    thisTree.nodeLabels(:,newParentIndex) = thisTree.nodeLabels(:,kids(1)) + thisTree.nodeLabels(:,kids(2));
    
    % compute category/label activation of this new node
    thisTree.catAct(:,newParentIndex) = Wcat*[newSegHid ;1 ];
    thisTree.catOut(:,newParentIndex) = softmax(thisTree.catAct(:,newParentIndex));
    [prob catNew] = max(thisTree.catOut(:,newParentIndex));
    thisTree.nodeCat(newParentIndex) = catNew;
    correctNodeLabels = thisTree.nodeLabels(:,newParentIndex);
    % nodes are only "right" if they have 1 label in the ground truth!
    if sum(correctNodeLabels>0)==1
        thisTree.nodeCatsRight(newParentIndex) = catNew==find(correctNodeLabels);
    end
    % for funky multi-label nodes, it might still make sense to predict their leaf nodes' label distribution
    if topCorr==2
        labelsTrue = thisTree.nodeLabels(:,newParentIndex);
        if any(labelsTrue)
            labelDistribution = labelsTrue./sum(labelsTrue);
            newCEE = -sum(labelDistribution.*log(thisTree.catOut(:,newParentIndex)));
            thisTree.cost = thisTree.cost+newCEE;
        end
    end
    
    adj(newParentIndex,:) = adj(kids(1),:) | adj(kids(2),:);
    adj(:,newParentIndex) = adj(newParentIndex,:)';
    
    % delete pairs in pairHid that have either of the kids anywhere and from the adj matrix
    delete = allPairsNum==kids(1) | allPairsNum==kids(2);
    delete = any(delete);
    allPairsNum(:,delete)=[];
    allPairs(:,delete)=[];
    pairHid(:,delete)=[];
    scores(:,delete)=[];
    pairGood(delete)=[];
    
    
    
    adj(kids(1),:) = 0;
    adj(:,kids(1)) = 0;
    adj(kids(2),:) = 0;
    adj(:,kids(2)) = 0;
    
    % add new pairs to set of pairs with scores
    newSegsNeighbors = find(adj(newParentIndex,:));
    if ~isempty(newSegsNeighbors)
        newPairsNum = zeros(length(newSegsNeighbors),2);
        newPairsNum(:,1) = newParentIndex;
        newPairsNum(:,2) = newSegsNeighbors';
        
        allPairsNum=[allPairsNum newPairsNum'];
        
        newPairs = [thisTree.nodeFeatures(:,newPairsNum(:,1)) ; thisTree.nodeFeatures(:,newPairsNum(:,2))];
        allPairs=[allPairs newPairs];
        
        newHidCand = params.f(W * [newPairs; ones(1,length(newSegsNeighbors))]);
        pairHid = [pairHid newHidCand ];
        
        newGoodness = thisTree.nodeLabels(:,newPairsNum(:,1)) + thisTree.nodeLabels(:,newPairsNum(:,2));
        newGoodness = newGoodness>0;
        newGoodness = sum(newGoodness)==1;
        pairGood = [pairGood newGoodness];
        
        newScores = Wout*newHidCand;
        if topCorr==1
            % add structure loss penalization for incorrect decisions (to chose them and decrease their scores)
            % (we should only add this if there are other good decisions left)
            addPenToScores = params.LossPerError * ~newGoodness;
            newScores = newScores+addPenToScores;
        end
        scores = [scores newScores];
        
        
    end
    
    newParentIndex = newParentIndex+1;
end
