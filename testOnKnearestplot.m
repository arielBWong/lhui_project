
prob_str = 'smd4()';
seed     = 2;
tic;
ulego_klocal_singlelevel(prob_str, seed, 'EIMnext_dace' , 'EIM_evaldace', ...
    'normalization_y', true);
toc;