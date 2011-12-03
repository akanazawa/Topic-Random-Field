function do_all(config)
%%%%%%%%%%%%%%%%%%%%
% do_all.m
% The top-level script for the implementation of TRF
% Overall routine that does everything, call this with 
% See the comments in each do_ routine for details of what it does
%%%%%%%%%%%%%%%%%%%%

% generate random indices for training and test frames
%do_random_indices(config);

% over segment each images
do_overSegmentImages(config);

% Extract features from each images
do_extractFeatures(config);
    
% run TRF to learn the model
do_trf(config);
    
% test model
do_trf_evaluation(config);
    
    
