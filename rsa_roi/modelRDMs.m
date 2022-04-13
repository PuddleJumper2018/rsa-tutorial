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

% o=1 % if o=1 then euclid models if 2 then dCNN
 
%Create Categorical conditions
generalpath = '/Users/sztuka/Documents/rsa-tutorial/rsa_roi/RDM/';
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

% %get LLFs
   load([generalpath 'LLF_RDM_new.mat']);
%   Models.Brightness  = Brightness_RDM;
%   Models.EdgeDensity = EdgeDensity_RDM;
%   Models.Hue         = Hue_RDM;
%   Models.Saturation  = Saturation_RDM;
%   Models.Entropy     = Entropy_RDM;
   Models.FractalD     = FDD_RDM;
%   Models.FractalB     = FDb;
%   Models.SED         = SED_RDM;
%   Models.NSED        = NSED_RDM;

%get random RDM
Models.random = squareform(pdist(rand(nconditions,nconditions)));


end%function
