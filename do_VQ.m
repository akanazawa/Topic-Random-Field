function do_VQ(config_file)
%%%%%%%%%%
% do_VQ.m
% assuming data is in format:
% the data is a cell array of fields:
%           img: [H x W x 3 uint8]
%        labels: [H x W  double]
%         segs2: [H x W  double]
%         feat2: [Nd x M double]
%     segLabels: [Nd x 1 double]
%           adj: [Nd x Nd logical]
%
% adds field vq [Nd x 1] and vq_count [Nd x 1] to this data, 
%
% Angjoo Kanazawa 12/13/2011

%% Evaluate global configuration file and load parameters
eval(config_file);

% do only if this hasn't been computed already
if exist(allData_fname)
    return;
end

%% load data computed previously
load(allData_fname_original,'allData');

M = size(allData{1}.feat2, 2); % length of feature vector
D = length(allData);
%% vocabulary exist?
if ~exist(VQ.vocabulary_f)
    feat = [];
    for d = 1:D
        feat = [ feat allData{d}.feat2']; % everything in vl_feat is col wise
    end
    % Just use some to build the vocab (using all has minimal
    % performance improvements)
    descriptors = single(vl_colsubset(feat, 150, 'uniform'));
    vocabulary.words = vl_kmeans(descriptors, VQ.Num_Vocab, 'verbose', 'algorithm', 'elkan') ;
    vocabulary.kdtree = vl_kdtreebuild(vocabulary.words) ;   
    fprintf('vocabulary built..\n');
    save(VQ.vocabulary_f, 'vocabulary');
else
    load(VQ.vocabulary_f);
end

%% VQ all

for d = 1:D
    allData{d}.vq = vl_kdtreequery(vocabulary.kdtree, ...
                                   vocabulary.words,single(allData{d}.feat2'));
    [uniques, numUnique] = count_unique(double(allData{d}.vq));
    % save the frequency count
    allData{d}.vq_count = zeros(VQ.Num_Vocab, 1);
    allData{d}.vq_count(uniques) = numUnique;
end

% save it
save(allData_fname, 'allData');
