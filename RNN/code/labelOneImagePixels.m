function [correctPixels totalPixels] = labelOneImagePixels(imgData,imgTreeTop)

numLeafNodes = size(imgData.adj,1);

outImg = zeros(size(imgData.segs2,1),size(imgData.segs2,2));

for s = 1:numLeafNodes
    finalLabelProbs = imgTreeTop.catOut(:,s);
    % collect all parent indices
    
    [~,thisSegLabel]= max(finalLabelProbs);
    outImg(imgData.segs2==s) = thisSegLabel;
end

correctTestImg = outImg==imgData.labels;
correctPixels = sum(correctTestImg(:));
% ignore 0 = void labels in total count (like Gould et al.)
% (we never predict 0 either)
totalPixels = sum(sum(imgData.labels>0));

