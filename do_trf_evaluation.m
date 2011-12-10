function do_trf_evaluation(config_file)
%%%%%%%%%%
% do_trf_evaluation.m
% Test and evaluate TRF model learnt with do_trf.m
%%%%%%%%%%

%% Evaluate global configuration file
eval(config_file);

%%% Load data and parameters
evalSet=load(evalData_fname,'allData','goodPairsL','goodPairsR','badPairsL','badPairsR','onlyGoodL','onlyGoodR','onlyGoodLabels','allSegs','allSegLabels');

load(model_name,'alpha','sig','beta','mu','delta', 'Learn');

allResults = cells(1,length(allData));

for i = 1:length(allData)
    %  label all regions, save in allResults
    
end

