function do_trf_evaluation(config_file)
%%%%%%%%%%
% do_trf_evaluation.m
% using the TRF model learnt in do_trf.m, label each region with
% most likely topic. i.e:
%  argmax_{z_r^d} P(x_r^d|z_r^d)
%
%%%%%%%%%%

%% Evaluate global configuration file
eval(config_file);

%%% Load data and parameters
evalSet=load(evalData_fname,'allData','allSegs','allSegLabels');

load(model_name,'alpha','sig','beta','mu','delta', 'Learn');

allResults = cells(1,length(allData));

for i = 1:length(allData)
    %  label all regions, save in allResults
    
end

