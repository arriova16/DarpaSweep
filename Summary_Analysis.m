%New script for summary data of sweep task
tld = 'C:\Users\arrio\Box\BensmaiaLab\UserData\UserFolders\ToriArriola\DARPA_updated\PreProcessedData';
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

%% Cath_getting
  Pinot_hybrid = fullfile(tld, 'Pinot', 'Cathodic_Anodic');
    mat_file_cath = dir(fullfile(Pinot_hybrid, '*.mat'));
    cath_an_struct = struct(); ii =1;
    for p1 = 1:size(mat_file_cath)
        cath_split = strsplit(mat_file_cath(p1).name,'_');
        electrode_cath = cath_split{2};
        task_cath = cath_split{3};
        pulse_cath = cath_split{6}(1:2);
       
        if contains(cath_split{2}, 'and')
            and_idx_cath = strfind(cath_split{2}, 'and');
            ee = [str2double(cath_split{2}(1:and_idx_cath-1)), str2double(cath_split{2}(and_idx_cath+3:end))];
        end
        cath_an_struct(ii).Monkey = 'Pinot';
        cath_an_struct(ii).Electrode = ee;
        cath_an_struct(ii).Task = task_cath;
        cath_an_struct(ii).Pulse = pulse_cath;
        temp_one = load(fullfile(mat_file_cath(p1).folder, mat_file_cath(p1).name));
        cath_an_struct(ii).ResponseTable = temp_one.bigtable;
        
        
 
       
    ii = ii+1;

    end
%% block analysis - DOESNT WORK


for dt = 1:length(cath_an_struct)
    cath_an_struct(dt).Pulse = convertCharsToStrings(cath_an_struct(dt).Pulse);
    pulse_data = vertcat(cath_an_struct(:).Pulse);
    cath_idx = strcmpi(pulse_data, 'Ca');

    cath_struct = struct();

    cath_struct = cath_an_struct(cath_idx) ;

end

for d2 = 1:length(cath_struct)

    [detection_table{d2}, dprime_table{d2}] = AnalyzeHybridTable(cath_struct(d2).ResponseTable);
    cath_struct(d2).DetectionTable = detection_table{d2};
    cath_struct(d2).DprimeTable = dprime_table{d2};
% 
    u_mech_amps = unique(cath_struct(d2).ResponseTable.IndentorAmp);
    dprime_block_2 = cath_struct(d2).DprimeTable{:,2};
    dprime_block_1 = cath_struct(d2).DprimeTable{:,1};

% 
% 
    x_block = u_mech_amps;
    y_block_1 = dprime_block_1;
    y_block_2 = dprime_block_2;
    [~, coeffs_woicms, ~, ~,~, warn_0] = FitSigmoid(x_block,y_block_1,'NumCoeffs', 2, 'CoeffInit', [100, .0002,NaN,NaN], 'Plotfit', true);
    [~, coeffs_wicms, ~, ~,~, warn_w] = FitSigmoid(x_block,y_block_2,'NumCoeffs', 2, 'CoeffInit', [100,.0002,NaN,NaN], 'Plotfit', true);

    cath_struct(d2).Coeff_w_icms = coeffs_wicms;
    cath_struct(d2).Coeff_wo_icms = coeffs_woicms;

end

%% finding thresholds between

for d3 = 1:size(cath_struct,2)

            siggy = GetSigmoid(4);
            u_mech = unique(cath_struct(d3).ResponseTable.IndentorAmp);   
            xq = linspace(0, .2);
            yq_w = sigfun(cath_struct(d3).Coeff_w_icms, xq);
            yq_wo = sigfun(cath_struct(d3).Coeff_wo_icms,xq);
            dprime_threshold = 1.35;
            hold on;
            [~, b] = min(abs(cath_struct(d3).Coeff_w_icms - dprime_threshold));
            [~, c] = min(abs(cath_struct(d3).Coeff_wo_icms - dprime_threshold));
            plot([0 xq(b) xq(b)], [dprime_threshold, dprime_threshold, -1], 'Color',rgb(26, 35, 126),'LineStyle', '--')
            plot([0 xq(c) xq(c)], [dprime_threshold, dprime_threshold, -1], 'Color',rgb(26, 35, 126),'LineStyle', '--')

            cath_struct(d3).ThresholdW= xq(b);
            cath_struct(d3).ThresholdWO = xq(c);
    
end

