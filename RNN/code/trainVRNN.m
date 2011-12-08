%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright by Richard Socher
% For questions, email richard @ socher .org
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('tools/'));

% set to 1 if you have <5GB RAM or you just want to see what's going on for debugging/studying
tinyDatasetDebug = 1;

%%%%%%%%%%%%%%%%%%%%%%
% data set: stanford background data set from Gould et al.
mainDataSet = 'iccv09-1'
setDataFolders

%%%%%%%%%%%%%%%%%%%%%%%
% minfunc options (not tuned)
options.Method = 'lbfgs';
options.MaxIter = 1000;
optionsPT=options;
options.TolX = 1e-4;


%%%%%%%%%%%%%%%%%%%%%%%
%iccv09: 0 void   1,1 sky  0,2 tree   2,3 road  1,4 grass  1,5 water  1,6 building  2,7 mountain 2,8 foreground
set(0,'RecursionLimit',1000);
params.numLabels = 8; % we never predict 0 (void)
params.numFeat = 119;


%%%%%%%%%%%%%%%%%%%%%%
% model parameters (should be ok, found via CV)
params.numHid = 50;
params.regPTC = 0.0001;
params.regC = params.regPTC;
params.LossPerError = 0.05;

%sigmoid activation function:
params.f = @(x) (1./(1 + exp(-x)));
params.df = @(z) (z .* (1 - z));


%%%%%%%%%%%%%%%%%%%%%%
% input and output file names
neighNameStem = ['../data/' mainDataSet '-allNeighborPairs'];
if tinyDatasetDebug
    neighName = [neighNameStem '_' dataSet '_tiny.mat'];
else
    neighName = [neighNameStem '_' dataSet '.mat'];
end
neighNameEval = [neighNameStem '_' dataSetEval '.mat'];

paramString = ['_hid' num2str(params.numHid ) '_PTC' num2str(params.regPTC)];
fullParamNameBegin = ['../output/' mainDataSet '_fullParams'];
paramString = [paramString '_fullC' num2str(params.regC) '_L' num2str(params.LossPerError)];
fullTrainParamName = [fullParamNameBegin paramString '.mat'];
disp(['fullTrainParamName=' fullTrainParamName ])


%%%%%%%%%%%%%%%%%%%%%%
% load and pre-process training and testing dataset
% the resulting files are provided
if ~exist(neighName,'file')
    %%% first run preProData once for both train and eval!
    dataSet='train';
    preProSegFeatsAndSave(dataFolder,neighNameStem,trainList, neighName, dataSet, params,mainDataSet)
    dataSet='eval';
    preProSegFeatsAndSave(dataFolder,neighNameStem,evalList, neighNameEval, dataSet, params,mainDataSet)
end

if ~exist('allData','var')
    load(neighName,'allData','goodPairsL','goodPairsR','badPairsL','badPairsR','onlyGoodL','onlyGoodR','onlyGoodLabels','allSegs','allSegLabels');
    evalSet=load(neighNameEval,'allData','goodPairsL','goodPairsR','badPairsL','badPairsR','onlyGoodL','onlyGoodR','onlyGoodLabels','allSegs','allSegLabels');
end

% start a matlab pool to use all CPU cores for full tree training
if isunix && matlabpool('size') == 0
    numCores = feature('numCores')
    if numCores==16
        numCores=8
    end
    matlabpool('open',numCores);
end


%%%%%%%%%%%%%%%%%%%%%%
% initialize parameters
initParams

%%%%%%%%%%%%%%%%%%%%%%
% TRAINING

% train Wbot layer and first RNN collapsing decisions with all possible correct and incorrect segment pairs
% this uses the training data more efficiently than the purely greedy full parser training that only looks at some pairs
% both could have been combined into one training as well.
[X decodeInfo] = param2stack(Wbot,W,Wout,Wcat);
X = minFunc(@costFctInitWithCat,X,optionsPT,decodeInfo,goodPairsL,goodPairsR,badPairsL,badPairsR,onlyGoodL,onlyGoodR,onlyGoodLabels,allSegs,allSegLabels,params);

X = minFunc(@costFctFull,X,options,decodeInfo,allData,params);
[Wbot,W,Wout,Wcat] = stack2param(X, decodeInfo);
save(fullTrainParamName,'Wbot','W','Wout','Wcat','params','options')


%%%%%%%%%%%%%%%%%%%%%
% run analysis
testVRNN

% visualize trees
visualizeImageTrees
