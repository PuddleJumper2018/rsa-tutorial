% Big thing 
% COPY FOR TARDIS TO WORK ALONG THE LIST OF MASKS: 21/02/22
% RSA that used to work
% 03/01/22 modified for dCNNs: changes distance to correlation and rootPath
% model to RSA_dCNN
% 04/01/22 modified back to euclidean
% 17/02/22 PPA.mat on euclidean
% 21/02/22 ROIs on dCNNs.

function rsa_roi_tardis(model)
%%%%%%%%%%%%%%%%%%%%
%Initialisation 
%%%%%%%%%%%%%%%%%%%%
% Directories
%toolbox
% which mask
masks = '/home/mpib/sztuka/projects/RSA/code/RSA_roi/mask_used/';
%mask_names = ["l_ACC","l_HC","l_OPA_10mm","l_RSC_10mm","r_ACC","r_HC","r_OPA_10mm","r_RSC_10mm","l_Amy","l_Lingual","l_PPA_10mm","l_dlPFC","r_Amy","r_Lingual","r_PPA_10mm","r_dlPFC"];
model = model; % 
disp(model)
toolboxRoot = '/home/mpib/sztuka/projects/RSA/code/RSA_roi/rsatoolbox.git/'; addpath(toolboxRoot);
% add spm path:
addpath('/opt/matlab/toolboxes/spm12/7771/');
%userOptions = defineUserOptions();
%data root
data_dir = '/home/mpib/sztuka/projects/RSA/derivatives/1Level/RSA_1stLevel_1stDeriv/';
subs = dir(fullfile(data_dir, 'sub-*'));
subs = subs(1:34); 
structPath = '/home/mpib/sztuka/projects/RSA/derivatives/flipped/[[subjectName]]/anat/';
betaPath = '/home/mpib/sztuka/projects/RSA/derivatives/1Level/RSA_1stLevel_1stDeriv/[[subjectName]]/[[betaIdentifier]]';
betanames = dir(rsa.util.replaceWildcards(betaPath, ...
                                          '[[subjectName]]', subs(1).name, ...
                                          '[[betaIdentifier]]', 'beta_*'));
betacount = 60;
rootPath = sprintf('/home/mpib/sztuka/projects/RSA/derivatives/rsa/rsa_roi/RSA_Euclid_%s/',model)
mkdir(rootPath);
% Parameters: 
subjects = 34;
numConditions = 60;
numSessions = 1;
numCategories = 5; 
betaCorrespondence = struct('identifier', {betanames(1:betacount).name});
condition_names_cell = {'I-C-A-1.jpg','I-C-A-10.jpg','I-C-A-11.jpg','I-C-A-3.jpg','I-C-A-4.jpg', ...
    'I-E-A-1.jpg','I-E-A-2.jpg','I-E-A-3.jpg','I-E-A-5.jpg','I-E-A-7.jpg', ...
    'I-G-A-1.jpg','I-G-A-14.jpg','I-G-A-20.jpg','I-G-A-3.jpg','I-G-A-8.jpg', ...
    'I-H-A-22.jpg','I-H-A-29.jpg','I-H-A-5.jpg','I-H-A-51.jpg','I-H-A-7.jpg', ...
    'I-M-A-10.jpg','I-M-A-11.jpg','I-M-A-13.jpg','I-M-A-14.jpg','I-M-A-16.jpg',...
    'I-R-A-20.jpg','I-R-A-21.jpg','I-R-A-23.jpg','I-R-A-25.jpg','I-R-A-9.jpg',...
    'I-C-N-1.jpg','I-C-N-11.jpg','I-C-N-2.jpg','I-C-N-3.jpg','I-C-N-7.jpg',...
    'I-E-N-1.jpg','I-E-N-2.jpg','I-E-N-3.jpg','I-E-N-4.jpg','I-E-N-6.jpg',...
    'I-G-N-1.jpg','I-G-N-13.jpg','I-G-N-16.jpg','I-G-N-5.jpg','I-G-N-7.jpg',...
    'I-H-N-29.jpg','I-H-N-39.jpg','I-H-N-41.jpg','I-H-N-44.jpg','I-H-N-7.jpg',...
    'I-M-N-1.jpg','I-M-N-4.jpg','I-M-N-5.jpg','I-M-N-6.jpg','I-M-N-8.jpg',...
    'I-R-N-10.jpg','I-R-N-12.jpg','I-R-N-21.jpg','I-R-N-22.jpg','I-R-N-23.jpg'}; 

