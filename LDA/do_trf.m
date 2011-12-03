function [alpha,beta] = do_trf(train,k,emmax,demmax)
% wrapper of Topic Random Model based on LDA, the standard model (no gibbs sampling).
% [alpha,beta] = ldamain(train,k,[emmax,demmax])
% $Id: ldamain.m,v 1.1 2004/11/08 12:41:58 dmochiha Exp $
% d      : data of documents
% k      : # of classes to assume
% emmax  : # of maximum VB-EM iteration (default 100)
% demmax : # of maximum VB-EM iteration for a document (default 20)

%% Evaluate global configuration file and load parameters
eval(config_file);

% load data computed previously by do_extractFeatures.m
% should be a numImages long cell array where each cell stores N_d (number of segments) by S, the length of the feature vector
data = load(Global.AllFeatures_Name);

