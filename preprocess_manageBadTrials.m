function [EEGlabStruct] = preprocess_manageBadTrials(EEGlabStruct,opts)
% 
% EEGlabStruct   - EEGlab data structure
% opts   - options for managing bad trials
%
%_____________________________________________________________________________
% Author: Sridhar Jagannathan (05/07/2017).
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

[BadTrlIdx,BadElecIdx] = preprocess_detectBadTrials(EEGlabStruct,opts);

if opts.reject 
    
    fprintf('<--------Summary------------->\n');
    fprintf('The following epochs have been marked for rejection after manual inspection \n');
    fprintf([num2str(BadTrlIdx) '\n']);

    if ~isempty(BadTrlIdx)
            EEGlabStruct = pop_select(EEGlabStruct, 'notrial', BadTrlIdx);
            EEGlabStruct.rejepoch = BadTrlIdx;
    end
    
elseif opts.recon
    
    nrrejec = sum(BadElecIdx,1);
    rejelecscount = nrrejec(BadTrlIdx);
    [~,idx] = find(rejelecscount==0); %Remove the trials that have no bad electrodes..
    BadTrlIdx(idx)=[];
    EEGlabStruct.rejepoch = BadTrlIdx;
    EEGlabStruct.reconepoch = BadElecIdx;

    fprintf('\nInterpolating bad channels in a trial by trial manner...\n');
    for m = 1:length(BadTrlIdx)
        %tempEEG.data = EEG.data(:,:,BadTrlIdx(m));
        tempEEG = pop_select(EEGlabStruct, 'trial', BadTrlIdx(m)); %Select only the rejected trial..
        badelectrodes = find(BadElecIdx(:,BadTrlIdx(m)));
        strtxt = sprintf('%.0f,',badelectrodes');

        fprintf('\n Replacing electrodes %s in trial %d\n', strtxt(1:end-1), BadTrlIdx(m));

        tempEEG = eeg_interp(tempEEG, badelectrodes);
        %now put the data back..
        EEGlabStruct.data(badelectrodes,:,BadTrlIdx(m)) = tempEEG.data(badelectrodes,:);

    end
    
       
end
 

return