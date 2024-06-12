%New script for summary data of sweep task
tld = 'C:\Users\arrio\OneDrive\DARPA\Data\ProcessedData';
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
       data(m).Monkey = convertCharsToStrings(data(m).Monkey);
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
% 
for p = 1:length(sweep_struct)
    sweep_struct(p).RT = sweep_struct(p).RT.CatTable;
end
sweep_struct = sweep_struct(2:8);

%% Sweep Analysis redo




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
        p_detect_temp = ones([length(u_mech),1]);% * 1e-3;
%          p_detect_temp = zeros(length(u_mech),length(u_icms));%1]);% * 1e-3;

        dprime_temp = NaN([length(u_mech),1]);
        for j = 1:length(u_mech)
            trial_idx = [sweep_struct(d).RT.IndentorAmp] == u_mech(j) & [sweep_struct(d).RT.StimAmp] == u_icms(u);
            % trial_idx = ia == j & [sweep_struct(d).RT.StimAmp] == u_icms(u);
            correct_idx = strcmp(sweep_struct(d).RT.Response(trial_idx), 'correct');
            if u_mech(j) == 0
                p_detect_temp(j) = 1 - (sum(correct_idx) / sum(trial_idx));
            else
                p_detect_temp(j) = sum(correct_idx) / sum(trial_idx);
            end
        end
        p_detect(:,u) = p_detect_temp;
        
    %     % Compute d'
    %     %dprime wrong- no longer the same dprime formula- needs to be changed-
    %     %all have the same FA point.
        % pmiss_big = max([p_detect(1), 1e-3]);
        pmiss =  max([p_detect(1,1)]);
        % pmiss =  max([p_detect(1,1), 1e-3]);

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
%% Checking pdetect

hold on
for i = 1:length(sweep_struct)
plot(sweep_struct(3).pdetect_obs{:,1}, sweep_struct(3).pdetect_obs{:,2},'o-', 'MarkerSize', 5,'Color',rgb(229, 115, 115), 'LineWidth', 4);
plot(sweep_struct(3).pdetect_obs{:,1}, sweep_struct(3).pdetect_obs{:,3},'o-', 'MarkerSize', 5,'Color',rgb(229, 115, 115), 'LineWidth', 4);
plot(sweep_struct(3).pdetect_obs{:,1}, sweep_struct(3).pdetect_obs{:,4},'o-', 'MarkerSize', 5,'Color',rgb(211, 47, 47), 'LineWidth', 4);
plot(sweep_struct(3).pdetect_obs{:,1}, sweep_struct(3).pdetect_obs{:,5},'o-', 'MarkerSize', 5,'Color',rgb(183, 28, 28), 'LineWidth', 4);

% text(.01,0.15, '0','Color',rgb(229, 115, 115), 'FontSize', 18)
% text(.01,0.2, '11','Color',rgb(229, 115, 115), 'FontSize', 18)
% text(.01,0.25, '12','Color',rgb(211, 47, 47), 'FontSize', 18)
% text(.01,0.3, '16','Color',rgb(183, 28, 28), 'FontSize', 18)
xlabel('Amplitude (mm)','FontSize', 18)
ylabel('p(Detected)','FontSize',18)
ylim([0 1])
axis square
end

 %% Predicted Detection Rates
% sweep_probabilty formula
% P(A)+P(B) - P(A)*(and)P(B)
% P(A) = probability of Mechanical- just mechanical
% P(B) = Probability of Electrical- just electrical 
%predicted is from the formula / observed is icms w/ mechnical

for m1 = 1:length(sweep_struct)
    
    mech = sweep_struct(m1).pdetect_obs{2,2};
    icms_only = sweep_struct(m1).pdetect_obs(1,2:end);
    for m = 1:size(icms_only,2)
        %predicted is incorrect
        empty_icms = zeros([size(icms_only,2)]);
        predict_pdetect{m} = (mech + icms_only{:,m}) - (mech .* icms_only{:,m});
    end %icms_only
    FA = max([icms_only{1,1}]); 
