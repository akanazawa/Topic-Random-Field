%%%%%%%%%%%%%%%%%%%%
% The global configuration file 
% Holds all settings used in all parts of the TRF, enabling the exact
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

trainListName = [DATA_DIR,'trainList.txt'];
evalListName = [DATA_DIR,'evalList.txt'];

allData_fname = [DATA_DIR,'iccv09-1-allNeighborPairs_train_tiny.mat'];
evalData_fname = [DATA_DIR,'iccv09-1-allNeighborPairs_train_tiny.mat']; %'iccv09-1-allNeighborPairs_eval.mat"
%%%%
%% GLOBAL PARAMETERS
%%%%

%% Feature representation of all images
% DEPRECIATED: should be a numImages x 1 cell array where each cell stores N_d x S matrix where N_d is the number of segments in image d, and S is the length of the feature vector
% NOW, FOLLOWING RNN FORMAT:
% the data is in format:
% allData{1}:
%           img: [240x320x3 uint8]
%        labels: [240x320 double]
%         segs2: [240x320 double]
%         feat2: [115x119 double]
%     segLabels: [115x1 double]
%           adj: [115x115 logical]


%% model parameters saved
model_name = [DATA_DIR, 'TRF_model.mat'];

%%%%%
%% OVERSEGMENATAION SETTINGS
%%%%%

%%%%%
%% FEATURE EXTRACTION SETTINGS
%%%%%


%%%%%
%% LEARNING SETTINGS
%%%%%

% Number of K neighbors in making MRF
Learn.Num_Neighbors = 4;

% How many topics in TRF
Learn.Num_Topics = 3;

% How many prototypes in a topic
Learn.Num_Prototypes = 2;

% Max number of VB-EM iterations
Learn.Max_Iterations  = 100;

% Max number of VB-EM iterations for a document
Learn.V_Max_Iterations = 20;

%%%%%
%% EXPERIMENT SETTINGS
%%%%%
