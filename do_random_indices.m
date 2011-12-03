function do_random_indices(config_file)

%% Routine randomly partitions the frame indices into training and test
%% saving the files into the file RUNDIR/random_indices.mat

%% This routine should be run before any other do_ routines since they
%% will require the presence of the random_indices.mat file  

%%% R.Fergus (fergus@csail.mit.edu)  03/10/05.    
  
%% Evaluate global configuration file
%% the try-catch statement is needed, otherwise the error message about
%% random_indices.mat not being present will stop the execution of the routine
try
  eval(config_file);
catch
end
  
%% Check that Categories.Train_Test_Potion is sensible
if ((Categories.Train_Test_Portion<=0) | (Categories.Train_Test_Portion>=1))
  error('Categories.Train_Test_Potion should be greater than 0 and less than 1');
end
    
      
for a=1:length(Categories.Name) %% loop over each category...
  
  %%% randomly choose indices for training and test...
  random_indices{a} = randperm(length(Categories.Frame_Range{a}));
  
  %%% get number of training and testing frames
  nTraining_Images = round( length(Categories.Frame_Range{a}) * Categories.Train_Test_Portion);
  nTesting_Images  = length( Categories.Frame_Range{a} ) - nTraining_Images;
  
  %%% separate frames out into training and testing.....
  train_frames{a} = random_indices{a}(1:nTraining_Images);
  test_frames{a}  = random_indices{a}(nTraining_Images+1:nTraining_Images+nTesting_Images);

  %%% add offset seeing as all images from each class are in the same directory...
  if (a>1)
    train_frames{a} = train_frames{a} + sum(cellfun('length',Categories.Frame_Range(1:a-1)));
    test_frames{a}  = test_frames{a}  + sum(cellfun('length',Categories.Frame_Range(1:a-1)));    
  end
  
  if (nTraining_Images<=1)
    fprintf('Warning: too few training images allocated - please increase Train_Test_Portion\n');
  end   

  
  if (nTesting_Images<=1)
    fprintf('Warning: too few testing images allocated - please increase Train_Test_Portion\n');
  end
  
end


save([RUN_DIR , '/random_indices.mat'],'random_indices','train_frames','test_frames');
  
