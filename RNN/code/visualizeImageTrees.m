% visualizeImageTrees

%if data and parameters are already loaded from trainVRNN
%fullTrainParamName
%load(fullTrainParamName,'Wbot','W','Wout')

if ~exist('visuFolder','var')
    visuFolder = '../output/visualization/';
end


for i = 1:length(evalSet.allData)
    visualizeOneTreeImg(evalSet.allData{i},Wbot,W,Wout,Wcat,params,visuFolder,i,1)
    disp(['Done with visualizing image ' num2str(i)]);
end



