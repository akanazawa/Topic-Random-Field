function do_lda_mrf_evaluation(config_file)
%%%%%%%%%%
% do_lda_mrf_evaluation.m
% using the lda-mrf model learnt in do_lda_mrf.m, label each region with
% most likely topic. i.e:
% for each image d, we label region r_d with (z_r)* = argmax_{z_r} P(x_r|z_r)
%%%%%%%%%%

%% Evaluate global configuration file
eval(config_file);

%%% Load data and parameters
%evalSet=load(evalData_fname,'allData','allSegs','allSegLabels');
load(allData_fname,'allData');

load(model_name,'alpha','beta','sig', 'Learn');

allResults = cell(1,length(allData));

K = Learn.Num_Topics;
L = size(allData{1}.feat2, 2);
% for all data, label all regions, save in allResults
for d = 1:length(allData)
    dfeat = allData{d}.feat2;
    Nd = length(allData{d}.segLabels); % number of regions    
    [gamma,rho,lambda] = vbem(allData{d}, beta, alpha,sig, Learn); 
    keyboard
    %% rho is Nd x K corresponding to the topic distribution? 
    % [bestScore, zs] = max(rho,[], 2);
    % pred_segLabels = zs;
    %% or do log P(w | z, beta) 
    Nd = length(allData{d}.segLabels); % number of regions
    pred_segLabels = zeros(Nd,1);                             
    d = allData{d}.vq; % (Nd x 1)
    score = zeros(Nd, K);
    score = rho.*log(beta(:, d)');
    [bestScore, zs] = max(score,[], 2);
    pred_segLabels = zs;
   
end    



colmap = [...
    0.8000    0.8000    0.8000;... % 1 grey
    0.4196    0.5569    0.1373;... % 2 dark green
    0.5451    0.1333    0.3216;... % 3 VioletRed4
    0         1.0000         0;... % 4 normal green
    0         0    1.0000;... % 5 blue
    1.0000         0         0;... % 6 red
    0.5451    0.2706    0.0745;... % 7 SaddleBrown
    1.0000    0.6471         0;... % 8 Orange
         ];

d = 2;
sfigure; 
plot(pred_segLabels, 'r.'); hold on;
plot(allData{d}.segLabels, 'b.');
legend('prediction', 'truth');

% show the first one for now:
[h w] = size(allData{1}.img);
fullMask = zeros(h,w);
segMap = allData{1}.segs2;
seged = allData{1}.img;

for i = 1:Nd
    col = colmap(pred_segLabels(i),:);
    s = seged(:,:,1);
    s(segMap == i) = s(segMap == i)/3 + 100*col(1);
    seged(:,:,1) = s;
    s = seged(:,:,2);
    s(segMap == i) = s(segMap == i)/3 + 100*col(2);
    seged(:,:,2) = s;
    s = seged(:,:,3);
    s(segMap == i) = s(segMap == i)/3 + 100*col(3);
    seged(:,:,3) = s;
end
sfigure; 
imagesc(seged);

