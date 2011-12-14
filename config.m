%%%%%%%%%%%%%%%%%%%%
% The global configuration file 
% Holds all settings used in all parts of LDA+MRF, enabling the exact
% reproduction of the experiment at some future date.

%%%%%
% DIRECTORIES
%%%%%

% Directory holding the experiment 
RUN_DIR = [ 'Topic-Random-Field' ];

% Directory holding all the source images
IMAGE_DIR = [ 'images/' ];

% Data directory - holds all intermediate .mat files
DATA_DIR = [ 'data/' ];   

allData_fname_original = [DATA_DIR,'../RNN/data/iccv09-1-allNeighborPairs_eval.mat'];
allData_fname = [DATA_DIR, 'stanford_vqed.mat'];
evalData_fname = [DATA_DIR,'iccv09-1-allNeighborPairs_train_tiny.mat']; 
%'iccv09-1-allNeighborPairs_eval.mat"

%%%%
%% GLOBAL PARAMETERS
%%%%

%% Feature representation of all images
% FOLLOWING RNN FORMAT:
% the data is a cell array of fields:
%           img: [H x W x 3 uint8]
%        labels: [H x W  double]
%         segs2: [H x W  double]
%         feat2: [Nd x M double]
%     segLabels: [Nd x 1 double]
%           adj: [Nd x Nd logical]
%            vq: [Nd x L ] 
% Where Nd is the number of regions for data d, M is the number of
% features, L is the length of the code book.

%% model parameters savedp
model_name = [DATA_DIR, 'LDA_MRF_model.mat'];

%%%%%
%% OVERSEGMENATAION SETTINGS
%%%%%

%%%%%
%% FEATURE EXTRACTION/VQ SETTINGS
%%%%%
VQ.vocabulary_f = [DATA_DIR, 'vocabulary.mat'];
VQ.Num_Vocab = 50; 

%%%%%
%% LEARNING SETTINGS
%%%%%

% Number of K neighbors in making MRF
Learn.Num_Neighbors = 4;

% How many topics in TRF
Learn.Num_Topics = 8;

% How many prototypes in a topic
Learn.Num_Prototypes = 3;

% Max number of VB-EM iterations
Learn.Max_Iterations  = 40;

% Max number of VB-EM iterations for a document
Learn.V_Max_Iterations = 20;

%%%%%
%% EXPERIMENT SETTINGS
%%%%%
