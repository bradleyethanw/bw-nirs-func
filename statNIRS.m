function [] = statNIRS(root)


% Bradley White, PhD
% March 2024

% This function will perform subject-level GLM with AR-IRLS pre-whitening
% and group-level LME with a specified function. Assumes data is already
% organized by groups for the NIRS Brain AnalyzIR Toolbox (see demos).

% Prerequisite: fixNIRS > readNIRS
% Outputs:      raw.mat
%               hb.mat
%               sub.mat
%               grp.mat

% root='/home/brad/Documents/MATLAB/func/data';

forg={'group','subject'} % assuming this structure, but can modify

% load data
files=rdir(fullfile(root,'**',['*_nirs.mat']));

data=nirs.core.Data.empty;
for iFile=1:length( files)
    load(files(iFile).name);
    data(end+1) = raw;
    disp(['Loading ', files(iFile).name, '...']);
    
    % split filename on separators
    fsplit=strsplit(files(iFile).name,filesep );
    rsplit=strsplit(root,filesep);
    
    % put demographics variables based on folder names
    demo = fsplit(length(rsplit)+1:end-1);
    data(end).description=files(iFile).name;
    for iDemo = 1:min(length(forg),length(demo))
        data(end).demographics(forg{iDemo}) = demo{iDemo};
    end
end
raw=data';
save([root, '/raw.mat'], 'raw');
disp(['Saving ', [root, '/raw.mat'], '...']);


% add demographics
% this is where to add a demographics table .csv for the group

% pre-processing
jobs=nirs.modules.RemoveStimless();
jobs=nirs.modules.FixNaNs(jobs);
% jobs = nirs.modules.Resample(jobs); % only resampling for speed testing
%     jobs.Fs = 1; % resample to 1 Hz
jobs=nirs.modules.OpticalDensity(jobs);
jobs=nirs.modules.BeerLambertLaw(jobs);
hb=jobs.run(raw);
save([root, '/hb.mat'], 'hb');
disp(['Saving ', [root, '/hb.mat'], '...']);

% first-level
% BE PATIENT - this step will take some time
disp(['Time for tea! If things are working, this part will take a while...']);
disp(['     ']);

jobs=nirs.modules.TrimBaseline();
   jobs.preBaseline=30;
   jobs.postBaseline=30;
jobs=nirs.modules.AR_IRLS(jobs);
sub=jobs.run(hb);
save([root, '/sub.mat'], 'sub');
disp(['Saving ', [root, '/sub.mat'], '...']);

% second-level
jobs=nirs.modules.MixedEffects();
    jobs.formula='beta~-1+group:cond+(1|subject)'; % assuming this formula, but can modify
grp=jobs.run(sub);
save([root, '/grp.mat'], 'grp');
disp(['Saving ', [root, '/grp.mat'], '...']);

end