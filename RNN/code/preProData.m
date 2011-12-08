% preProData
% reads in images, features, and superpixel information from stephen gould's data

addpath(genpath('../../toolbox/'));

%dataset = '../data/iccv09/'
dataFolder = '../data/msrc/';


for asd=1:2
    
    if asd==1
        fileList = readTextFile([dataFolder 'evalList.txt']);
    else
        fileList = readTextFile([dataFolder 'trainList.txt']);
    end
    
    % evallist: 6000150 has faulty segmentation file, deleted for now :/
    saveFolder = [dataFolder 'allInMatlab/'];
    
    for i = 1:length(fileList)
        
        img = imread([dataFolder 'images/' fileList{i} '.jpg']);
        labels = dlmread([dataFolder 'labels/' fileList{i} '.regions.txt']);
        %segs1= dlmread([dataFolder 'multisegmentations/' fileList{i} '.S11.R6.seg.int']);
        %     segs2= dlmread([dataFolder 'multisegmentations/' fileList{i} '.S19.R6.seg.int']);
        %     segs3= dlmread([dataFolder 'multisegmentations/' fileList{i} '.S31.R6.seg.int']);
        
        % after noticing the inconsistent data:
        segs2 = dlmread([dataFolder 'newFeatures/' fileList{i} '.0.seg']);
        % so that they start with index 1:
        %segs1=segs1+1;
        segs2=segs2+1;
        %     segs3=segs3+1;
        assert(min(segs2(:))>0)
        assert(all(size(segs2)==size(labels)))
        
        %feat1= dlmread([dataFolder 'features/' fileList{i} '.0.txt']);
        %     feat2= dlmread([dataFolder 'features/' fileList{i} '.1.txt']);
        %     feat3= dlmread([dataFolder 'features/' fileList{i} '.2.txt']);
        % after noticing the inconsistent data:
        feat2= dlmread([dataFolder 'newFeatures/' fileList{i} '.0.txt']);
        
        % labels are inconveniently starting their labels at -1 (void)
        labels=labels+1;
        
        assert(size(feat2,1)==max(segs2(:)));
        
        saveName = [saveFolder fileList{i} '.mat'];
        if exist(saveName,'file')
            %save(saveName,'img','labels','segs2','segs3','feat2','feat3','-append');
            save(saveName,'img','labels','segs2','feat2');
        else
            %save(saveName,'img','labels','segs2','segs3','feat2','feat3');
            save(saveName,'img','labels','segs2','feat2');
        end
        disp(num2str(i))
    end
    
end