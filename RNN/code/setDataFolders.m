%setDataFolders

dataFolder = ['../data/' mainDataSet '/allInMatlab/'];
analysisFile = '../output/analysis.txt';
analysisFileFull = '../output/analysisPixelAcc_RELEASE.txt';

visuFolder = '../output/visualization/';
dataSet = 'train';
dataSetEval = 'eval';

% if isunix
%     disp('Full dataset on UNIX')
trainList = readTextFile(['../data/' mainDataSet '/' dataSet 'List.txt']);
evalList = readTextFile(['../data/' mainDataSet '/'  dataSetEval 'List.txt']);
% else
%     disp('Debug on Windows')
%     trainList = readTextFile(['../data/' mainDataSet '/' dataSet 'ListDEBUG.txt']);
%     evalList = readTextFile(['../data/' mainDataSet '/' dataSetEval 'ListDEBUG.txt']);
% end