%%%%%%%%%%%%%%%%%%%%%%
% User options %%
%%%%%%%%%%%%%%%%%%%%%%
%Project details
% This name identifies a collection of files which all belong to the same run of a project.
userOptions.projectName  = 'ARCH';
% This name identifies a collection of files which all belong to the same analysis within a project.
userOptions.analysisName = sprintf('RSA_%s',model)
% This is the root directory of the project.
userOptions.rootPath = rootPath;
% must be a cell: {'sub1','sub2','sub3'}The list of subjects to be included in the study.
userOptions.subjectNames = {subs.name};
%'D:\Analysen\RSA\subjects\';
userOptions.subjectPath = data_dir;
% The path leading to where the scans are stored (not including subject-specific identifiers).
userOptions.betaPath = betaPath;
%MASKS USED:'lr_occipital_cuneus_calcarine_97_115_97','lrAmygdala_97_115_97','lrHC_97_115_97','lrMidFC_97_115_97', };
%'lr_occipital_cuneus_calcarine_97_115_97','lrPFC_97_115_97'};
% Where is the folder where masks are located -> here in the MASK FOLDER 
userOptions.maskNames = {model}; %lrAmygdala_97_115_97'}; %,'lrHC_97_115_97','lrMidFC_97_115_97','lr_occipital_cuneus_calcarine_97_115_97','lrPFC_97_115_97','lr_ACC_97_15_97','lr_fusiform_97_15_97'};
userOptions.maskPath = fullfile(masks,userOptions.maskNames);
% MAYBE CONSIDER COMMENTING THIS OUT? 
if strcmp(userOptions.maskNames(1), 'mask');
     userOptions.maskPath = fullfile(userOptions.subjectPath, ...
                                     '[[subjectName]]', '[[maskName]].nii');
else
     % The path to a stereotypical mask data file is stored (not including subject-specific identifiers).
     userOptions.maskPath = fullfile(masks, sprintf('%s.nii',model))
end
% The default colour label for RDMs corresponding to RoI masks (as opposed to models).
userOptions.RoIColor = [0 0 1];
% The default colour label for RDMs corresponding to RoI masks (as opposed to models).
userOptions.ModelColor = [0 1 0];
% Should information about the experimental design be automatically acquired from SPM metadata? ->
% If this option is set to true, the entries in userOptions.conditionLabels
% MUST correspond to the names of the conditions as specified in SPM.
userOptions.getSPMData = true;

% PARAMETERS:
% What are the dimensions (in mm) of the voxels in the scans?
userOptions.voxelSize = [2 2 2];
% Save figures to PDF
userOptions.saveFiguresPDF = true;
userOptions.saveFiguresPS = false;
userOptions.saveFiguresFig = true;
userOptions.writeOut = 1;
userOptions.plottingStyle = 2;
userOptions.dpi = 300;
userOptions.criterion = 'metricstress';
% to adjust for the majority of the mRDMs being euclidean! 
userOption.distance = 'euclidean';

%%%%%%%%%%%%%%%%%%%%%%
% Data preparation %%
%%%%%%%%%%%%%%%%%%%%%%
fullBrainVols = rsa.fmri.fMRIDataPreparation(betaCorrespondence, userOptions);
%
binaryMasks_nS = rsa.fmri.fMRIMaskPreparation(userOptions);%Data preparation
%
responsePatterns = rsa.fmri.fMRIDataMasking(fullBrainVols, binaryMasks_nS,betaCorrespondence, userOptions);
%%%%%%%%%%%%%%%%%%%%%
% RDM calculation %%
%%%%%%%%%%%%%%%%%%%%%
RDMs  = rsa.constructRDMs(responsePatterns, betaCorrespondence, userOptions);
%sRDMs = rsa.rdm.averageRDMs_subjectSession(RDMs, 'session');
RDMs  = rsa.rdm.averageRDMs_subjectSession(RDMs, 'session', 'subject');
Models = rsa.constructModelRDMs(modelRDMs(), userOptions);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First-order visualisation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
userOptions.conditionLabels = condition_names_cell;
userOptions.alternativeConditionLabels = condition_names_cell;
userOptions.useAlternativeConditionLabels = true;
%removed .fig. this function is in different directory.
rsa.figureRDMs(RDMs, userOptions, struct('fileName', 'RoIRDMs', 'figureNumber', 1)); 
rsa.figureRDMs(Models, userOptions, struct('fileName', 'ModelRDMs', 'figureNumber', 2));
rsa.MDSConditions(RDMs, userOptions);
rsa.dendrogramConditions(RDMs, userOptions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% relationship amongst multiple RDMs %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
userOptions.distanceMeasure = 'Pearson';
rsa.pairwiseCorrelateRDMs({RDMs, Models}, userOptions);
localOptions.figI_shepardPlots = [14];
localOptions.MDScriterion = 'metricstress';
% doesn't work for some reason
%rsa.MDSRDMs({RDMs, Models}, userOptions); % problem with figureMDSArrangement 'disparities'. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% statistical inference %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
roiIndex = 1;% index of the ROI for which the group average RDM will serve 
% as the reference RDM. 
for i=1:numel(Models)
    models{i}=Models(i);
end
%
userOptions.RDMcorrelationType= 'Pearson' %'Kendall_taua'; % Spearman or Pearson (fro multiple brain areas)
userOptions.RDMrelatednessTest = 'subjectRFXsignedRank';
userOptions.RDMrelatednessThreshold = 0.05;
userOptions.figureIndex = [10 11];
userOptions.figure1filename = 'compareRefRDM2candidateRDMs_bargraph'
userOptions.resultsPath = rootPath;
userOptions.RDMrelatednessMultipleTesting = 'FDR';
userOptions.candRDMdifferencesTest = 'subjectRFXsignedRank';
userOptions.candRDMdifferencesThreshold = 0.05;
userOptions.candRDMdifferencesMultipleTesting = 'FDR';
stats_p_r=rsa.compareRefRDM2candRDMs(RDMs(roiIndex), models, userOptions);
save('stats.mat','stats_p_r');
disp('done')

end
