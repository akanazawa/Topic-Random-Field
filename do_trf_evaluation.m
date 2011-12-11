function do_trf_evaluation(config_file)
%%%%%%%%%%
% do_trf_evaluation.m
% using the TRF model learnt in do_trf.m, label each region with
% most likely topic. i.e:
% for each image d, we label region r_d with (z_r)* = argmax_{z_r} P(x_r|z_r)
% where p(x|z) = prod_L Beta(k,l)p(x|mu(k,l)*del(k,l))^(Sign(k & l))
%%%%%%%%%%

%% Evaluate global configuration file
eval(config_file);

%%% Load data and parameters
%evalSet=load(evalData_fname,'allData','allSegs','allSegLabels');
load(allData_fname,'allData','allSegs','allSegLabels');

load(model_name,'alpha','sig','beta','mu','delta', 'Learn');

allResults = cells(1,length(allData));
keyboard
for d = 1:length(allData)
    %  label all regions, save in allResults
    
    
end

