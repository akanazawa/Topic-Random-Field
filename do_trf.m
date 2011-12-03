function [alpha,beta] = do_trf(train,k,emmax,demmax)
% wrapper of Topic Random Model based on LDA, the standard model (no gibbs sampling).

%% Evaluate global configuration file and load parameters
eval(config_file);

% load data computed previously by do_extractFeatures.m
% should be a numImages long cell array where each cell stores N_d (number of segments) by S, the length of the feature vector
data = load(Global.AllFeatures_Name);

%%% Call the actual EM routine
[alpha,sig,beta,mu,delta] = trf(data,Learn);

%%% save the model and parameters used
save(Global.Model_name,'alpha','sig','beta','mu','delta', 'Global','Learn');