%% plot
subplot(1,3,1); hold on
    u_mech_3 = unique(cath_struct(1).ResponseTable.IndentorAmp);   

    plot(u_mech_3, cath_struct(1).DetectionTable{:,1}, 'Color',rgb(33, 33, 33))
    plot(u_mech_3, cath_struct(1).DetectionTable{:,2}, 'Color',rgb(211, 47, 47))
    
    xlabel(sprintf('Stimulus Amplitude (%sm)', GetUnicodeChar('mu')),'FontSize',18)
    ylabel('p(Detected)','FontSize',18)
    
    axis square
subplot(1,3,2); hold on
    plot(u_mech_3, cath_struct(1).DprimeTable{:,1}, 'Color',rgb(33, 33, 33))
    plot(u_mech_3, cath_struct(1).DprimeTable{:,2}, 'Color',rgb(211, 47, 47))
    xlabel(sprintf('Stimulus Amplitude (%sm)', GetUnicodeChar('mu')),'FontSize',18)
    ylabel('d''','FontSize',18)
    
    yline(1.35,'-', 'Threshold', 'FontSize', 15)
    axis square
subplot(1,3,3); hold on


    axis square


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
         % p_detect_temp = zeros(length(u_mech),length(u_icms));%1]);% * 1e-3;

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
    FA = max([icms_only{1,1}, 1e-3]); 
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
sweep_struct(m1).dprime_predict = dprime_predicted;

end %sweep_struct

%% Plotting

SetFont('Arial', 33)

monkey_list = vertcat(sweep_struct(:).Monkey);
WP_idx = strcmpi(monkey_list, 'Whistlepig');
Pinot_idx = strcmpi(monkey_list, 'Pinot');
Pinot_struct = struct(sweep_struct(Pinot_idx));
WP_struct = struct(sweep_struct(WP_idx));

