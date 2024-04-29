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

tasks = vertcat(data(:).Task);
me_idx = strcmpi(tasks, 'ME');
sweep_idx = strcmpi(tasks, 'Sweep');
sweep_some = data(sweep_idx).RT;
sweep_struct = struct(data(sweep_idx));
 
for p = 1:length(sweep_struct)
    sweep_struct(p).RT = sweep_struct(p).RT.CatTable;
end

%% Sweep Analysis
%observed detection rates
for d = 1:length(sweep_struct)
    u_icms = unique(sweep_struct(d).RT.StimAmp);
    [u_mech, ~, ia] = unique(sweep_struct(d).RT.IndentorAmp);
    [pd_strings_big, dp_strings_big] = deal(cell(1, length(u_icms)));
    p_detect = zeros([length(u_mech),length(u_icms)]);
    dprime = NaN([length(u_mech),length(u_icms)]);
    for u = 1:length(u_icms)
        % Initalize arrays
        p_detect_temp = ones([length(u_mech),1]) * 1e-3;
        dprime_temp = NaN([length(u_mech),1]);
        for j = 1:length(u_mech)
            trial_idx = ia == j & [sweep_struct(d).RT.StimAmp] == u_icms(u);
            correct_idx = strcmp(sweep_struct(d).RT.Response(trial_idx), 'correct');
            if u_mech(j) == 0
                p_detect_temp(j) = 1 - (sum(correct_idx) / sum(trial_idx));
            else
                p_detect_temp(j) = sum(correct_idx) / sum(trial_idx);
            end
        end
        p_detect(:,u) = p_detect_temp;
        % Compute d'
        %dprime wrong- no longer the same dprime formula- needs to be changed-
        %all have the same FA point.
        % pmiss_big = max([p_detect(1), 1e-3]);
        pmiss =  max([p_detect(1,1), 1e-3]);
        for j = 1:length(dprime_temp)-1
             phit = p_detect_temp(j+1);
            if phit == 1 % Correct for infinite hit rate
                phit = .999;
            elseif phit == 0
                phit = 1e-3;
            end
            dprime_temp(j+1) = norminv(phit) - norminv(pmiss);
        end
        dprime(:,u) = dprime_temp;
        % Make strings
        pd_strings_big{u} = sprintf('pDetect_%d', u_icms(u));
        dp_strings_big{u} = sprintf('dPrime_%d', u_icms(u));
    end
    sweep_struct(d).pdetect_obs = array2table([u_mech, p_detect], 'VariableNames', ['TestAmps', pd_strings_big]);
    sweep_struct(d).dprime_obs = array2table([u_mech, dprime], 'VariableNames', ['TestAmps', dp_strings_big]);

end
 %% Predicted Detection Rates
% sweep_probabilty formula
% P(A)+P(B) - P(A)*(and)P(B)
% P(A) = probability of Mechanical- just mechanical
% P(B) = Probability of Electrical- just electrical 
%predicted is from the formula / observed is icms w/ mechnical

for m1 = 1:length(sweep_struct)
    
    mech = sweep_struct(m1).pdetect_obs{2,1};
    icms_only = sweep_struct(m1).pdetect_obs(1,2:end);
    for m = 1:size(icms_only,2)
        empty_icms = zeros([size(icms_only,2)]);
        predict_pdetect{m} = (mech + icms_only{:,m}) - (mech .* icms_only{:,m});
    end
    FA = max([icms_only{1,1}, 1e-3]); 

    for j = 1:size(empty_icms)-1
        phit_predict = predict_pdetect{j+1};

        if phit_predict == 1
            phit_predict = .999;
        elseif phit_predict == 0
            phit_predict = 1e-3;
        end
        
        empty_icms(j+1) = norminv(phit_predict) - norminv(FA);
    end
    dprime_predicted = empty_icms;
end


