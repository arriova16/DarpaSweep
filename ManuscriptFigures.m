% Across Figures Params
%summary 
SetFont('Arial', 12)

%% Figure 1

% A

% B

% C

% D



%% Figure 3

% Load data file from analysis script
% load('./Data/Monkey_struct.mat')

figure('OuterPosition', [200 200 800 500])
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
   
    amp_colors = [rgb(255, 179, 0); rgb(251, 140, 0); rgb(244, 81, 30)];

    Swarm(1, [Pinot_low_diff, WP_low_diff], "DS", 'Box', "Color", amp_colors(1, :))
    Swarm(2, [Pinot_mid_diff, WP_mid_diff], "DS", 'Box', "Color", amp_colors(2, :))
    Swarm(3, [Pinot_high_diff, WP_high_diff], "DS", 'Box', "Color", amp_colors(3, :))

ylabel('\Delta Mechanical Only - Subthreshold')
xticks([1 2 3])
xticklabels({'Low', 'Medium', 'High'})
xlabel('Subthreshold \muA')
axis square

% Add Kruskal-Wallis test results

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

    % elec_colors = [rgb(216, 27, 96); rgb(94, 53, 177); rgb(30, 136, 229); rgb(124, 179, 66)];
    Swarm(1,[Pinot_low_predict_diff, WP_low_predict_diff])
    Swarm(2,[Pinot_mid_predict_diff, WP_mid_predict_diff])
    Swarm(3, [Pinot_high_predict_diff, WP_high_predict_diff])

ylabel('\Delta Predicted \muA - Observed \muA')
xticklabels({'Low', 'Medium', 'High'})
xticks([1 2 3])
axis square