%     subplot(1,2,1);
    hold on
    title('pDetect')
    for d1 = 1:length(Pinot_struct)
    %plotting pinot pdetect_obs
        scatter(Pinot_struct(d1).pdetect_predict{1,2},Pinot_struct(d1).pdetect_obs{2,3},150,'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
        scatter(Pinot_struct(d1).pdetect_predict{1,3},Pinot_struct(d1).pdetect_obs{2,4},150,'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
        scatter(Pinot_struct(d1).pdetect_predict{1,4},Pinot_struct(d1).pdetect_obs{2,5},150, 'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
 
        for d2 = 1:length(WP_struct)
            scatter(WP_struct(d2).pdetect_predict{1,2},WP_struct(d2).pdetect_obs{2,3},150,'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
            scatter(WP_struct(d2).pdetect_predict{1,3},WP_struct(d2).pdetect_obs{2,4},150,'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
            scatter(WP_struct(d2).pdetect_predict{1,4},WP_struct(d2).pdetect_obs{2,5},150,'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
         plot([0,5],[0,5], 'LineStyle','--','color', [.6,.6,.6])

        end

    end
    text(.6, .2, ColorText({'Monkey 1', 'Monkey 2'}, [rgb(183, 28, 28); rgb(13, 71, 161)]), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
    % text(.6, .2, 'Monkey 1', 'Color', rgb(183, 28, 28))
    % text(.6, .15, 'Monkey 2', 'Color', rgb(13, 71, 161))
     axis square
    xlim([0,1])
    ylim([0,1])
    yticks([.2,.4,.6,.8, 1])
    xlabel('Predicted (pDetect)')
    ylabel('Observed (pDetect)')
  

%     subplot(1,2,2); hold on
%     title('dPrime')
%     
%     for d1 = 1:length(Pinot_struct)
%         scatter(Pinot_struct(d1).dprime_predict(2,1), Pinot_struct(d1).dprime_obs{2,3},'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
%         scatter(Pinot_struct(d1).dprime_predict(3,1), Pinot_struct(d1).dprime_obs{2,4},'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
%         scatter(Pinot_struct(d1).dprime_predict(4,1), Pinot_struct(d1).dprime_obs{2,5}, 'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
%     
%     for d2 = 1:length(WP_struct)
%             scatter(WP_struct(d2).dprime_predict(2,1),WP_struct(d2).dprime_obs{2,3},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
%             scatter(WP_struct(d2).dprime_predict(3,1),WP_struct(d2).dprime_obs{2,4},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
%             scatter(WP_struct(d2).dprime_predict(4,1),WP_struct(d2).dprime_obs{2,5},'filled', 'MarkerEdgeColor',rgb(13, 71, 161), 'MarkerFaceColor',rgb(13, 71, 161))
%          plot([0,5],[0,5], 'LineStyle','--','color', [.6,.6,.6])
%         
% 
%     end
% 
% 
% 
%     end
% 
% 
%     xlabel('Predicted (dPrime)')
%     ylabel('Observed (dPrime)')
%     xlim([0,4])
%     ylim([0 4])
%     axis square
%% three analysis

% monkey = vertcat(sweep_struct(:).Monkey);
% WP_idx = strcmpi(monkey_list, 'Whistlepig');
% Pinot_idx = strcmpi(monkey_list, 'Pinot');
% Pinot_struct = struct(sweep_struct(Pinot_idx));
% WP_struct = struct(sweep_struct(WP_idx));


subplot(1,2,1); hold on
for i = 1:length(sweep_struct)
    
    low_diff(i) = sweep_struct(i).pdetect_obs{2,2} - sweep_struct(i).pdetect_obs{2,3};
    mid_diff(i) = sweep_struct(i).pdetect_obs{2,2} - sweep_struct(i).pdetect_obs{2,4};
    high_diff(i) = sweep_struct(i).pdetect_obs{2,2} - sweep_struct(i).pdetect_obs{2,5};
 end   

    low_diff = vertcat(low_diff);
    mid_diff = vertcat(mid_diff);
    high_diff = vertcat(high_diff);

    
    Swarm(1, low_diff)
    Swarm(2, mid_diff)
    Swarm(3, high_diff)

ylabel('\Delta Mechanical Only - Subthreshold \muA')
xticklabels({'low', 'medium', 'high'})
xlabel('Subthreshold \muA')

subplot(1,2,2); hold on
for d = 1:length(sweep_struct)
    mech_predict_diff(d) = sweep_struct(d).pdetect_predict{1} - sweep_struct(d).pdetect_obs{2,2};
    low_predict_diff(d) = sweep_struct(d).pdetect_predict{2} - sweep_struct(d).pdetect_obs{2,3};
    mid_predict_diff(d) = sweep_struct(d).pdetect_predict{3} - sweep_struct(d).pdetect_obs{2,4};
    high_predict_diff(d) = sweep_struct(d).pdetect_predict{4} - sweep_struct(d).pdetect_obs{2,5};
end

    % Swarm(1, mech_predict_diff)
    Swarm(1, low_predict_diff)
    Swarm(2, mid_predict_diff)
    Swarm(3, high_predict_diff)

ylabel('\Delta Predicted \muA - Observed \muA')
xticklabels({'low', 'medium', 'high'})
xlabel('Subthreshold \muA')


%%
% WP_idx = strcmpi(monkey_list, 'Whistlepig');
% Pinot_idx = strcmpi(monkey_list, 'Pinot');
% Pinot_struct = struct(sweep_struct(Pinot_idx));
% WP_struct = struct(sweep_struct(WP_idx));
subplot(1,2,1); hold on
for i = 1:length(Pinot_struct)
    
    Pinot_low_diff(i) = Pinot_struct(i).pdetect_obs{2,2} -  Pinot_struct(i).pdetect_obs{2,3};
    Pinot_mid_diff(i) =  Pinot_struct(i).pdetect_obs{2,2} -  Pinot_struct(i).pdetect_obs{2,4};
    Pinot_high_diff(i) =  Pinot_struct(i).pdetect_obs{2,2} - Pinot_struct(i).pdetect_obs{2,5};
end   
    Pinot_low_diff = vertcat(Pinot_low_diff);
    Pinot_mid_diff = vertcat(Pinot_mid_diff);
    Pinot_high_diff = vertcat(Pinot_high_diff);

for w = 1:length(WP_struct)
    WP_low_diff(w) = WP_struct(w).pdetect_obs{2,2} -  WP_struct(w).pdetect_obs{2,3};
    WP_mid_diff(w) =  WP_struct(w).pdetect_obs{2,2} -  WP_struct(w).pdetect_obs{2,4};
    WP_high_diff(w) =  WP_struct(w).pdetect_obs{2,2} - WP_struct(w).pdetect_obs{2,5};

end
    
    WP_low_diff = vertcat(WP_low_diff(1:3));
    WP_mid_diff = vertcat(WP_mid_diff(1:3));
    WP_high_diff = vertcat(WP_high_diff(1:3));
   
    elec_colors = [rgb(216, 27, 96); rgb(94, 53, 177); rgb(30, 136, 229); rgb(124, 179, 66)];

    
    Swarm(1, [Pinot_low_diff, WP_low_diff], "DS", 'Box', "Color", [.1 .1 .1])
    Swarm(2, [Pinot_mid_diff, WP_mid_diff], "DS", 'Box', "Color", [.1 .1 .1])
    Swarm(3, [Pinot_high_diff, WP_high_diff], "DS", 'Box', "Color", [.1 .1 .1])

    %old plot code
    % Swarm(3, Pinot_high_diff)
    % Swarm(1, WP_low_diff)
    % Swarm(2, WP_mid_diff)
    % Swarm(3, WP_high_diff)
    % swarmchart(1, Pinot_low_diff,100, elec_colors,'^', 'filled')
    % swarmchart(1,WP_low_diff,100,elec_colors(1:3, :), 'o', 'filled')
    % swarmchart(2,Pinot_mid_diff,100,elec_colors, '^', 'filled')
    % swarmchart(2,WP_mid_diff,100,elec_colors(1:3, :), 'o', 'filled')
    % swarmchart(3, Pinot_high_diff,100,elec_colors, '^', 'filled')
    % swarmchart(3,WP_high_diff,100,elec_colors(1:3, :), 'o', 'filled')


ylabel('\Delta Mechanical Only - Subthreshold')
xticks([1 2 3])
xticklabels({'Low', 'Medium', 'High'})
xlabel('Subthreshold \muA')
% text(3,.1, 'Pinot \Delta ')
% text(3, .08, "WP o")
axis square
subplot(1,2,2); hold on
for d = 1:length(Pinot_struct)
    Pinot_mech_predict_diff(d) = Pinot_struct(d).pdetect_predict{1} - Pinot_struct(d).pdetect_obs{2,2};
    Pinot_low_predict_diff(d) = Pinot_struct(d).pdetect_predict{2} - Pinot_struct(d).pdetect_obs{2,3};
    Pinot_mid_predict_diff(d) = Pinot_struct(d).pdetect_predict{3} - Pinot_struct(d).pdetect_obs{2,4};
    Pinot_high_predict_diff(d) = Pinot_struct(d).pdetect_predict{4} - Pinot_struct(d).pdetect_obs{2,5};
end

for d1 = 1:length(WP_struct)
    WP_mech_predict_diff(d1) = WP_struct(d1).pdetect_predict{1} - WP_struct(d1).pdetect_obs{2,2};
    WP_low_predict_diff(d1) = WP_struct(d1).pdetect_predict{2} - WP_struct(d1).pdetect_obs{2,3};
    WP_mid_predict_diff(d1) = WP_struct(d1).pdetect_predict{3} - WP_struct(d1).pdetect_obs{2,4};
    WP_high_predict_diff(d1) = WP_struct(d1).pdetect_predict{4} - WP_struct(d1).pdetect_obs{2,5};


end
    % Swarm(1, mech_predict_diff)
    % marker = 

    % elec_colors = [rgb(216, 27, 96); rgb(94, 53, 177); rgb(30, 136, 229); rgb(124, 179, 66)];
    Swarm(1,[Pinot_low_predict_diff, WP_low_predict_diff], "DS", 'Box','CM', "Color", [.1 .1 .1])
    Swarm(2,[Pinot_mid_predict_diff, WP_mid_predict_diff], "DS", 'Box', "Color", [.1 .1 .1])
    Swarm(3, [Pinot_high_predict_diff, WP_high_predict_diff], "DS", 'Box', "Color", [.1 .1 .1])

    %old plotting code
    % swarmchart(1, Pinot_low_predict_diff, 100, elec_colors, '^', 'filled')
    % swarmchart(1,WP_low_predict_diff,100, elec_colors(1:3, :), 'o','filled')
    % swarmchart(2, Pinot_mid_predict_diff,100, elec_colors, '^', 'filled')
    % swarmchart(2, WP_mid_predict_diff, 100, elec_colors(1:3, :), 'o','filled')
    % swarmchart(3,WP_high_predict_diff,100, elec_colors(1:3, :), 'o','filled')
    % swarmchart(3,Pinot_high_predict_diff,100, elec_colors, '^', 'filled')

ylabel('\Delta Predicted \muA - Observed \muA')
xticklabels({'Low', 'Medium', 'High'})
xticks([1 2 3])
% xlabel('Subthreshold \muA')
axis square