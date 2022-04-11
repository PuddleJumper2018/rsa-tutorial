%% RSA-ROI analysis example
% modified: 7/04/22
% created: Izabel M Sztuks imsztuka@protonmail.com, Maxi Becker.
% This is a script showing the single-roi rsa analysis step by step. It
% uses SPM12 (I have ver. 7771) and custom-adjusted rsatoolbox (which you download from the github)

%%%%%%%%%%%%%%%%%%%%
%Initialisation 
%%%%%%%%%%%%%%%%%%%%
% Customise the directories to account for your circumstances. 
% Directory to where the ROI mask is located:
masks = '/Users/sztuka/Documents/rsa-tutorial/rsa-roi/mask_used/';
% Add the name of the mask you will use
mask_names = ["r_cuneus"];
% add is as a character vector to help automatise the process
model = "r_cuneus"; % 
% create directory for the results
rootPath = sprintf('/home/mpib/sztuka/projects/RSA/derivatives/rsa/rsa_roi/RSA_Euclid_%s/',model)
mkdir(rootPath);
% add the location of rsatoolbox
toolboxRoot = '/Users/sztuka/Documents/rsa-tutorial/rsa-roi/rsatoolbox.git/'; addpath(toolboxRoot);
% add spm path:
addpath('/Users/sztuka/SPM12/');
% add the directory containing your betas
data_dir = '/Users/sztuka/Documents/rsa-tutorial/derivatives/1Level/RSA_1stLevel_1stDeriv/';
% Parameters: 
% subjects included
subjects = 5;
% how many conditions included (how many betas will be loaded)
numConditions = 60;
betacount = numConditions; 
subs = dir(fullfile(data_dir, 'sub-*'));
% helper for wildcard
subs = subs(1:subjects); 
% add the path to structural images including wildcards
structPath = '/home/mpib/sztuka/projects/RSA/derivatives/flipped/[[subjectName]]/anat/';
betaPath = fullfile(data_dir,'[[subjectName]]/[[betaIdentifier]]');
betanames = dir(rsa.util.replaceWildcards(betaPath, ...
                                          '[[subjectName]]', subs(1).name, ...
                                          '[[betaIdentifier]]', 'beta_*'));
% creating beta corresponcence (toolbox has an example recipe for creating the variable)
betaCorrespondence = struct('identifier', {betanames(1:betacount).name});
% our conditions included in betas.
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
% It is a struct that contains all information & parameters for the
% project.
% This name identifies a collection of files which all belong to the same run of a project.
userOptions.projectName  = 'ARCH';
% This name identifies a collection of files which all belong to the same analysis within a project.
userOptions.analysisName = sprintf('RSA_%s',model)
% This is the root directory of the project.
userOptions.rootPath = rootPath;
% must be a cell: {'sub1','sub2','sub3'}The list of subjects to be included in the study.
userOptions.subjectNames = {subs.name};
% defined before
userOptions.subjectPath = data_dir;
% The path leading to where the scans are stored (not including subject-specific identifiers).
userOptions.betaPath = betaPath;
% Where is the folder where masks are located -> here in the MASK FOLDER 
userOptions.maskNames = {model};
userOptions.maskPath = fullfile(masks,userOptions.maskNames);
% Here you can load more than one ROI mask. Please mind this part doesn't
% work for me for some reason. 
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
userOptions.getSPMData = true;
% Additional parameters:
% What are the dimensions (in mm) of the voxels in the scans?
userOptions.voxelSize = [2 2 2];
% Save figures to PDF
userOptions.saveFiguresPDF = true;
userOptions.saveFiguresPS = false;
% Save as a figure. 
userOptions.saveFiguresFig = true;
userOptions.writeOut = 1;
userOptions.plottingStyle = 2;
userOptions.dpi = 300;
% This is a criterion to be minimised in MDS display. Metric stress is
% used in most cases.
userOptions.criterion = 'metricstress';
% A string indicating the distance measure with which to
% calculate the RDMs. Defaults to 'Correlation'. I also used Euclidean. 
userOption.distance = 'Correlation';
%% This part will take some time. 
%%%%%%%%%%%%%%%%%%%%%%
% Data preparation %%
%%%%%%%%%%%%%%%%%%%%%%
% Loads brain responses to all experimental conditions.
fullBrainVols = rsa.fmri.fMRIDataPreparation(betaCorrespondence, userOptions);
% Load the ROI masks
binaryMasks_nS = rsa.fmri.fMRIMaskPreparation(userOptions);
% Extracts the relevant information from ROI
responsePatterns = rsa.fmri.fMRIDataMasking(fullBrainVols, binaryMasks_nS,betaCorrespondence, userOptions);
%%%%%%%%%%%%%%%%%%%%%
% RDM calculation %%
%%%%%%%%%%%%%%%%%%%%%
% RDMs are calculated for each subject and each region of interest.
RDMs  = rsa.constructRDMs(responsePatterns, betaCorrespondence, userOptions);
%sRDMs = rsa.rdm.averageRDMs_subjectSession(RDMs, 'session');
RDMs  = rsa.rdm.averageRDMs_subjectSession(RDMs, 'session', 'subject');
% The candidate models are loaded from modelRDMs.m file.
Models = rsa.constructModelRDMs(modelRDMs(), userOptions);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First-order visualisation %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%In this step, average RDMs are displayed first. 
%(RDMs are averaged according to user’s preferences, defaulting to subject- 
%and session-averaged RDMs for each RoI.) Then the MDS plots and
% the dendrograms will be displayed and saved.
userOptions.conditionLabels = condition_names_cell;
userOptions.alternativeConditionLabels = condition_names_cell;
userOptions.useAlternativeConditionLabels = true;
%removed .fig. this function is in different directory.
rsa.figureRDMs(RDMs, userOptions, struct('fileName', 'RoIRDMs', 'figureNumber', 1)); 
rsa.figureRDMs(Models, userOptions, struct('fileName', 'ModelRDMs', 'figureNumber', 2));
rsa.MDSConditions(RDMs, userOptions);
rsa.dendrogramConditions(RDMs, userOptions);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% relationship amongst multiple RDMs %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute and display a second-order similarity matrix from RDMs and multidimensional scalling of 
% RDMs
% The measurement type (Defaults to 'Spearman' but any Matlab distance
% measure may be used.)
userOptions.distanceMeasure = 'Spearman';
rsa.pairwiseCorrelateRDMs({RDMs, Models}, userOptions);
localOptions.figI_shepardPlots = [14];
localOptions.MDScriterion = 'metricstress';
% MDSRDM performs second-order MDS, visualising the dissimilarities between
% RDMs.
% Note: Doesn't work for some reason for me you can try to comment out and see if
% that works for you. 
%rsa.MDSRDMs({RDMs, Models}, userOptions); % problem with figureMDSArrangement 'disparities'. 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% statistical inference %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final step compared reference RDM (ROI RDM) to candidate RDMs (AN in our case).
% See the decision-making process on slide. 

roiIndex = 1;% index of the ROI for which the group average RDM will serve 
% as the reference RDM. 
for i=1:numel(Models)
    models{i}=Models(i);
end
%
userOptions.RDMcorrelationType= 'Spearman' %'Kendall_taua', Spearman or Pearson (fro multiple brain areas)
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


