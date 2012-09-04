% getMedianDistBetween 
% 
% Find the closest point in X for each point in Y, then
% get the median of these points.
%
% If one of X or Y is empty (or both), the dist between them
% is returned as inf
%
function [ med ] = getMedianDistBetween( X,Y )
    if ~isempty(X) && ~isempty(Y)
        dists = ones(size(Y,1),1);
        tree = kdtree_build( X );
        for i=1:size(dists,1)    
            [idxs,dists(i)] = kdtree_k_nearest_neighbors( tree, Y(i,:), 1 );
        end
        med = median( dists );
        kdtree_delete(tree);
    else 
        med = inf;
    end
end

