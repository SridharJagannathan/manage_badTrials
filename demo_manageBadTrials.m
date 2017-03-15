loadpath; %path for eeglab
S.eeg_filepath = '/work/imagingP/SpatialAttention_Drowsiness/Scripts/manage_badTrials/';
S.eeg_filename = 'demo';

EEG_Orig = pop_loadset('filename', [S.eeg_filename '.set'], 'filepath', S.eeg_filepath);
EEG_Demo1 = EEG_Orig;
EEG_Demo2 = EEG_Orig;
EEG_Demo3 = EEG_Orig;
EEG_Demo4 = EEG_Orig;


 opts.reject = 1; opts.recon = 0;
 opts.threshold = 1; opts.slope = 0;
 [EEG_Demo1] = preprocess_manageBadTrials(EEG_Demo1,opts);
 temp = [];
  

opts.reject = 1; opts.recon = 0;
opts.threshold = 0; opts.slope = 1;
[EEG_Demo2] = preprocess_manageBadTrials(EEG_Demo2,opts);

temp = [];

opts.reject = 0; opts.recon = 1;
opts.threshold = 1; opts.slope = 0;
[EEG_Demo3] = preprocess_manageBadTrials(EEG_Demo3,opts);

temp = [];

opts.reject = 0; opts.recon = 1;
opts.threshold = 0; opts.slope = 1;
[EEG_Demo4] = preprocess_manageBadTrials(EEG_Demo4,opts);

temp = [];

