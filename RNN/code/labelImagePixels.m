function [allResults allResultString] = labelImagePixels(allData,Wbot,W,Wout,Wcat,params)

allResults=[];

allTrees = cell(1,length(allData));
parfor i = 1:length(allData)
    if length(allData{i}.segLabels)~=size(allData{i}.feat2,1)
        disp(['Image ' num2str(i) ' has faulty data, skipping!'])
        continue
    end
    topCorr=0;
    imgTreeTop = parseImage(topCorr,Wbot,W,Wout,Wcat,allData{i}.adj, allData{i}.feat2,allData{i}.segLabels,params);
    allTrees{i} = imgTreeTop;
end


allCorrectPixels = 0;
allPixels = 0;
for i = 1:length(allData)
    if length(allData{i}.segLabels)~=size(allData{i}.feat2,1)
        disp(['Image ' num2str(i) ' has faulty data, skipping!'])
        continue
    end
    [correctPixels totalPixelsImg] = labelOneImagePixels(allData{i},allTrees{i});
    allCorrectPixels = allCorrectPixels + correctPixels ;
    allPixels = allPixels + totalPixelsImg;
    if mod(i,10)==0
        disp(['Done with computing image ' num2str(i)]);
    end
end
acc = allCorrectPixels/allPixels
allResults = [allResults ; acc];
allResultString = sprintf('a:%f',acc);
