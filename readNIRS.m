function [raw] = readNIRS(probe1,probe2,nod)


% Bradley White, PhD
% March 2024

% This function will read data from Hitachi ETG-4000 with two 3x5 probes
% and a Names, Onsets, and Durations (NOD) file.

% Outputs:      sub-000_task.nirs

% probe1='/home/brad/Documents/MATLAB/func/data/hearing/sub-132/sub-132_LXBA_MES1.csv';
% probe2='/home/brad/Documents/MATLAB/func/data/hearing/sub-132/sub-132_LXBA_MES2.csv';
% nod='/home/brad/Documents/MATLAB/func/data/hearing/sub-132/sub-132_LX_NOD.mat';

% read Hitachi
mes={probe1,probe2};

for i=1:length(mes)
    [info{i},data{i},markers{i}]=parsefile(mes{i});
    info{i}.probe=['Probe', num2str(i)];
    info{i}.filename=mes{i};
end

% build raw
raw=nirs.core.Data;

% raw.description
[a b]=fileparts(probe1);
raw.description=a;

% raw.data
for i=1:length(data)
    raw.data=horzcat(raw.data,data{i}(:,1+[1:length(info{i}.Wave_Length)]));
end

% raw.probe
SrcPos=[]; DetPos=[]; link=table;
for i=1:length(info)
    probe=getprobefrominfo(info{i});
    l=probe.link;
    l.source=l.source+size(SrcPos,1);
    l.detector=l.detector+size(DetPos,1);
    SrcPos=[SrcPos; probe.srcPos];
    DetPos=[DetPos; probe.detPos];
    link=[link; l];
end
load('func/nirs_brad/real_link.mat');
link(1:end,1)=table(real_link(1:end,1));
link(1:end,2)=table(real_link(1:end,2));
raw.probe=nirs.core.Probe(SrcPos,DetPos,link);

% raw.time and raw.Fs
raw.time=[0:size(data{1},1)-1]*0.1;

% raw.stimulus
load(nod);

for i=1:length(onsets)
    onsets{i}=(onsets{i}+49)/10; % adjust and convert from scans to time
end

for i=1:length(durations)
    durations{i}=durations{i}/10; % convert from scans to time
end

for i=1:length(names)
    stim=nirs.design.StimulusEvents;
    stim.onset=onsets{i};
    stim.dur=durations{i};
    stim.amp=ones(size(stim.onset));
    raw.stimulus([names{i}])=stim;
end

% raw.demographics
[c d]=fileparts(a);
raw.demographics('subject')=d;
raw.demographics('task')=info{1}.Comment;

% save to mat
save([a, filesep, d, '_nirs.mat'], 'raw');
end