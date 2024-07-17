function [] = ciNIRS(root)

% Bradley White, PhD
% April 2024

% This function will combine runs and read data from Hitachi ETG-4000 with
% two 3x5 probes and an EPrime file.

% Assumes Probe1 and Probe2 are equal sizes across tasks and runs.
% Assumes headers are the same across runs.

% Prerequisite: BIDS
% Outputs:      sub-000_task_MES_Merged_Probe0.csv

% root='/home/brad/Documents/MATLAB/adult-ci/data/';

subs=rdir(fullfile(root,'sub-*'));
% eprs=rdir(fullfile(root,'**',['sub-*_EPrime.csv']));
% mess=rdir(fullfile(root,'**',['sub-*_MES_Probe*.csv']));
% nods=rdir(fullfile(root,'**',['sub-*_NOD.csv']));

tasks={'Deletion';'Discrimination';'Rhyme';'Syntax';'Word';'Verb'};

% deletion_names={};
% discrimination_names={};
% rhyme_names={};
syntax_names={'OSGY','OSGN','SOGY','SOGN'};
word_names={'Regular', 'Irregular', 'Nonword'};
% verb_names={'Plain', 'Aspectual', 'Entity', 'Handling', 'Video','Response'};

% combine runs
for i=1:length(subs) % per subject
    
    % get this subject
    [~,sub]=fileparts(subs(i).name);
    
    progressbar([num2str(i),'/',num2str(length(subs)),'... ',sub],[],[]);
    
    for ii=1:length(tasks) % per task
        
        % get this task
        task=tasks{ii};
        
        progressbar([num2str(i),'/',num2str(length(subs)),'... ',sub],[num2str(ii),'/',num2str(length(tasks)),'... ',task],[]);
        
        for iii=1:2 % per probe
            
            % get these files
            files=rdir(fullfile(subs(i).name,['/sub-*',tasks{ii},'*_MES_Probe',num2str(iii),'.csv']));
            
            % skip if necessary
            if length(files)==0; continue % skip task if no files
                % elseif length(files)<2; continue % skip task if only one run
                
                % previous line commented out, go ahead and "merge" single runs
                % in order to produce the _nirs.mat file needed for analysis
                % with the NIRS Toolbox. This will create _MES_Merged_Probe#
                % files, but they will be almost identical to the single run.
                
            end
            
            if contains(task,'Discrimination');;
                try files(length(files)+1)=rdir(fullfile(subs(i).name,['/sub-*','English','*MES_Probe',num2str(iii),'.csv'])); end
                try files(length(files)+1)=rdir(fullfile(subs(i).name,['/sub-*','Hindi','*MES_Probe',num2str(iii),'.csv'])); end
                try files(length(files)+1)=rdir(fullfile(subs(i).name,['/sub-*','Tone','*MES_Probe',num2str(iii),'.csv'])); end
            end
            
            progressbar([num2str(i),'/',num2str(length(subs)),'... ',sub],[num2str(ii),'/',num2str(length(tasks)),'... ',task],[num2str(iii),'/2','... Probe',num2str(iii)]);
            pause(0.01);
            progressbar((i-1)/length(subs),(ii-1)/length(tasks),(iii-1)/2);
            
            % extract data
            info={}; data={}; marker={};
            for iv=1:length(files)
                [info{1,iv},data{iv},marker{iv}]=parsefile(files(iv).name);
            end
            
            % adjust timings
            for v=2:length(files)
                data{v}(:,1)=(data{v}(:,1)+data{v-1}(end,1));
            end
            
            % combine run data
            datcat = vertcat(data{:});
            
            % rebuild header from info{1}
            header{1,1} = 'Header';
            header{2,1} = ['File Version,',num2str(info{1}.File_Version)];
            header{3,1} = 'Patient Information';
            header{4,1} = ['ID,',sub];
            header{5,1} = 'Name,CI Study';
            header{6,1} = ['Comment,',task,' Merged'];
            header{7,1} = ['Birth Date,',num2str(info{1}.Birth_Date)];
            header{8,1} = ['Age,',strtrim(num2str(info{1}.Age))];
            header{9,1} = ['Sex,',info{1}.Sex];
            header{10,1} = 'Analyze Information';
            header{11,1} = 'AnalyzeMode,Continuous';
            header{12,1} = ['Pre Time[s],',num2str(info{1}.Pre_Time_s)];
            header{13,1} = ['Post Time[s],',num2str(info{1}.Post_Time_s)];
            header{14,1} = ['Recovery Time[s],',num2str(info{1}.Recovery_Time_s)];
            header{15,1} = ['Base Time[s],',num2str(info{1}.Base_Time_s)];
            header{16,1} = ['Fitting Degree,',num2str(info{1}.Fitting_Degree)];
            header{17,1} = ['HPF[Hz],',info{1}.HPF_Hz];
            header{18,1} = ['LPF[Hz],',info{1}.LPF_Hz];
            header{19,1} = ['Moving Average[s],',num2str(info{1}.Moving_Average_s)];
            header{20,1} = 'Measure Information';
            header{21,1} = ['Date,',num2str(info{1}.Date)];
            header{22,1} = 'Probe Type,Adult';
            header{23,1} = 'Mode,3x5';
            header{24,1} = ['Wave[nm],',num2str(info{1}.Wave_nm{1}),',',num2str(info{1}.Wave_nm{2})];
            header{25,1} = ['Wave Length,',strjoin(info{1}.Wave_Length(:), ',')];
            header{26,1} = ['Analog Gain,',strjoin(cellfun(@num2str,info{1}.Analog_Gain(:),'un',0),',')];
            header{27,1} = ['Digital Gain,',strjoin(cellfun(@num2str,info{1}.Digital_Gain(:),'un',0),',')];
            header{28,1} = ['Sampling Period[s],',num2str(info{1}.Sampling_Period_s)];
            header{29,1} = ['StimType,',info{1}.StimType];
            header{30,1} = 'Stim Time[s]';
            header{31,1} = ['F1,',strjoin(cellfun(@num2str,info{1}.F1(:),'un',0),',')];
            header{32,1} = ['Repeat Count,',num2str(info{1}.Repeat_Count)];
            header{33,1} = ['Exception Ch,',strjoin(cellfun(@num2str,info{1}.Exception_Ch(:),'un',0),',')];
            header{34,1} = [];
            header{35,1} = [];
            header{36,1} = [];
            header{37,1} = [];
            header{38,1} = [];
            header{39,1} = [];
            header{40,1} = 'Data';
            header{41,1} = ['Probe',num2str(iii),',',strjoin(info{1}.Wave_Length(:), ','),',Mark,BodyMovement,RemovalMark,PreScan'];
            
            % write header and combined run data
            for vi=1:size(datcat,1)
                datone{vi,1}=strjoin(cellfun(@num2str,num2cell(datcat(vi,1:end))','un',0),',');
            end
            
            cell2csv([subs(i).name,filesep,sub,'_',task,'_MES_Merged_Probe',num2str(iii),'.csv'],[header;datone],',');
            
        end
        
        % rebuilding
        
        % skip generating _nirs.mat if not written for task yet
        if contains(task,'Deletion'); continue
        elseif contains(task,'Discrimination'); continue
        elseif contains(task,'Rhyme'); continue
        elseif contains(task,'Word'); continue
        elseif contains(task,'Verb'); continue
        else
            
            mes_fn=rdir(fullfile(subs(i).name,['/sub-*',task,'_MES_Merged_Probe','*.csv']));
            if length(mes_fn)==0; continue % skip task if no files
            mes={mes_fn(1).name,mes_fn(2).name};
            
            info={}; data={}; marker={};
            for vii=1:length(mes)
                [info{1,vii},data{vii},marker{vii}]=parsefile(mes{vii});
                info{vii}.probe=['Probe', num2str(vii)];
                info{vii}.filename=mes{vii};
            end
            
            % build raw
            raw=nirs.core.Data;
            
            % raw.description
            [a b]=fileparts(mes{1});
            raw.description=a;
            
            % raw.data
            for viii=1:length(data)
                raw.data=horzcat(raw.data,data{viii}(:,1+[1:length(info{viii}.Wave_Length)]));
            end
            
            % raw.probe
            SrcPos=[]; DetPos=[]; link=table;
            for ix=1:length(info)
                probe=getprobefrominfo(info{ix});
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
            names={};
            if contains(task,'Syntax'); names=syntax_names;
            elseif contains(task,'Word'); names=word_names;
            end
            
            warning('off','all');
            try eprime = readtable(fullfile(subs(i).name,['/',sub,'_',task,'_EPrime_UTF8.txt'])); end
            warning('on','all');
            
            if contains(task,'Syntax')
                conds = eprime.Condition;
                for x=1:length(conds)
                    if contains(conds{x},'OSG'); conds{x}='OSGY';
                    elseif contains(conds{x},'OSUG'); conds{x}='OSGN';
                    elseif contains(conds{x},'SOG'); conds{x}='SOGY';
                    elseif contains(conds{x},'SOUG'); conds{x}='SOGN';
                    end
                end
                
                durs = ceil((eprime.Stimuli_RT/1000)*10)/10; % round up to nearest 10th to match Hz
                
                %             elseif contains(task,'Word'); names=word_names;
                %                 conds = eprime.ListType;
                %                 conds = conds(~cellfun('isempty',conds)) ;
                %                 durs = ceil((eprime.Word_RT/1000)*10)/10; % round up to nearest 10th to match Hz
                %                 durs(isnan(durs))=[];
            end
            
            [~,~,ic]=unique(marker{1}); % assuming probe 1 and probe 2 are identical
            
            for xi=1:length(names)
                stim=nirs.design.StimulusEvents;
                stim.name=names{xi};
                stim.onset=(raw.time(ic==2));
                stim.onset=stim.onset(contains(conds,names{xi}));
                stim.dur=durs(contains(conds,names{xi}));
                stim.amp=ones(size(stim.onset));
                raw.stimulus([names{xi}])=stim;
            end
            
            % raw.demographics
            raw.demographics('subject')=sub;
            raw.demographics('task')=task;
            
            % save to mat
            save([root, sub, filesep, sub, '_', task, '_NIRS.mat'], 'raw');
            
        end
    end
    
end
progressbar(1,1,1);
end