function [BadTrlIdx, BadElecIdx] = preprocess_detectBadTrials(EEGlabStruct,opts)
% 
% EEGlabStruct   - EEGlab data structure
% opts   - options for detecting bad trials
% BadTrlIdx - returns indices of bad trials detected
% BadElecIdx - returns indices of corresponding bad electrodes detected
%_____________________________________________________________________________
% Based on discussions in https://sccn.ucsd.edu/pipermail/eeglablist/2014/008332.html
% and also in http://sccn.ucsd.edu/pipermail/eeglablist/2011/004085.html
% Author: Sridhar Jagannathan (01/01/2017).
%
% Copyright (C) 2017 Sridhar Jagannathan
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


if opts.threshold
    
    %threshold limits of scalp amplitudes in uV
    threshold.lower=-150;
    threshold.upper=150;
    
else
    
    threshold =[];
    
end

if opts.slope
    
    %slope maximum and rvalue..
    slope.maxval=60;
    slope.rVal=0.3;
    
else
    
    slope =[];
    
end

%Collect the parameters from the EEGlabStruct
    starttime = EEGlabStruct.xmin;
    epochLength=EEGlabStruct.xmax;
    epochTimeFrames=EEGlabStruct.pnts;
    sampleRate=EEGlabStruct.srate;
    events=EEGlabStruct.event;
    nElec=EEGlabStruct.nbchan;
    
    
%Do the error detecting and get the format for marking trials in eegplot
    if ~isempty(threshold)
        [EEGlabStruct,ThreshIdx]=pop_eegthresh(EEGlabStruct,1,1:nElec,threshold.lower,threshold.upper,starttime,epochLength,0,0);
        fprintf('The following epochs have been marked for rejection after thresholds \n');
        fprintf([num2str(ThreshIdx) '\n']);
        plotRejThr=trial2eegplot(EEGlabStruct.reject.rejthresh,EEGlabStruct.reject.rejthreshE,epochTimeFrames,EEGlabStruct.reject.rejthreshcol);
        EEGlabStruct.comments = pop_comments(EEGlabStruct.comments,'',['Filtered by pop_eegthresh, lowerLimit = ' num2str(threshold.lower) ',upperLimit = ' num2str(threshold.upper)],1);
   else
        plotRejThr=[];
    end
    
    if ~isempty(slope)
        [EEGlabStruct]=pop_rejtrend(EEGlabStruct,1,1:nElec,epochTimeFrames,slope.maxval,slope.rVal,1,0,0);
        plotRejTre=trial2eegplot(EEGlabStruct.reject.rejconst,EEGlabStruct.reject.rejconstE,epochTimeFrames,EEGlabStruct.reject.rejconstcol);
        EEGlabStruct.comments = pop_comments(EEGlabStruct.comments,'',['Filtered by pop_rejtrend, maxSlope = ' num2str(slope.maxval)],1);
    else
        plotRejTre=[];
    end
    
    
assignin('base', 'EEG', EEGlabStruct);
evalin('base','ArtefactsDetectionComplete=0;');
evalin('base','BadTrials=[];');
evalin('base','BadElectrodes=[];');

cmd = [ ...
        '[tmprej,tmprejE] = priv_eegplot2trial( TMPREJ, EEG.pnts, EEG.trials);' ...
        'BadTrials = tmprej;' ...
        'BadElectrodes = tmprejE;' ...
        'ArtefactsDetectionComplete=1;' ...
    ] ;

    rejE=[plotRejThr;plotRejTre];
    %Draw the data.
    priv_eegplot(EEGlabStruct.data,...
        'srate',sampleRate,...
        'events',events,...
        'winrej',rejE,...
        'command',cmd,...
        'butlabel','Reject');

    %Wait until the user has finished reviewing.
    reviewFinished=0;
    BadTrials = [];
    while ~reviewFinished
        reviewFinished=evalin('base','ArtefactsDetectionComplete');
        BadTrials =evalin('base','BadTrials'); 
        BadElectrodes =evalin('base','BadElectrodes'); 
        pause(0.01);
    end
   
    BadTrlIdx = find(BadTrials);
    BadElecIdx = BadElectrodes;
    evalin('base','clear ArtefactsDetectionComplete');


return