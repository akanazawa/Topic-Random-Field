function do_all_trf(config)
%%%%%%%%%%%%%%%%%%%%
% do_all.m
% The top-level script for the implementation of TRF
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

% the data is in format:
% data{1}:
%           img: [240x320x3 uint8]
%        labels: [240x320 double]
%         segs2: [240x320 double]
%         feat2: [115x119 double]
%     segLabels: [115x1 double]
%           adj: [115x115 logical]


% over segment each images 
% for each d images, oversegment
%do_overSegmentImages(config);

% Extract features from each images
%do_extractFeatures(config);

% run TRF to learn the model
do_trf(config);
    
% test model
do_trf_evaluation(config);
    
    
