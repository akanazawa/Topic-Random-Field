function [numLabels scratch] = visualizeSegments(segMap, im, superSegList, nodeLabels, saveTo)
% set nodeLabels to [] if you want to see pairs,triples,... each with their own color

if isempty(nodeLabels)
    colmap = hsv(length(superSegList));
else
    % number of classes!
    %colmap = hsv(5);
    colmap = [0 0 1; 0 1 0; 1 0.5 0; 1 0 0; 1 0 0; 1 0 0; 1 0 0];%blue. green
    
end

[h w] = size(segMap);

fullMask = zeros(h,w);
%wordsForMask = {'bla'};

scratch = im;
numLabels = 0;


%numSegs = max(segMap(:));
for ss = 1:length(superSegList)
    segs = superSegList{ss};
    
    if isempty(nodeLabels)
        col = colmap(ss,:);
    else
       numLalbesInLeafs = length(find(nodeLabels(:,ss)));
       col = colmap(numLalbesInLeafs,:);
    end
    
    for n = 1:length(segs)
        i=segs(n);
        %string = get(trans, words{i});
        %     if (isempty(string))
        %         s = scratch(:,:,1);
        %         s(segMap == i) = s(segMap == i)/3;
        %         scratch(:,:,1) = s;
        %         s = scratch(:,:,2);
        %         s(segMap == i) = s(segMap == i)/3;
        %         scratch(:,:,2) = s;
        %         s = scratch(:,:,3);
        %         s(segMap == i) = s(segMap == i)/3;
        %         scratch(:,:,3) = s;
        %     else
        %         %scratch = scratch / 3;
        
        s = scratch(:,:,1);
        s(segMap == i) = s(segMap == i)/3 + 100*col(1);
        scratch(:,:,1) = s;
        s = scratch(:,:,2);
        s(segMap == i) = s(segMap == i)/3 + 100*col(2);
        scratch(:,:,2) = s;
        s = scratch(:,:,3);
        s(segMap == i) = s(segMap == i)/3 + 100*col(3);
        scratch(:,:,3) = s;
        %         if ~ismember(wordsForMask,string)
        %             wordsForMask{end+1} = string;
        %         end
        %fullMask(segMap == i) = find(strcmp(string,wordsForMask));
        %
        %
        %     end
    end
end

imshow(scratch);
% if onlyOneLabel
%     hold on;
%     for obs = 2:length(wordsForMask)
%         string = wordsForMask{obs};
%         col = get(colmap, string);
%         [r, c] = segmentCenter(fullMask, obs);
%         text(c, r, string,'FontSize',18,'EdgeColor', col, 'BackgroundColor', [1 1 1], 'LineWidth', 3);
%     end
%   hold off;
% else
%     hold on;
%     for i = 1:numSegs
%         string = get(trans, words{i});
%         annotated = get(lex, words{i});
%         if (~isempty(string))
%             col = get(colmap, string);
%             if (~isempty(annotated))
%                 string = sprintf('(%s)', string);
%             end
%             numLabels = numLabels + 1;
%             [r, c] = segmentCenter(segMap, i);
%             text(c, r, string, 'EdgeColor', col, 'BackgroundColor', [1 1 1], 'LineWidth', 2);
%         end
%     end
%     hold off;
% end

if exist('saveTo', 'var')
    print([saveTo '.png'], '-dpng')
    %     print([saveTo '.eps'], '-depsc')
end
end