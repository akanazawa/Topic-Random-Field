function do_trf_evaluation(config_file)

%% Test and plot graphs for a plsa model learnt with do_plsa.m

%% Runs the pLSA procedure, this time holding P(w|z) constant and
%% estimating P(d|z) using a "folding in" procedure. Calls code written
%% by Josef Sivic (josef@robots.ox.ac.uk), based on the paper:
%% 
%%  J. Sivic, B. C. Russell, A. Efros, A. Zisserman and W. T. Freeman,
%%  Discovering objects and their location in images, ICCV 2005.

%% The action of this routine depends on the directory in which it is
%% run: 
%% (a) If run from RUN_DIR, then it will evaluate the latest model in the
%% models subdirectory. i.e. if you have just run
%% do_plsa('config_file_2'), which saved to model_0011.mat and
%% config_file_0011.m in the models subdirectory in RUN_DIR, then doing
%% do_plsa_evaluation('config_file_2') will load up model_0011.mat and
%% evaluate it. 
%% (b) If run within in models subdirectory, then it
%% will evaluate the model corresponding to the configuration file passed
%% to it. i.e. do_plsa_evaluation('config_file_0002') will load
%% model_0002.mat and evaluate/plot figures for it. 
%%  
%% Mode (a) exists to allow a complete experiment to be run from start to
%% finish without having to manually go into the models subdirectory and
%% find the appropriate one to evaluate.
  
%% If this routine is called on a newly learnt model, it will run the pLSA code
%% in folding in mode and then plot lots of figures. If run a second time
%% on the same model, it will only plot the figures, since there is no need
%% to recompute the P(d|z) on the testing images. If you want to force it
%% to re-run on the images, then remove the Pd_z_test variable from the
%% model file. 
  
%% Note this only uses a pre-existing model to evaluate the test
%% images. Please use do_plsa to actually learn a pLSA model.  
  
%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file.
%%    do_preprocessing - to get the images that the operator will run on.  
%%    do_interest_op  - to get extract interest points (x,y,scale) from each image.
%%    do_representation - to get appearance descriptors of the regions.  
%%    do_vq - vector quantize appearance of the regions in each image.
%%    do_plsa - learn a pLSA model.
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
 
  
%%% figure number to start plotting at  
FIGURE_BASE = 1000;
%%% color order
cols = {'r' 'g' 'b' 'c' 'm' 'y' 'k'};

