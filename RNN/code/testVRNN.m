
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data and parameters if they aren't already loaded
if ~exist('Wbot','var')
    %fullTrainParamName = '../output/fullParams_hid50_PTC5e-05_zeroW35maxIterPT400_fullC0.001_L0.05maxIter150_CUT1_78.1.mat'
    fullTrainParamName = '../output/iccv09-1_fullParams_hid50_PTC0.0001_fullC0.0001_L0.05_good.mat'    
    load(fullTrainParamName,'Wbot','W','Wout','Wcat','params')
end

if ~exist('evalSet','var')
    mainDataSet = 'iccv09-1';
    neighNameStem = ['../data/' mainDataSet '-allNeighborPairs'];
    dataSetEval = 'eval';
    neighNameEval = [neighNameStem '_' dataSetEval '.mat'];
    
    evalSet=load(neighNameEval,'allData','goodPairsL','goodPairsR','badPairsL','badPairsR','onlyGoodL','onlyGoodR','onlyGoodLabels','allSegs','allSegLabels');
    analysisFileFull = '../output/analysisPixelAcc_RELEASE.txt';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[allResultsTEST outString] = labelImagePixels(evalSet.allData,Wbot,W,Wout,Wcat,params)

% analysis output
analOutBegin=sprintf('Full:%s\t%i\tPTC:%f\tC:%f\t%f\t%f', mainDataSet,params.numHid,params.regPTC,params.regC,params.LossPerError,norm(W));
analOut=sprintf('%s\t%s\n',analOutBegin, outString);
disp(analOut)
fid = fopen(analysisFileFull,'a');
fprintf(fid,'%s',analOut);
fclose(fid);
