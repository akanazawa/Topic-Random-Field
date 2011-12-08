function adj = getAdjacentSegments(segs, showImage)
%getAdjacentSegments(segs)
%  Determine which segments in a segmentation map are adjacent to each
%  other.  This is done by finding those pixels which are in a different segment
%  from the pixels either directly above, to the right, diagonally up and
%  to the right, or diagonally down and to the right.
%
%Args:
%  segs: The segmentation map.
%  showImage (optional): If 1, show an image with the segment boundaries.
%
%Returns:
%  adj: An upper-triangular adjacency matrix, where entry adj(i,j) is 1
%    if i < j and segment i is adjacent to segment j.

    [h w] = size(segs);
    
    horz = segs(:, 1:w-1) - segs(:, 2:w);
    vert = segs(1:h-1, :) - segs(2:h, :);
    diagup = segs(2:h, 1:w-1) - segs(1:h-1, 2:w);
    diagdown = segs(1:h-1, 1:w-1) - segs(2:h, 2:w);
    
    % Find the segment outlines
    net = zeros(h, w);
    net(:, 1:w-1) = net(:, 1:w-1) | horz;
    net(1:h-1, :) = net(1:h-1, :) | vert;
    net(2:h, 1:w-1) = net(2:h, 1:w-1) | diagup;
    net(1:h-1, 1:w-1) = net(1:h-1, 1:w-1) | diagdown;
    
    if exist('showImage', 'var')
        if showImage
            scratch = segs;
            figure; imagesc(net);
            scratch(net == 1) = max(max(segs)) + 1;
            figure; imagesc(scratch);
        end
    end
    
    
    % Find the adjacent segments
    adj = eye(max(max(segs)));
    ind = find(net == 1);
    for k = 1:length(ind)
        [i j] = ind2sub([h w], ind(k));
        
        % Update adjacencies for surrounding pixels
        if (i < h)
            adj(segs(i,j), segs(i+1, j)) = 1;
            if (j < w)
                adj(segs(i,j), segs(i+1, j+1)) = 1;
            end
            if (j > 1)
                adj(segs(i,j), segs(i+1, j-1)) = 1;
            end
        end
        
        if (j < w)       
            adj(segs(i,j), segs(i, j+1)) = 1;
            if (i > 1)
                adj(segs(i,j), segs(i-1, j+1)) = 1;
            end
        end
        
        if (i > 1)
            adj(segs(i,j), segs(i-1, j)) = 1;
            if (j > 1)
                adj(segs(i,j), segs(i-1, j-1)) = 1;
            end
        end
        
        if (j > 1)       
            adj(segs(i,j), segs(i, j-1)) = 1;
        end
    end
    
    
    adj = adj | adj';
    adj = triu(adj);
    
    adj = adj - eye(size(adj));
end