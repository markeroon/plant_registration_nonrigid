%FINDPOINTSTOREGISTER Find the points in X that are near points
% in Y_ur
% We wish to find the k-nearest neighbours that are within a reasonable
% distance
% X - the set of reference points to which the points in Y_u are going to
% be fittted
% Y_ur - the unregistered (ur) points of Y
% k - the number of neighbouring points in X to each Y_ur that we wish
% to register
% max_allowable_dist - if the nearest neighbour is greater than this 
% distance, it is likely that the scans do not overlap in this area
function [ X_ur ] = findPointstoRegister( X,Y_ur,k,max_allowable_dist )
  
    id_ur = [];
    size(Y_ur,1)
    for i=1:size(Y_ur,1)
        % find k-nearest neighbours
        [id,dist] = kNearestNeighbors( X,Y_ur(i,:),k);
        if( dist(1) < max_allowable_dist )
            id_ur = [id_ur id];
        end
    end
    
    % remove duplicates
    id_unique = unique( id_ur );
    X_ur = X(id_unique,:);
end
   