%dprime incorrect
    for j = 1:size(empty_icms)-1

        phit_predict = predict_pdetect{j+1};

        if phit_predict == 1
            phit_predict = .999;
        elseif phit_predict == 0
            phit_predict = 1e-3;
        end
        
        empty_icms(j+1) = norminv(phit_predict) - norminv(FA);
    end %empty_icms
    dprime_predicted = empty_icms;
sweep_struct(m1).pdetect_predict = predict_pdetect;
sweep_struct(m1).dprime_predict = reshape(dprime_predicted;

end %sweep_struct

%% Plotting

SetFont('Arial', 18)

monkey_list = vertcat(sweep_struct(:).Monkey);
WP_idx = strcmpi(monkey_list, 'Whistlepig');
Pinot_idx = strcmpi(monkey_list, 'Pinot');
Pinot_struct = struct(sweep_struct(Pinot_idx));
WP_struct = struct(sweep_struct(WP_idx));

    subplot(1,2,1);
    hold on
    title('pDetect')
    for d1 = 1:length(Pinot_struct)
    %plotting pinot pdetect_obs
        scatter(Pinot_struct(d1).pdetect_predict{1,2},Pinot_struct(d1).pdetect_obs{2,3},'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
        scatter(Pinot_struct(d1).pdetect_predict{1,3},Pinot_struct(d1).pdetect_obs{2,4},'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
        scatter(Pinot_struct(d1).pdetect_predict{1,4},Pinot_struct(d1).pdetect_obs{2,5}, 'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
 
        for d2 = 1:length(WP_struct)
            scatter(WP_struct(d2).pdetect_predict{1,2},WP_struct(d2).pdetect_obs{2,3},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
            scatter(WP_struct(d2).pdetect_predict{1,3},WP_struct(d2).pdetect_obs{2,4},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
            scatter(WP_struct(d2).pdetect_predict{1,4},WP_struct(d2).pdetect_obs{2,5},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
         plot([0,5],[0,5], 'LineStyle','--','color', [.6,.6,.6])

        end

    end
    text(.6, .2, 'Monkey 1', 'Color',rgb(183, 28, 28))
    text(.6, .15, 'Monkey 2', 'Color', rgb(13, 71, 161))
   
    xlim([0,1])
    ylim([0,1])
    xlabel('Predicted (pDetect)')
    ylabel('Observed (pDetect)')
    axis square

    subplot(1,2,2); hold on
    title('dPrime')
    
    for d1 = 1:length(Pinot_struct)
        scatter(Pinot_struct(d1).dprime_predict(2,1), Pinot_struct(d1).dprime_obs{2,3},'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
        scatter(Pinot_struct(d1).dprime_predict(3,1), Pinot_struct(d1).dprime_obs{2,4},'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
        scatter(Pinot_struct(d1).dprime_predict(4,1), Pinot_struct(d1).dprime_obs{2,5}, 'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
    
    for d2 = 1:length(WP_struct)
            scatter(WP_struct(d2).dprime_predict(2,1),WP_struct(d2).dprime_obs{2,3},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
            scatter(WP_struct(d2).dprime_predict(3,1),WP_struct(d2).dprime_obs{2,4},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
            scatter(WP_struct(d2).dprime_predict(4,1),WP_struct(d2).dprime_obs{2,5},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
         plot([0,5],[0,5], 'LineStyle','--','color', [.6,.6,.6])
        

    end



    end


%     xlabel('Predicted (dPrime)')
    ylabel('Observed (dPrime)')
    xlim([0,4])
    ylim([0 4])
    axis square


%% three analysis
figure; hold on
for i = 1:length(sweep_struct)

%     sweep_struct(i).dprime_predict = vercat(sweep_struct(i).dprime_predict{:,1);

    x1 = repmat({'Low'},sweep_struct(i).dprime_predict(2,1));
    x2 = repmat({'Middle'},sweep_struct(i).dprime_predict(3,1));
    x3 = repmat({'High'},sweep_struct(i).dprime_predict(4,1));
    g = [x1; x2; x3];

%     boxpchart(sweep_struct(i).dprime_predict:,1})


end