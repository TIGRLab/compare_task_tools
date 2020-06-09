

# load AFNI before submitting to queue

# GLM

sub_dir=$(ls -d -- /projects/loliver/SPINS_GLM_Test/sub*) # lists test subject directories
#/projects/loliver/SPINS_GLM_Test/sub-CMH0159

for dir in ${sub_dir}; do
    subj=$(basename ${dir})
   
    im_dir="/projects/colin/SPINS/EA_test_spm/${subj}"

# Empathic accuracy (with amplitude modulation) GLM for {subj} smoothed EA data
# TR of images is 1, which caused some onsets to be cut (forced to 2)
# AFNI does not allow block dur of 0, so switched to 1 for button presses
# ortvec confounds: fd, 6 motion, 6 motion derivatives, mean wm, mean csf
        #-mask ${out_dir}/anat_EPI_mask_MNI-nonlin.nii.gz \
        #-censor ${out_dir}/PARAMS/censor_EA.1D \

    if [ ! -f ${dir}/${subj}_glm_ea_1stlevel.nii.gz ]; then
      3dDeconvolve \
        -force_TR 2 \
        -input ${im_dir}/*desc-preproc_Atlas_s6.nii \
        -polort 5 \
        -num_stimts 4 \
        -ortvec ${dir}/${subj}_ea_confounds_glm.1D \
        -local_times \
        -jobs 4 \
        -x1D ${dir}/${subj}_glm_ea_1stlevel_design.mat \
        -stim_times_AM2 1 ${dir}/${subj}_ea.1D 'dmBLOCK(1)' \
        -stim_label 1 empathic_accuracy \
        -stim_times 2 ${dir}/${subj}_circles.1D 'BLOCK(40,1)' \
        -stim_label 2 circles \
        -stim_times 3 ${dir}/${subj}_ea_buttons.1D 'BLOCK(1,1)' \
        -stim_label 3 ea_press \
        -stim_times 4 ${dir}/${subj}_circ_buttons.1D 'BLOCK(1,1)' \
        -stim_label 4 circ_press \
        -fitts ${dir}/${subj}_glm_ea_1stlevel_explained.nii.gz \
        -errts ${dir}/${subj}_glm_ea_1stlevel_residuals.nii.gz \
        -bucket ${dir}/${subj}_glm_ea_1stlevel.nii.gz \
        -cbucket ${dir}/${subj}_glm_ea_1stlevel_coeffs.nii.gz \
        -fout \
        -tout \
        -xjpeg ${dir}/${subj}_glm_ea_1stlevel_matrix.jpg
    fi

done


