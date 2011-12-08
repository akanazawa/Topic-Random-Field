function [numLabels scratch] = colorImgWithLabels(segMap, im, nodeLabels, colmap, saveTo)

[h w] = size(segMap);

fullMask = zeros(h,w);
%wordsForMask = {'bla'};

scratch = im;
numLabels = 0;


%numSegs = max(segMap(:));
for i = 1:length(nodeLabels)
    col = colmap(nodeLabels(i),:);
    
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
    set(gca, 'position', [0 0 1 1], 'visible', 'off') 
    print([saveTo '.png'], '-dpng')
    %     print([saveTo '.eps'], '-depsc')
end
end