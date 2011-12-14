function [alpha,beta] = do_lda_mrf(config_file)
%%%%%%%%%%
% do_lda_mrf.m
% wrapper of LDA+MRF, on oversegmented regions, MRF as a prior on
% topic distribution.
%
% Angjoo Kanazawa
%%%%%%%%%%


%% Evaluate global configuration file and load parameters
eval(config_file);

%% load data computed previously by do_extractFeatures.m
load(allData_fname,'allData');


%% add MRF information making adjacency matrix if it doesn't exist
%[allDataMRF] = initMRF(allData);

%% Call the actual EM routine
[alpha, beta, sig] = lda_mrf(allData,Learn, VQ);

%%% save the model and parameters used
save(model_name,'alpha','beta','sig','Learn', 'VQ');
