function [cost,grad] = costFctFull(X,decodeInfo,allData,params)

numImg = length(allData);
numVars = length(X);
allCost = zeros(numImg,1);
allGrads = zeros(numImg,numVars);

parfor i = 1:numImg
    
    if length(allData{i}.segLabels)~=size(allData{i}.feat2,1)
        disp(['Image ' num2str(i) ' has faulty data!?'])
        numImg=numImg-1;
        continue
    end
    
    if length(allData{i}.segLabels)<3
       disp(['Image ' num2str(i) ' has too few segments, no tree needed.'])
       numImg=numImg-1;
       continue
    end
    
    [costImg gradImg] = computeRNNCostAndGrad(X,decodeInfo,allData{i},params);
    
    if costImg==0
       disp(['cost=0, ignoring tree ' num2str(i)])
       continue; 
    end
    
    allCost(i) = costImg;
    allGrads(i,:) = gradImg';    
end

cost = 1/numImg * sum(allCost) + params.regC/2 * sum(X.^2);

grad = 1/numImg *  sum(allGrads,1)' + params.regC * X;
