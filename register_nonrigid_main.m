addpath( 'file_management/' );
addpath( 'kdtree-mex/' );
addpath( 'icp' );
addpath( genpath( 'CoherentPointDrift' ) );

rms_e_all = [];
R =  [ 0.9101   -0.4080    0.0724 ;
       0.4118    0.8710   -0.2681 ;
       0.0463    0.2738    0.9607 ];
t = [ 63.3043,  234.5963, -46.8392 ];

min_size = 100;%500;
max_registerable_dist = 30;
opt.viz = 1;
opt.lambda = 1;
opt.beta = 1;
opt.max_it = 15;
opt.method = 'rigid';
opt.outliers = 0.2;
opt.tol = 1e-10;
opt.rot = 0;
opt.normalize = 1;
opt.scale = 0;
opt.fgt = 1;

%register all of the indices
registration_indices = [9:11];
for q=registration_indices

filename_0 = sprintf( '../../Data/PlantDataPly/plants_converted82-%03d-clean-clear.ply', q-1 );
[Elements_0,varargout_0] = plyread(filename_0);
X = [Elements_0.vertex.x';Elements_0.vertex.y';Elements_0.vertex.z']';
%X=X(1:5:end,:);
for j=1:q-1
        X_dash = R*X' + repmat(t,size(X,1),1)';
        X = X_dash';
end
    
filename_1 = sprintf( '../../Data/PlantDataPly/plants_converted82-%03d-clean-clear.ply', q );
[Elements_1,varargout_1] = plyread(filename_1);
Y = [Elements_1.vertex.x';Elements_1.vertex.y';Elements_1.vertex.z']';
%Y=Y(1:5:end,:);
for j=1:q
        Y_dash = R*Y' + repmat(t,size(Y,1),1)';
        Y = Y_dash';
end

[Yr_x,Yr_y,Yr_z]=...
    registerRecursive( X,Y,opt,min_size,max_registerable_dist );

Y_reg_all{q} = [Yr_x'; Yr_y'; Yr_z' ]';
filename = sprintf( '../../Data/Yq%02d-%s.mat',[q datestr(now,'dd.mm.yy.HH.MM') ] )
Yq = Y_reg_all{q};
save(filename,'Yq');
Yq = [];
end