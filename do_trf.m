function [alpha,beta] = do_trf(train,k,emmax,demmax)
%%%%%%%%%%
% do_trf.m
% wrapper of Topic Random Model based on LDA, the standard model (no gibbs sampling).
%
%% the data is in format:
% allData{1}:
%           img: [240x320x3 uint8]
%        labels: [240x320 double]
%         segs2: [240x320 double]
%         feat2: [115x119 double]
%     segLabels: [115x1 double]
%           adj: [115x115 logical]
%%%%%%%%%%


%% Evaluate global configuration file and load parameters
val(config_file);

% load data computed previously by do_extractFeatures.m
load(allData_fname,'allData','goodPairsL','goodPairsR','badPairsL','badPairsR','onlyGoodL','onlyGoodR','onlyGoodLabels','allSegs','allSegLabels');

%%% Call the actual EM routine
[alpha,sig,beta,mu,delta] = trf(allData,Learn);

%%% save the model and parameters used
save(model_name,'alpha','sig','beta','mu','delta','Learn');
