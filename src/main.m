clear all;
close all;
clc;
%% 1 Load the EEG file and the channel location

fs = 128;
[ALLEEG EGG CURRENTSET ALLCOM]=eeglab;
EEG = pop_loadset('resources/testeeglaboratorio.set');
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);

eeglab redraw;

eegplot(EEG.data, 'srate', fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 30, 'spacing', 100, 'color', {'k'},'title','EEG PLOT');

%% Baseline removal

% My baseline removal
for i = 1:EEG.nbchan
    tmpmean  = mean(double(EEG.data(i,:)),2);
    EEG.data(i,:) = EEG.data(i,:) - tmpmean;
end

[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EEG_BAS');

eegplot(EEG.data, 'srate', fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 30, 'spacing', 100, 'color', {'k'},'title','EEG_BAS PLOT ');

eeglab redraw;

% Eeglab baseline removal
% EEG = eeg_retrieve( ALLEEG, 1);
% 
% EEG = pop_rmbase( EEG, [], []);
% 
% [ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EEG_BAS2');
% 
% eegplot(EEG.data, 'srate', fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 30, 'spacing', 100, 'color', {'k'},'title','EEG_BAS2 PLOT ');
% 
% eeglab redraw;

%% Filtering the data [1-25 Hz]

EEG = pop_eegfilt( EEG, 1, 0, [], 0, 0, 1, 'fir1', 0); % highpass filter

[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EEG_BAS_FIL');
eegplot(EEG.data, 'srate', fs, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 30, 'spacing', 100, 'color', {'k'},'title','EEG_BAS_FIL PLOT ');

eeglab redraw;

%% Re-reference the data (use average reference)

EEG = pop_reref( EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EEG_FIL_BAS_AVE');
eegplot(EEG.data, 'srate', 250, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'spacing', 50, 'color', {'k'});

eeglab redraw;

%% Interpolate bad channel(s)

EEG = pop_interp(EEG, 13, 'spherical'); %% canale T3
[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EEG_FIL_BAS_AVE_INT');
eegplot(EEG.data, 'srate', 250, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'spacing', 50, 'color', {'k'});

eeglab redraw;

%% Run Independent Component Analysis (ICA) (using fastica)

EEG = pop_runica( EEG, 'icatype', 'fastica' );
[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EEG_FIL_BAS_AVE_INT_ICA');

eeglab redraw;

pop_eegplot(EEG,0,0,0);

% plot the componenst maps in 2-D (optional)
pop_topoplot(EEG, 0, [1: size(EEG.icawinv,2)], 'EEG_FIL_BAS_AVE_INT_ICA', [4 5], 0, 'electrodes', 'on');

%% ICA denoising

EEG = pop_subcomp( EEG, 1, 0); % removing first component
pop_eegplot(EEG,0,0,0);

eeglab redraw;

eegplot(EEG.data, 'srate', 250, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'spacing', 50, 'color', {'k'});



%% Extracting all type epochs after the events

EEG = pop_epoch( EEG, {'2' '4'}, [0 2], 'newname' ,'EOEC_epochs', 'epochinfo', 'yes' );
[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EOEC_epochs');

eeglab redraw;

eegplot(EEG.data, 'srate', 250, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 5, 'spacing', 50, 'color', {'k'});

%% Extract epochs Type 2 EC (eyes closed)

EEG = pop_selectevent(EEG,'type',2,'deleteevents','on','deleteepochs','on');
[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EC_epochsT2');

eeglab redraw;

eegplot(EEG.data, 'srate', 250, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'spacing', 50, 'color', {'k'});

%% Extract epochs Type 4 EO (eyes open)
EEG = eeg_retrieve( ALLEEG, 7 );

EEG = pop_selectevent(EEG,'type',4,'deleteevents','on','deleteepochs','on');
[ALLEEG EEG CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET,'setname','EO_epochsT4');

eegplot(EEG.data, 'srate', 250, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'spacing', 50, 'color', {'k'});

eeglab redraw;
%% Calculate power spectra density

EEG = eeg_retrieve( ALLEEG, 8 );
figure;
title('Type 2 EC (eyes closed)');
pop_spectopo( EEG, 1, [0 1996], 'EEG','percent',100,'freq',[6 11 22],'freqrange', [2 25], 'electrodes', 'on', 'maplimits', [-8 8]); 

EEG = eeg_retrieve( ALLEEG, 9 );
figure;
title('Type 4 EO (eyes open)');
pop_spectopo( EEG, 1, [0 1996], 'EEG','percent',100,'freq',[6 11 22],'freqrange', [2 25], 'electrodes', 'on', 'maplimits', [-8 8]); 





