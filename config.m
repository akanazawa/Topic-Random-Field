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

%%%%
%% GLOBAL PARAMETERS
%%%%

%% Feature representation of all images
% should be a numImages x 1 cell array where each cell stores N_d x S matrix where N_d is the number of segments in image d, and S is the length of the feature vector
Global.All_features = [DATA_DIR, 'allFeatures.mat'];

%% model parameters saved
Global.Model_name = [DATA_DIR, 'TRF_model.mat'];

%%%%%
%% OVERSEGMENATAION SETTINGS
%%%%%

%%%%%
%% FEATURE EXTRACTION SETTINGS
%%%%%
Feature.length = 1000;

%%%%%
%% LEARNING SETTINGS
%%%%%

% Number of K neighbors in making MRF
Learn.Num_Neighbors = 2;

% How many topics in TRF
Learn.Num_Topics = 2;

% How many prototypes in a topic
Learn.Num_Prototypes = 2;

% Max number of VB-EM iterations
Learn.Max_Iterations  = 100;

% Max number of VB-EM iterations for a document
Learn.Doc_Max_Iterations = 20;

%%%%%
%% EXPERIMENT SETTINGS
%%%%%
%% relative sizes of training and test sets 
%% 0.5 = equal; <0.5 = more testing; >0.5 = more training
Experiment.Train_Test_Portion = 0.5;



