# Comparison of fMRI Task Analysis Software


Working Group Goals

    focus on task analysis
    create a standard streamline process
    output - single subject stat maps, what people need, can also do a parallel volume analysis if needed (for Randy's PLS approach)
        contrast beta weights, t map for each contrast for each subject, beta weights to store parameters, residuals - time series for each voxel after you remove all the task effects 
    potential group analysis outputs (will think about later) 

Packages/tools - one isn't really better for integrating with other imaging data

    Always start with fmriprep and then ciftify to project onto the surface
    Then some kind of smoothing - ciftify clean
        6 mm is pretty/consensus (or 4 mm)
        for volume 8 mm (12 mm just blurs data) 
    each participant has a csv for each of their tasks, also a json with the task architecture - fitlins can read the csvs 

    AFNI - known
    SPM - is in matlab, known, lots of tools
    python tools - nistats (same group as nilearn, fitlins the Poldrack is working on, wrapping so that you can execute it on a bids folder - one json file with options), group level through PALM
        fitlins is task specific, fit glm and do stats on the contrast - design model, fit, stats
        github issue - nistats & SPM correlated 0.96 across 20 participants, but using dependent parametric modulation goes down to 0.67
        ciftify clean uses nilearns signal clean 

    want nuisance regressors inside of GLM - different from resting-state
        important because want to look for task effects at the same time, whereas with resting state this is just pre correlating different regions 
    Randy's PLS pipeline requires volume data - can use stat maps, can't see all results, just have to create fake nii files (pushes surface data into a nii) 

Next Steps:

    focus on empathic accuracy first
    Michael will choose 10 SPINS participants, same site, good enough performance
    Colin will choose regressors (won't be the final ones, just for the pilot)
        not using 36p nuisance regressors
        https://cobidas-checklist.herokuapp.com 
    Run fitlins/nistats (Thomas) and SPM (Colin) and AFNI (Lindsay) and see if findings are consistent
        if dissimilar examine design matrix to see if they can converge
        parametric modulator - most likely will differ 

