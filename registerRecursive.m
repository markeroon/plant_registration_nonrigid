%REGISTER_VIA_SURFACE_SUBDIVISION Do a coarse to fine, recursive
%registration.
function [Y1,Y2,Y3] = ...%,Y_unreg] = ...
        registerRecursive( X,Y,opt,MIN_SIZE,MAX_REG_DIST )
    iter_num=0;
    %[idx_y_unreg,idx_y_reg] = findPointIndicesToNotRegister( X,Y,MAX_REG_DIST );
    %Y_toreg = Y(idx_y_reg,:);
    [Y1,Y2,Y3] = registerPoints( X,Y... % Y_toreg ...
                    ,opt,MIN_SIZE,MAX_REG_DIST,iter_num );
    %Y_unreg = Y(idx_y_unreg,:);
end
 
function [X__,Y__,Z__] = registerPoints( X,Y,opt,...
                                        MIN_SIZE,max_dist,iter_num )   
    if size(X,1) > MIN_SIZE && size(Y,1) > MIN_SIZE && max_dist >= 1 ...
            && iter_num < 3
        
        if iter_num > 0
            [R,T] = icp( X,Y );
            Y_icp = R*Y' + repmat(T',size(Y,1),1)';
            Y_icp = Y_icp';
            Y = Y_icp;

        end
            %{
        if iter_num > 0
            opt.lambda = 1;
            opt.beta = 1;
            opt.method = 'rigid';%'nonrigid_lowrank';
            %opt.max_it = 100;
            opt.normalize = 0;
            T = cpd_register(X,Y,opt);
            Y = T.Y;
        end
        %}
            
        % this use of X co-ords as the dividing 
        % space is on purpose
        left_y   = min( Y(:,1) );
        right_y  = max( Y(:,1) );
        top_y    = max( Y(:,2) );
        bottom_y = min( Y(:,2) );
        back_y   = min( Y(:,3) );
        front_y  = max( Y(:,3) );     
        
        pad_width = .1*abs(right_y-left_y);
        pad_height = .1*abs(top_y-bottom_y);
        pad_depth = .1*abs(front_y-back_y);
        
        m_width_y  = left_y+((right_y-left_y)/2);
        m_height_y = bottom_y+((top_y-bottom_y)/2);
        m_depth_y = back_y+((front_y-back_y)/2 );
        
        Y1_ = Y(:,1);
        Y2_ = Y(:,2);
        Y3_ = Y(:,3);
        
        X1_ = X(:,1);
        X2_ = X(:,2);
        X3_ = X(:,3);
        pad_width
        pad_height
        pad_depth
        
        %{
        [idx_y_000,idx_y_001,idx_y_010,idx_y_011,...
        idx_y_100,idx_y_101,idx_y_110,idx_y_111] = ...
            subdivide_volume( Y1_, Y2_, Y3_, ...
                        left_y,bottom_y,back_y, ...
                        right_y,top_y,front_y, ...
                        m_width_y, m_height_y, m_depth_y ) ;       

        [idx_x_000,idx_x_001,idx_x_010,idx_x_011,...
        idx_x_100,idx_x_101,idx_x_110,idx_x_111] = ...
            subdivide_volume( X1_, X2_, X3_, ...
                        left_y-pad_width,bottom_y-pad_height,...
                        back_y-pad_depth,right_y+pad_width,...
                        top_y+pad_height,front_y+pad_depth, ...
                        m_width_y, m_height_y, m_depth_y ) ;                      
        %}
        idx_y_000 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_001 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_010 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_011 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );

        idx_y_100 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_101 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_110 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_111 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        
        idx_x_000 = find( X1_ < m_width_y & X2_ < m_height_y & X3_ < m_depth_y );
        idx_x_001 = find( X1_ < m_width_y & X2_ < m_height_y & X3_ >= m_depth_y );
        idx_x_010 = find( X1_ < m_width_y & X2_ >= m_height_y & X3_ < m_depth_y );
        idx_x_011 = find( X1_ < m_width_y & X2_ >= m_height_y & X3_ >= m_depth_y );
        
        idx_x_100 = find( X1_ >= m_width_y & X2_ < m_height_y & X3_ < m_depth_y );
        idx_x_101 = find( X1_ >= m_width_y & X2_ < m_height_y & X3_ >= m_depth_y );
        idx_x_110 = find( X1_ >= m_width_y & X2_ >= m_height_y & X3_ < m_depth_y );
        idx_x_111 = find( X1_ >= m_width_y & X2_ >= m_height_y & X3_ >= m_depth_y );
        
        %make fgt = 0 for the smaller subdivisions
        
        %FIX CALLS TO REGISTER POINTS!!!!!!!!!!!!!!
        [Y1_000,Y2_000,Y3_000] = registerPoints( X(idx_x_000,:),Y(idx_y_000,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        [Y1_001,Y2_001,Y3_001] = registerPoints( X(idx_x_001,:),Y(idx_y_001,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );

        [Y1_010,Y2_010,Y3_010] = registerPoints( X(idx_x_010,:),Y(idx_y_010,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        [Y1_011,Y2_011,Y3_011] = registerPoints( X(idx_x_011,:),Y(idx_y_011,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );

        [Y1_100,Y2_100,Y3_100] = registerPoints( X(idx_x_100,:),Y(idx_y_100,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        [Y1_101,Y2_101,Y3_101] = registerPoints( X(idx_x_101,:),Y(idx_y_101,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );

        [Y1_110,Y2_110,Y3_110] = registerPoints( X(idx_x_110,:),Y(idx_y_110,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );
        [Y1_111,Y2_111,Y3_111] = registerPoints( X(idx_x_111,:),Y(idx_y_111,:),opt,MIN_SIZE,max_dist - 2,iter_num+1 );

        X__ = [Y1_000; Y1_001 ; Y1_010 ; Y1_011 ; Y1_100 ; Y1_101 ; Y1_110 ; Y1_111 ]; 
        Y__ = [Y2_000; Y2_001 ; Y2_010 ; Y2_011 ; Y2_100 ; Y2_101 ; Y2_110 ; Y2_111 ];  
        Z__ = [Y3_000; Y3_001 ; Y3_010 ; Y3_011 ; Y3_100 ; Y3_101 ; Y3_110 ; Y3_111 ]; 

    else
        figure;
        plot3( X(:,1),X(:,2),X(:,3), '.b', 'markersize',1 )
        hold on
        plot3( Y(:,1),Y(:,2),Y(:,3), '.r', 'markersize',1 )
        med = getMedianDistBetween( X,Y );
        if med > 1.0 
            X__ = [];
            Y__ = [];
            Z__ = [];
            title( 'not accepted' );
        else
            X__ = Y(:,1);
            Y__ = Y(:,2);
            Z__ = Y(:,3);
            title( 'accepted reg' );
        end
    end

end
