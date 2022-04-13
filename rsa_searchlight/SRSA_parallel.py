#!/usr/bin/python3
# Script for Searchlight Analysis (SRSA) with RSA method on Python rsatoolbox
# The script is used for distributed computation by model & participant.
# THIS IS A SUBJECT-LEVEL SRSA ANALYSIS
import numpy as np
import os
import matplotlib.pyplot as plt
from nilearn.image import new_img_like
import pandas as pd
import nibabel as nib
import seaborn as sns
from nilearn import plotting
from rsatoolbox.inference import eval_fixed
from rsatoolbox.model import ModelFixed
from rsatoolbox.rdm import RDMs
from glob import glob
from scipy import io
from rsatoolbox.util.searchlight import get_volume_searchlight, get_searchlight_RDMs, evaluate_models_searchlight
import sys

MODEL = sys.argv[1]
SUB = sys.argv[2]

print('Searchlight Model '+MODEL+'_'+ SUB)

# organise the RDM into upper triangular index and configure the matrices.

def upper_tri(RDM):
    """upper_tri returns the upper triangular index of an RDM

    Args:
        RDM 2Darray: squareform RDM

    Returns:
        1D array: upper triangular vector of the RDM
    """
    # returns the upper triangle
    m = RDM.shape[0]
    r, c = np.triu_indices(m, 1)
    return RDM[r, c]

import matplotlib.colors
def RDMcolormapObject(direction=1):
    """
    Returns a matplotlib color map object for RSA and brain plotting
    """
    if direction == 0:
        cs = ['yellow', 'red', 'gray', 'turquoise', 'blue']
    elif direction == 1:
        cs = ['blue', 'turquoise', 'gray', 'red', 'yellow']
    else:
        raise ValueError('Direction needs to be 0 or 1')
    cmap = matplotlib.colors.LinearSegmentedColormap.from_list("", cs)
    return cmap
def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

# directories ADJUST
IN = '/PathToBids/derivatives/1Level/RSA_1stLevel_1stDeriv/'
# set results folders
OUT_brains = '/PathTo/'+MODEL+'/Figures/'
ensure_dir(OUT_brains)
OUT_plots = '/PathTo/'+MODEL+'/Plots/'
ensure_dir(OUT_plots)
OUT_scores = '/PathTo/'+MODEL+'/Scores/'
ensure_dir(OUT_scores)
OUT_results = '/PathTo/'+MODEL+'/Results/'
ensure_dir(OUT_results)
# Directory to stored Model RDM
mat_dir = '/PathTo/Model_RDM.mat'


# set this path to wherever you saved the folder containing the img-files
data_folder = os.path.join(IN, SUB)
image_paths = list(glob(f"{data_folder}/beta_*.nii"))  #  image_paths = list(glob(f"{data_folder}/beta_*.nii"))
image_paths.sort()
print( SUB +' - images loaded ' + MODEL)
# load one image to get the dimensions and make the mask
tmp_img = nib.load(image_paths[0])
affine_mat = tmp_img.affine
dimsize = tmp_img.header.get_zooms()
# we infer the mask by looking at non-nan voxels
mask = ~np.isnan(tmp_img.get_fdata())
x, y, z = tmp_img.get_fdata().shape
# loop over all images
data = np.zeros((len(image_paths), x, y, z))
for x, im in enumerate(image_paths):
    data[x] = nib.load(im).get_fdata()
