%  modelRDMs is a user-editable function which specifies the models which
%  brain-region RDMs should be compared to, and specifies which kinds of
%  analysis should be performed.
%
%  Models should be stored in the "Models" struct as a single field labeled
%  with the model's name (use underscores in stead of spaces).
%  
%  Cai Wingfield 11-2009
%  adapted by maxi almaxi@gmail.com 2020
%  adapted in mpl version by IMS 2020/22
% Model list (euclidean distances): 
%           * AN
%           * CEGHMR
%           * MDS D1
%           * MDS D2
%           * ST (PWD)
%           * R1
%           * R2
%           * R3
%           * R4
%           * LLF: B, H, S, ED, SED, NSED, FDD, FDB, Entropy
%          Corr * AlexNet:
%          Corr * VGG:
%           * random

function Models = modelRDMs()

 o=1 % if o=1 then euclid models if 2 then dCNN
 
%Create Categorical conditions
generalpath = '/home/mpib/sztuka/projects/RSA/code/RSA_roi/RDM/';
nconditions=60; % amount of different pictures representing different conditions;

% define artifical and natural index vectors
AC = 1:5; AE = 6:10; AG = 11:15; AH=16:20; AM =21:25; AR=26:30;
NC = 31:35; NE = 36:40; NG = 41:45; NH=46:50; NM =51:55; NR=56:60;

A = [AC AE AG AH AM AR];
N = [NC NE NG NH NM NR];%setdiff(1:nconditions,artifical)

Models.AN = ones(nconditions, nconditions);
Models.AN(N,N) = 0;
Models.AN(A,A) = 0;
Models.AN(logical(eye(nconditions)))=0; % fix the zero-diagonal

Models.CEGHMR = ones(nconditions, nconditions);
Models.CEGHMR([AC NC],[AC NC]) = 0;
Models.CEGHMR([AE NE],[AE NE]) = 0;
Models.CEGHMR([AG NG],[AG NG]) = 0;
Models.CEGHMR([AH NH],[AH NH]) = 0;
Models.CEGHMR([AM NM],[AM NM]) = 0;
Models.CEGHMR([AR NR],[AR NR]) = 0;
Models.CEGHMR(logical(eye(nconditions)))=0; % fix the zero-diagonal

if o==1 

% % MDS D1&2
   load([generalpath 'MDS_Proxscal_RDM.mat']);
   Models.MDSD1 = D1_Proxscal_RDM;
   Models.MDSD2 = D1_Proxscal_RDM;
   warning('MDS: Dimension 1& 2')
% 
% MDS ST-PWD
   load([generalpath 'ST_RDM.mat']);
   Models.ST = ST_RDM;
   warning('ST')
%   
%get Human Rating RDMs 
   load([generalpath 'ratings_rdm.mat']);
   Models.rating_q1 = Preference_RDM;
   Models.rating_q2 = Naturalness_RDM;
   Models.rating_q3 = BeThere_RDM;
   Models.rating_q4 = Arousal_RDM;
%   
%get LLFs
  load([generalpath 'LLF_RDM_new.mat']);
  Models.Brightness  = Brightness_RDM;
  Models.EdgeDensity = EdgeDensity_RDM;
  Models.Hue         = Hue_RDM;
  Models.Saturation  = Saturation_RDM;
  Models.Entropy     = Entropy_RDM;
  Models.FractalD     = FDD_RDM;
  Models.FractalB     = FDB_RDM;
  Models.SED         = SED_RDM;
  Models.NSED        = NSED_RDM;

elseif o==2
%get AlexNet RDMs -> think which layers are most suited
 alexnetpath = [generalpath 'AlexNet_RDM/'];
% 
 load([alexnetpath 'ARCH_layer_1_corr_mtx_nan.mat'],'R');
%create an dissimiliarity matrix instead of similiarity matrix
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet1 = R; clearvars R;
% 
 load([alexnetpath 'ARCH_layer_3_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet3 = R; clearvars R;
% 
 load([alexnetpath 'ARCH_layer_4_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet4 = R; clearvars R;
% 
 load([alexnetpath 'ARCH_layer_8_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet8 = R; clearvars R;
% 
 load([alexnetpath 'ARCH_layer_12_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet12 = R; clearvars R;
% 
 load([alexnetpath 'ARCH_layer_14_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet14 = R; clearvars R;
% 
 load([alexnetpath 'ARCH_layer_15_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.Alexnet16 = R; clearvars R;
% 
% 
%get VGG16 RDMs -> think which layers are most suited
 vggnetpath = [generalpath 'VGG_RDM/'];
% alexnetpath = 'C:\Users\cabez\Google Drive\personal\Mx\ARCH\modelRDMs\RDM_alexnet\';
% 
 load([vggnetpath 'ARCH_layer_1_corr_mtx_nan.mat'],'R');
%create an dissimiliarity matrix instead of similiarity matrix
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.VGG1 = R; clearvars R;
% 
 load([vggnetpath 'ARCH_layer_6_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.VGG6 = R; clearvars R;
% 
 load([vggnetpath 'ARCH_layer_13_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.VGG13 = R; clearvars R;
% 
 load([vggnetpath 'ARCH_layer_20_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.VGG20 = R; clearvars R;
% 
 load([vggnetpath 'ARCH_layer_27_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.VGG27 = R; clearvars R;
% 
 load([vggnetpath 'ARCH_layer_29_corr_mtx_nan.mat'],'R');
 R= 1-R; R(logical(eye(nconditions)))= 0; Models.VGG29 = R; clearvars R;
end % if statement
%get Human Rating RDMs 
% ratingpath = [generalpath 'RDM_subjective_rating\'];
% load([ratingpath 'ARCH_RDM_rating.mat']);
% Models.rating_q1 = Model.rating_q1;
% Models.rating_q2 = Model.rating_q2;
% Models.rating_q3 = Model.rating_q3;
% Models.rating_q4 = Model.rating_q4;
% 
% %get Human MDS
%  load([generalpath 'RDM_MDS\MDS_RDM_avg.mat']);
%  Models.MDS = r_rdm_square;
%  warning('MDS: check if pictures are in correct order & fehlt noch!')

%get random RDM
Models.random = squareform(pdist(rand(nconditions,nconditions)));


end%function
