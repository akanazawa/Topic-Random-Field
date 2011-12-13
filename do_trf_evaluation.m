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

allResults = cell(1,length(allData));

K = Learn.Num_Topics;
L = Learn.Num_Prototypes;
% for all data, label all regions, save in allResults
for d = 1:length(allData)
    dfeat = allData{d}.feat2;
    Nd = length(allData{d}.segLabels); % number of regions    
    [gamma, xi, rho, lambda] = vbem(allData{d}, beta, alpha, mu, delta, ...
                                    sig, Learn); 
    % rho is Nd x K corresponding to the topic distribution
    [bestScore, zs] = max(rho, [], 2);
    pred_segLabels = zs;
end    

    % dfeat = allData{d}.feat2;
    % Nd = length(allData{d}.segLabels); % number of regions
    % pred_segLabels = zeros(Nd,1);                             
    % for n=1:Nd
    %     dn = dfeat(n,:)'; % (m x 1)
    %     ks = zeros(K,1);
    %     for k = 1:K
    %         score = 1;
    %         for l=1:L
    %             px_udel = exp(-(dn-squeeze(mu(l,k, :)))'*...
    %                           (dn-squeeze(mu(l,k, :)))/(2*delta(l,k).^2) );        
    %             score = beta(l,k)*px_udel;                
    %         end
    %         ks(k) = score;
    %     end
    %     ks;
    %     [bestScore, z] = max(ks);
    %     pred_segLabels(n) = z;
    % end    


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