%% Evaluate global configuration file
eval(config_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Model section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% get filename of model to learn
%%% if in models subdirectory then just get index off config_file string
if (strcmp(pwd,[RUN_DIR,'/',Global.Model_Dir_Name]) | strcmp(pwd,[RUN_DIR,'\',Global.Model_Dir_Name]))
    ind = str2num(config_file(end-Global.Num_Zeros+1:end));
else
    %%% otherwise just take newest model in subdir.
    ind = length(dir([RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,'*.mat']));    
end
%%% construct model file name
model_fname = [RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,prefZeros(ind,Global.Num_Zeros),'.mat'];

%%% load up model
load(model_fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test section - run model on testing images only if Pd_z_test does not exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('Pd_z_test') %%% only do this section the first time we look at the model
                       %%% saves time if we just want to look at the pretty
                       %%% figures
    
    %% get all file names of testing image interest point files.
    ip_file_names =  genFileNames({Global.Interest_Dir_Name},Categories.All_Test_Frames,RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);

    %% Create matrix to hold word histograms from all images
    X = zeros(VQ.Codebook_Size,length(Categories.All_Test_Frames));

    %% load up all interest_point files which should have the histogram
    %% variable already computed (performed by do_vq routine).
    for a=1:length(ip_file_names)
        %% load file
        load(ip_file_names{a});
        %% store histogram
        X(:,a) = histogram';    
    end 

    %%% Call actual EM routine again in test mode
    [Pw_z,Pd_z_test,Pz_test,Li_test] = pLSA_EM(X,Pw_z,Learn.Num_Topics,Learn);

    %%% get labels for test frames
    labels = [];
    for a=1:Categories.Number
        labels = [labels , Categories.Labels(a)*ones(1,length(Categories.Test_Frames{a}))];
    end
   
    %%% compute classification performance for each topic
    for t=1:Learn.Num_Topics
        %%% get scores for each image
        values = Pd_z_test(:,t)';
        %%% compute roc
        [roc_curve{t},roc_op(t),roc_area(t),roc_threshold(t)] = roc([values;labels]');
        %%% compute rpc
        [rpc_curve{t},rpc_ap(t),rpc_area(t),rpc_threshold(t)] = recall_precision_curve([values;labels]',length(find(labels==1)));
    end 

    %%% store all test variables in the model
    save(model_fname,'Pd_z_test','Pz_test','Li_test','roc_curve','roc_op','roc_area','roc_threshold','rpc_curve','rpc_ap','rpc_area','rpc_threshold','-append');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting section - plot some figures to see what is going on...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% We will use figures from FIGURE_BASE to FIGURE_BASE + 4;
%% clear them ready for plotting action...
for a=FIGURE_BASE:FIGURE_BASE+4
    figure(a); clf;
end

%% Plot Pw_z as an image - to get an idea of overall entropy
figure(FIGURE_BASE);
imagesc(Pw_z); colormap(gray); colorbar;
set(gca,'XTick',[1:Learn.Num_Topics]);
xlabel('Topic'); ylabel('Word'); title('Pw|z density');

%% Plot Pd_z as an image - to get an idea of overall entropy
figure(FIGURE_BASE+1);
imagesc(Pd_z); colormap(gray); colorbar;
set(gca,'XTick',[1:Learn.Num_Topics]);
xlabel('Topic'); ylabel('Image'); title('Pd|z density');

%% Now lets look at the classification performance
figure(FIGURE_BASE+2);
for t=1:Learn.Num_Topics
    plot(roc_curve{t}(:,1),roc_curve{t}(:,2),cols{rem(t-1,7)+1});
    hold on;
end 
axis([0 1 0 1]); axis square; grid on;
xlabel('P_{fa}'); ylabel('P_d'); title('ROC Curves');

%% Now lets look at the retrieval performance
figure(FIGURE_BASE+3);
for t=1:Learn.Num_Topics
    plot(rpc_curve{t}(:,1),rpc_curve{t}(:,2),cols{rem(t-1,7)+1});
    hold on;
end 
axis([0 1 0 1]); axis square; grid on;
xlabel('Recall'); ylabel('Precision'); title('RPC Curves');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Now plot out example images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% what crietrion are we going to use to choose the best topic?
if strcmp(Recog.Best_Topic_Criterion,'roc_area')
    topic_scores = roc_area;
    topic_thresholds = roc_threshold;
elseif strcmp(Recog.Best_Topic_Criterion,'roc_op')
    topic_scores = roc_op;
    topic_thresholds = roc_threshold;   
elseif strcmp(Recog.Best_Topic_Criterion,'rpc_ap')
    topic_scores = rpc_ap;
    topic_thresholds = rpc_threshold;    
elseif strcmp(Recog.Best_Topic_Criterion,'rpc_area')
    topic_scores = rpc_area;
    topic_thresholds = rpc_threshold;
else
    error('Unknown criterion for picking the best topic');
end

%% first decide on plotting order
if strcmp(Plot.Example_Mode,'ordered')
    %%% just go in orginial order of images
    plot_order = sort(Categories.All_Test_Frames);
elseif strcmp(Plot.Example_Mode,'alternate')
    %%% using random order but alternating between images of different
    %%% classes...
    ind = ones(Categories.Number,max(cellfun('length',Categories.Test_Frames)));
    tmp = length(Categories.Test_Frames{1});
    ind(1,1:tmp)=[1:tmp];
    for a=2:Categories.Number
        tmp = length(Categories.Test_Frames{a});
        offset=sum(cellfun('length',Categories.Test_Frames(1:a-1)));
        ind(a,1:tmp) = [1:tmp]+offset;
   end
   plot_order = ind(:);
   
elseif strcmp(Plot.Example_Mode,'random')
    %%% using order given in random_indices.mat
    plot_order = Categories.All_Test_Frames;
elseif strcmp(Plot.Example_Mode,'best')
    %%% plot ordered by score on best topic
    [tmp,best_topic]  = max(topic_scores);
    [tmp2,plot_order] = sort(-Pd_z(:,best_topic));
elseif strcmp(Plot.Example_Mode,'worst')
    %%% plot ordered by score on worst topic
    [tmp,best_topic]  = max(topic_scores);
    [tmp2,plot_order] = sort(Pd_z(:,best_topic));    
elseif strcmp(Plot.Example_Mode,'borderline')
    %%% images closest to threshold
    [tmp,best_topic]  = max(topic_scores);
    %%% ordering by how close they are to the topic_thresholds...
    [tmp2,plot_order] = sort(abs(Pd_z(:,best_topic)-topic_thresholds(best_topic)));
else
    error('Unknown type of Plot.Example_Mode');
end 

%% Get image filenames and ip filenames
image_file_names =  genFileNames({Global.Image_Dir_Name},Categories.All_Test_Frames,RUN_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);
ip_file_names =  genFileNames({Global.Interest_Dir_Name},Categories.All_Test_Frames,RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);

%%% get labels for test frames
labels = [];
for a=1:Categories.Number
    labels = [labels , Categories.Labels(a)*ones(1,length(Categories.Test_Frames{a}))];
end
    
%% now setup figure and run loop plotting images
figure(FIGURE_BASE+4);
nImage_Per_Figure = prod(Plot.Number_Per_Figure);

for a=1:nImage_Per_Figure:length(Categories.All_Test_Frames)
    
    clf; %% clear figure
    
    for b=1:nImage_Per_Figure
        
        %%% actual index
        index = plot_order(a+b-1);
        
        %%% get correct subplot
        subplot(Plot.Number_Per_Figure(1),Plot.Number_Per_Figure(2),b);
        
        %%% load image
        im=imread(image_file_names{index});
        
        %%% show image
        imagesc(im); hold on;
        
        %%% if grayscale, then adjust colormap
        if (size(im,3)==1)
            colormap(gray);
        end 
        
        %%% load up interest_point file
        load(ip_file_names{index});
        
        %%% loop over all regions, plotting and coloring according to Pw_z
        for c=1:length(x)
            %%% which topic is favoured by the region?
            [tmp,preferred_topic]=max(Pw_z(descriptor_vq(c),:));
            %%% plot center of region
            plot(x(c),y(c),'Marker','+','MarkerEdgeColor',cols{rem(preferred_topic-1,7)+1});
            %%% and circle showing scale
            drawcircle(y(c),x(c),2*scale(c)+1,cols{rem(preferred_topic-1,7)+1},1);
            hold on;    
        end
        
        %%% do we plot header information?
        if (Plot.Labels)
           
            %% get Pz_d for image, from Pd_z
            %% now get joint
            Pdz_test = Pd_z_test(index,:) .* Pz_test;
            Pz_d_test = Pdz_test / sum(Pdz_test);
            
            %% Label according to correct/incorrect classification
            %% is image above threshold?
            
            [tmp,best_topic]  = max(topic_scores);
            above_threshold = (Pd_z(index,best_topic)>topic_thresholds(best_topic));
            
            if (above_threshold==labels(index)) %% Correct classification    
                %% show image number and Pz_d
                title(['Correct - Image: ',num2str(index),' P(z|d)=',num2str(Pz_d_test)]);    
            else
                %% show image number and Pz_d
                title(['INCORRECT - Image: ',num2str(index),' P(z|d)=',num2str(Pz_d_test)]);    
            end
            
            fprintf('Image: %d \t Score: %f \t Threshold: %f\n',index,Pd_z(index,best_topic),topic_thresholds(best_topic));
        end
    end
    
    pause
    
end 