# only one pattern per image
image_value = np.arange(len(image_paths))
# get searchlights
print(SUB +' - looking for searchlights')
centers, neighbors = get_volume_searchlight(mask, radius=5, threshold=0.5)
# reshape data so we have n_observastions x n_voxels
data_2d = data.reshape([data.shape[0], -1])
data_2d = np.nan_to_num(data_2d)
# Get RDMs
print(SUB+' - creating brain RDMs')
# Define distance to be calculcated. ARCH: all but dCNN models euclidean distance.
SL_RDM = get_searchlight_RDMs(data_2d, centers, neighbors, image_value, method='euclidean')
# load sub specific file from matlab MDS file:
print(SUB+' - loading subjects dissimilarity matrix')
#load Model from general file:
matlab_data = io.matlab.loadmat(mat_dir)
matlab_data = matlab_data[MODEL+'_RDM']
# This is difficult part:
an_labels = np.array(['I-C-A-1.jpg','I-C-A-10.jpg','I-C-A-11.jpg','I-C-A-3.jpg','I-C-A-4.jpg','I-E-A-1.jpg','I-E-A-2.jpg','I-E-A-3.jpg','I-E-A-5.jpg','I-E-A-7.jpg','I-G-A-1.jpg','I-G-A-14.jpg','I-G-A-20.jpg','I-G-A-3.jpg','I-G-A-8.jpg','I-H-A-22.jpg','I-H-A-29.jpg','I-H-A-5.jpg','I-H-A-51.jpg','I-H-A-7.jpg','I-M-A-10.jpg','I-M-A-11.jpg','I-M-A-13.jpg','I-M-A-14.jpg','I-M-A-16.jpg','I-R-A-20.jpg','I-R-A-21.jpg','I-R-A-23.jpg','I-R-A-25.jpg','I-R-A-9.jpg','I-C-N-1.jpg','I-C-N-11.jpg','I-C-N-2.jpg','I-C-N-3.jpg','I-C-N-7.jpg','I-E-N-1.jpg','I-E-N-2.jpg','I-E-N-3.jpg','I-E-N-4.jpg','I-E-N-6.jpg','I-G-N-1.jpg','I-G-N-13.jpg','I-G-N-16.jpg','I-G-N-5.jpg','I-G-N-7.jpg','I-H-N-29.jpg','I-H-N-39.jpg','I-H-N-41.jpg','I-H-N-44.jpg','I-H-N-7.jpg','I-M-N-1.jpg','I-M-N-4.jpg','I-M-N-5.jpg','I-M-N-6.jpg','I-M-N-8.jpg','I-R-N-10.jpg','I-R-N-12.jpg','I-R-N-21.jpg','I-R-N-22.jpg','I-R-N-23.jpg'])
an_RDM = matlab_data
an_model = ModelFixed(MODEL, upper_tri(an_RDM))
# get the evaulation score for each voxel
eval_results = evaluate_models_searchlight(SL_RDM, an_model, eval_fixed, method='spearman', n_jobs=3)
# We only have one model, but evaluations returns a list. By using float we just grab the value within that list
print(SUB+' - running model comparison(?)')
eval_score = [np.float(e.evaluations) for e in eval_results]
file_n = 'ARCH_SL_'+MODEL+'_score_'+SUB
file_nFigures = os.path.join(OUT_scores, file_n)
print(SUB+' - saving scores')
np.save(file_nFigures,eval_score)
# Create an 3D array, with the size of mask, and
x, y, z = mask.shape
RDM_brain = np.zeros([x*y*z])
RDM_brain[list(SL_RDM.rdm_descriptors['voxel_index'])] = eval_score
RDM_brain = RDM_brain.reshape([x, y, z])
print('End SearchLight for participant ' + SUB)
# results for replication: (here you are saving RDM brain not only evaluation score)
file_nb = 'ARCH_'+MODEL+'_RDMbrain_'+SUB+'.npy'
file_nbFigures = os.path.join(OUT_scores, file_nb)
print(SUB+' - saving scores')
np.save(file_nbFigures,RDM_brain)
output_name = 'ARCH_SL_'+MODEL+'_result_'+SUB+'.nii.gz'
output_dir = os.path.join(OUT_results,output_name)
sl_result = RDM_brain.astype('double')  # Convert the output into a precision format that can be used by other applications
sl_result[np.isnan(sl_result)] = 0  # Exchange nans with zero to ensure compatibility with other applications
sl_nii = nib.Nifti1Image(sl_result, affine_mat)  # create the volume image
hdr = sl_nii.header  # get a handle of the .nii file's header
nib.save(sl_nii, output_dir)  # Save the volume
#plot results
sns.distplot(eval_score)
print(SUB+' - saving distribution of correlations')
plt.title('Distributions of correlations', size=18)
plt.ylabel('Occurance', size=18)
plt.xlabel('Spearmann correlation', size=18)
sns.despine()
# sale the plot
figure_name = 'ARCH_SL_'+MODEL+'_DOC_'+SUB
filenameFigures = os.path.join(OUT_plots,figure_name)
plt.savefig(filenameFigures,dpi=800)
# lets plot the voxels above the 99th percentile
threshold = np.percentile(eval_score, 99)
plot_img = new_img_like(tmp_img, RDM_brain)
cmap = RDMcolormapObject()
coords = range(-20, 40, 5)
print(SUB+' - saving plot of voxels above 99th percentile')
fig = plt.figure(figsize=(12, 3))
display = plotting.plot_stat_map(
    plot_img, colorbar=True, cut_coords=coords,threshold=threshold,
    display_mode='z', draw_cross=False, figure=fig,
    title=f'Model Evaluation'+SUB, cmap=cmap,
    black_bg=False, annotate=False)
figure_name = 'ARCH_SL_'+MODEL+'_'+SUB
filenameFigures = os.path.join(OUT_brains, figure_name)
plt.savefig(filenameFigures,dpi=800)
print(SUB+' - finished')
