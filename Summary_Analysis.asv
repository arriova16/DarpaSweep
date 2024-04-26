%New script for summary data of sweep task
tld = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\ProcessedData';
file_list = dir(tld);

%% loading mat files

monkey = file_list(3:end);

data = struct(); ii =1;
for i = 1:length(monkey)

    monkey_folders = fullfile(tld, monkey(i).name, 'DarpaSweep');
    electrode_folders = fullfile(monkey_folders, 'Electrode*');
    %getting mat files
    mat_file = dir(fullfile(electrode_folders, '*.mat'));
    electrode = dir(electrode_folders);
    electrode = electrode.name;
    %loading tables
    for m = 1:size(mat_file)
       mat_split = strsplit(mat_file(m).name, '_');
       mat_idx = mat_split{3};
       data(ii).Monkey = mat_split{1};

       if contains(mat_split{2}, 'and')
           and_idx = strfind(mat_split{2}, 'and');
           ee = [str2double(mat_split{2}(1:and_idx-1)), str2double(mat_split{2}(and_idx+3:end))];
       end

       data(ii).Electrode = ee;
       %need to fix
       data(ii).Task = mat_split{3};

       data(m).Task= convertCharsToStrings(data(m).Task);
%         
% 
%        %need to fix
%    
       stuff_try = load(fullfile(mat_file(m).folder, mat_file(m).name));
       data(ii).RT = stuff_try;

       %fix later
       if data(m).Task == "ME.mat"
%          data(m).Task = data(m).Task(1:2);
       end
%        if data(m).Task == "ME"
%            data(ii).RT = data(ii).RT;
%        end
       ii = ii+1;


    end
 
end

%% Sweep Analysis
%observed detection rates

tasks = vertcat(data(:).Task);
me_idx = strcmpi(tasks, 'ME');
sweep_idx = strcmpi(tasks, 'Sweep');
sweep_some = data(sweep_idx).RT;
sweep_struct = struct();
sweep_struct = data(sweep_idx);
 
for d = 1:length(sweep_struct)
    sweep_struct(d).RT = sweep_struct(d).RT.CatTable;
    u_icms = unique(sweep_struct(d).RT.StimAmp);
    [u_mech,~, ia] = unique(sweep_struct(d).RT.IndentorAmp);
    p_detect = zeros([length(u_mech), length(u_icms)]);
    dprime = NaN([length(u_mech), length(u_icms)]);

    for e = 1:length(u_icms)
        p_detect_temp = ones([length(u_mech), 1]) * 1e-3;
        dprime_temp = NaN([length(u_mech),1]);

        for m = 1:length(u_mech)
            trial_idx = ia == m & [sweep_struct(d).RT.StimAmp] == u_icms(e); 
            correct_idx = strcmp(sweep_struct(d).RT.Response(trial_idx), 'correct');
            if u_mech(m) == 0
                p_detect_temp(m) = 1- (sum(correct_idx)/sum(trial_idx));
            else
                p_detect_temp(m) = sum(correct_idx)/sum(trial_idx);
            end

        end
        p_detect(:,e) = p_detect_temp;
        
        p_miss = max([p_detect(1,1), 1e-3]);

        
    end

    
end

