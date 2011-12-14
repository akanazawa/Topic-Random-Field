function do_all(config)
%%%%%%%%%%%%%%%%%%%%
% do_all.m
% The top-level script for the implementation of LDA + MRF
% Overall routine that does everything, call this with 
% See the comments in each do_ routine for details of what it does
%%%%%%%%%%%%%%%%%%%%

% start a matlab pool to use all CPU cores for full tree training
% if isunix && matlabpool('size') == 0
%     numCores = feature('numCores')
%     if numCores==16
%         numCores=8
%     end
%     matlabpool('open',numCores);
% end

% over segment each images 
% for each d images, oversegment
%do_overSegmentImages(config);

% VQ features
do_VQ(config);
 
% run TRF to learn the model
%do_trf(config);

% run LDA-MRF to learn the model
do_lda_mrf(config);


    
% test model
%do_trf_evaluation(config);
do_lda_mrf_evaluation(config);
    
