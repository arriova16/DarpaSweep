%Combination of Mech_Elect with SweepTask
sweep_df = 'Z:\UserFolders\ToriArriola\DARPA_updated\ProcessedData\Pinot\DarpaSweep\Electrode_3and23';
% sweep_df = 'C:\Users\arrio\Box\BensmaiaLab\UserData\UserFolders\ToriArriola\DARPA_updated\ProcessedData';
file_list = dir(sweep_df);

 %% Loading mat files

 block_struct = struct(); ii =1;
%need to figure out how to avoid this and go straight to matfiles

mat_file = dir(fullfile(sweep_df, '*.mat'));
name_split = strsplit(sweep_df, '\');
Monkey = name_split{6};
electrode = (name_split{8}(11:end));

%loading tables 
 for i = 1:size(mat_file,1)
     %hard coded need to fix
    ME_temp = load(fullfile(mat_file(1).folder, mat_file(1).name));
    sweep_temp = load(fullfile(mat_file(2).folder, mat_file(2).name));
    
    block_struct(ii).MechDetectTable = ME_temp.data.MechDetectTable;
    block_struct(ii).ElectDetectTable = ME_temp.data.ElectDetectTable;
    block_struct(ii).SweepDetectTable = sweep_temp.CatTable;
 
 end

%%


 %% Sweep Analysis
%create function


u_icms_big = unique(block_struct.SweepDetectTable.StimAmp);
[u_test_amps_big, ~, ia] = unique(block_struct.SweepDetectTable.IndentorAmp);
[pd_strings_big, dp_strings_big] = deal(cell(1, length(u_icms_big)));
p_detect_big = zeros([length(u_test_amps_big),length(u_icms_big)]);
dprime_big = NaN([length(u_test_amps_big),length(u_icms_big)]);
for u = 1:length(u_icms_big)
    % Initalize arrays
    p_detect = ones([length(u_test_amps_big),1]) * 1e-3;
    dprime = NaN([length(u_test_amps_big),1]);
    for j = 1:length(u_test_amps_big)
        trial_idx_big = ia == j & [block_struct.SweepDetectTable.StimAmp] == u_icms_big(u);
        correct_idx_big = strcmp(block_struct.SweepDetectTable.Response(trial_idx_big), 'correct');
        if u_test_amps_big(j) == 0
            p_detect(j) = 1 - (sum(correct_idx_big) / sum(trial_idx_big));
        else
            p_detect(j) = sum(correct_idx_big) / sum(trial_idx_big);
        end
    end
    p_detect_big(:,u) = p_detect;
    % Compute d'
    %dprime wrong- no longer the same dprime formula- needs to be changed-
    %all have the same FA point.
    % pmiss_big = max([p_detect(1), 1e-3]);
    pmiss_big =  max([p_detect_big(1,1), 1e-3]);
    for j = 1:length(dprime)-1
         phit_big = p_detect(j+1);
        if phit_big == 1 % Correct for infinite hit rate
            phit_big = .999;
        elseif phit_big == 0
            phit_big = 1e-3;
        end
        dprime(j+1) = norminv(phit_big) - norminv(pmiss_big);
       

    end
  
    dprime_big(:,u) = dprime;
    % Make strings
    pd_strings_big{u} = sprintf('pDetect_%d', u_icms_big(u));
    dp_strings_big{u} = sprintf('dPrime_%d', u_icms_big(u));
end

DetectionRates = array2table([u_test_amps_big, p_detect_big, dprime_big], 'VariableNames', ['TestAmps', pd_strings_big, dp_strings_big]);

%% plotting detection table for check
%fix this/fewer lines
hold on
plot(DetectionRates{:,1}, DetectionRates{:,2},'o-', 'MarkerSize', 5,'Color',rgb(229, 115, 115), 'LineWidth', 4);
plot(DetectionRates{:,1}, DetectionRates{:,3},'o-', 'MarkerSize', 5,'Color',rgb(229, 115, 115), 'LineWidth', 4);
plot(DetectionRates{:,1}, DetectionRates{:,4},'o-', 'MarkerSize', 5,'Color',rgb(211, 47, 47), 'LineWidth', 4);
plot(DetectionRates{:,1}, DetectionRates{:,5},'o-', 'MarkerSize', 5,'Color',rgb(183, 28, 28), 'LineWidth', 4);

% text(.01,0.15, '0','Color',rgb(229, 115, 115), 'FontSize', 18)
% text(.01,0.2, '11','Color',rgb(229, 115, 115), 'FontSize', 18)
% text(.01,0.25, '12','Color',rgb(211, 47, 47), 'FontSize', 18)
% text(.01,0.3, '16','Color',rgb(183, 28, 28), 'FontSize', 18)
xlabel('Amplitude (mm)','FontSize', 18)
ylabel('p(Detected)','FontSize',18)
ylim([0 1])
axis square
%% observed pdetect
    stuff_block = struct();
u_icms = unique(block_struct.SweepDetectTable.StimAmp);
[u_mech, ~, ia] = unique(block_struct.SweepDetectTable.IndentorAmp);
[op_strings,pp_string] = deal(cell(1, length(u_icms)));

op_detect_try = zeros([length(u_mech),length(u_icms)]);
pp_detect_tot = NaN([length(u_mech), length(u_icms)]);

for u = 1:length(u_icms)
    %initalize array, number going to 3 decimal pt? 
    op_detect = ones([length(u_mech),1]) * 1e-3;
    pp_detect = NaN([length(u_mech),1]);

    for j = 1:length(u_mech)
       trial_idx = ia == j & [block_struct.SweepDetectTable.StimAmp] == u_icms(u);
       correct_idx = strcmp(block_struct.SweepDetectTable.Response(trial_idx), 'correct');
       if u_mech(j) == 0
           op_detect(j) = 1 - (sum(correct_idx) / sum(trial_idx));
       else
           op_detect(j) = sum(correct_idx) / sum(trial_idx);
       end

    end
op_detect_try(:,u) = op_detect;


op_strings{u} = sprintf('ICMS_%d', u_icms(u));
end

sweep_pdetect = array2table([u_mech, op_detect_try], 'VariableNames',['MechAmps', op_strings]);

%% predicted pdetect and dprime

% sweep_probabilty formula
% P(A)+P(B) - P(A)*(and)P(B)
% P(A) = probability of Mechanical- just mechanical
% P(B) = Probability of Electrical- just electrical 
%predicted is from the formula / observed is icms w/ mechnical

mech = op_detect_try(2,1);
icms_FA = op_detect_try(1,:);
empty_icms = zeros([length(icms_FA),1]);

for m = 1:length(icms_FA) 
   predict(m) = (mech + icms_FA(m)) - (mech .* icms_FA(m));
end
%incorrect icms_FA - still the same as predicted points
FA = max([icms_FA(1), 1e-3]);

    % for j = 1:size(icms_FA)-1
    %incorrect (values too high) 
     for j = 1:size(empty_icms)-1
         phit = predict(j+1);
        if phit == 1 % Correct for infinite hit rate
            phit = .999;
        elseif phit == 0
            phit = 1e-3;
        end
        empty_icms(j+1) = norminv(phit) - norminv(FA);
    end

    dprime_predicted = empty_icms;
% drpime = using wrong mechanical / instead of using just mechanical- use just FA
%%  


%mech table dt
[MechDetect_DT] = AnalyzeMechTable(block_struct.MechDetectTable);
x_mech = MechDetect_DT.MechAmp;
% y_mech_dprime = MechDetect_DT.dPrime;
y_mech_pdetect = MechDetect_DT.pDetect;
%pinot
%dprime
%  [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime, 'NumCoeffs', 3,'Constraints', [0, 200; -5, 5],  'PlotFit', true);
%  %pdetect
% [~,coeffs_mech_pdetect, ~,~,~, warn__mech_pdetect] = FitSigmoid(x_mech, y_mech_pdetect, 'NumCoeffs', 3,'Constraints', [0, 200; -5, 5],  'PlotFit', true);
% wp
  % [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime,...
   % 'NumCoeffs', 4, 'CoeffInit', [1000,0.02,NaN,NaN], 'EnableBackup', false, 'PlotFit', true);
           [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_pdetect,'NumCoeffs', 4, 'CoeffInit', [100,.01,NaN,NaN],  'PlotFit', true);

%Elect table dt

[ElectDetect_DT] = AnalyzeElectTable(block_struct.ElectDetectTable);
x_elect = ElectDetect_DT.StimAmp;
% y_elect = ElectDetect_DT.dPrime;
y_elect_pdetect = ElectDetect_DT.pDetect;
% %pinot
% %dprime
%  [~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', 3,'CoeffInit', [.5,15,NaN,NaN],'PlotFit', true);
% %pdetect
% [~,coeffs_elect_pdetect,~, ~, ~, warn_elect_pdetect] = FitSigmoid(x_elect,y_elect_pdetect ,'NumCoeffs', 3,'CoeffInit', [.5,15,NaN,NaN],'PlotFit', true);

%wp
% [~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', ...
%            3,'CoeffInit', [1,30,NaN,NaN], 'EnableBackup', false, 'PlotFit', true);
       [~,coeffs_elect, ~,~,~, warn_elect] = FitSigmoid(x_elect, y_elect_pdetect,'NumCoeffs', 4,'CoeffInit', [.5,15,NaN,NaN], 'PlotFit', true);

%%

%new dprime coeffs for mech
sigfun = GetSigmoid(4);

xq = linspace(0, x_mech(end));
mc = sigfun(coeffs,xq);

mech_fa = MechDetect_DT{1,2};
mech_dprime_coeffs = norminv(mc) - norminv(mech_fa);


%new dprime coeffs for elect

tt = linspace(0,x_elect(end));
ec = sigfun(coeffs_elect,tt);
elect_fa = ElectDetect_DT{1,2};
elect_dprime_coeffs = norminv(ec)- norminv(elect_fa);


%% new plots 6 plots

SetFont('Arial',18)
% sgtitle(sprintf('%s %s', Monkey, electrode))
% title(sprintf('%s_%s', Monkey, electrode))
% title('Pinot')
subplot(2,3,1); hold on
title('Mech pDetect')
scatter(x_mech,y_mech_pdetect, 50, [.1 .1 .1], 'filled')
plot(x_mech, y_mech_pdetect,'Color', rgb(33, 33, 33), 'LineStyle', '-')

xq = linspace(0, x_mech(end));
yq = sigfun(coeffs,xq);
%sig plot
plot(xq,yq,'Color', rgb(183, 28, 28))



xlabel('Amplitude (mm)')
ylabel('pDetect')
ylim([0 1])

axis square

subplot(2,3,2); hold on

title('Elec pDetect')

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.pDetect, 'Color',rgb(33, 33, 33), 'LineStyle', '-')

tt = linspace(0,x_elect(end));
tq = sigfun(coeffs_elect,tt);
%sigmoid 
plot(tt,tq,'Color',rgb(183, 28, 28))

xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')))
ylabel('pDetect')
ylim([0 1])
xlim([0 30])

axis square

subplot(2,3,3); hold on
title('Sweep pDetect')

plot([0,2],[0,2], 'LineStyle','--','color', [.6,.6,.6])
scatter(predict(1),p_detect_big(2,2), 'filled', 'MarkerEdgeColor', rgb(229, 115, 115), 'MarkerFaceColor',rgb(229, 115, 115))
scatter(predict(2),p_detect_big(2,3), 'filled', 'MarkerEdgeColor', rgb(229, 57, 53), 'MarkerFaceColor',rgb(229, 57, 53))
scatter(predict(3),p_detect_big(2,4), 'filled', 'MarkerEdgeColor', rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
plot([0 p_detect_big(2,1) p_detect_big(2,1)], [p_detect_big(2,1) p_detect_big(2,1) 0], ...
    'LineStyle','--', 'Color', rgb(233, 30, 99))



ylim([0 1])
xlim([0 1])
xlabel('Predicted (pDetect)')
ylabel('Observed (pDetect)')




axis square

dprime_threshold = 1.35;
subplot(2,3,4); hold on
title('Mech d''')

scatter(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle', '-')
mq = linspace(0, x_mech(end));
[~, m] = min(abs(mech_dprime_coeffs-dprime_threshold));

plot([0 mq(m) mq(m)], [dprime_threshold, dprime_threshold, 0], 'Color',rgb(136, 14, 79),'LineStyle','--')
text(.02,1,(sprintf('%.3f', mq(m))), 'Color',rgb(136, 14, 79));

%incorrect 
dpm = sigfun(mech_dprime_coeffs,mq);
plot(mq,mech_dprime_coeffs,'Color',rgb(183, 28, 28))





xlabel('Amplitude (mm)')
ylabel('d''')
ylim([0 4.1])


axis square

subplot(2,3,5); hold on
title('Elec d''')

scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle', '-')
lp = 0.3;
mp = 0.45;

[~, up] = min(abs(elect_dprime_coeffs-dprime_threshold));
plot([0 tt(up) tt(up)], [dprime_threshold, dprime_threshold, -1], 'Color',rgb(183, 28, 28),'LineStyle', '--')
text(25,2,(sprintf('%.0fuA',tt(up))), 'Color', rgb(183, 28, 28));

[~, ll_p] = min(abs(elect_dprime_coeffs-lp));
plot([0 tt(ll_p) tt(ll_p)], [lp, lp, -1],'Color', rgb(229, 115, 115), 'LineStyle', '--')
text(25,1,(sprintf('%.0fuA',tt(ll_p))), 'Color', rgb(229, 115, 115));

[~, mm_p] = min(abs(elect_dprime_coeffs-mp));
plot([0 tt(mm_p) tt(mm_p)], [mp, mp,-1], 'Color', rgb(229, 57, 53),'LineStyle', '--')
 text(25,1.5,(sprintf('%.0fuA',tt(mm_p))), 'Color',rgb(229, 57, 53));


plot(tt,elect_dprime_coeffs,'Color',rgb(183, 28, 28))



xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')))
ylabel('d''')
ylim([0 4.1])
xlim([0 30])
axis square




subplot(2,3,6); hold on
title('Sweep d''')
scatter(dprime_predicted(2),dprime_big(2,2),'filled', 'MarkerEdgeColor', rgb(229, 115, 115), 'MarkerFaceColor',rgb(229, 115, 115))
scatter(dprime_predicted(3),dprime_big(2,3),'filled', 'MarkerEdgeColor',rgb(229, 57, 53), 'MarkerFaceColor',rgb(229, 57, 53))
scatter(dprime_predicted(4),dprime_big(2,4),'filled', 'MarkerEdgeColor',rgb(183, 28, 28), 'MarkerFaceColor',rgb(183, 28, 28))
plot([0 dprime_big(2,1) dprime_big(2,1)], [dprime_big(2,1) dprime_big(2,1) -1],'LineStyle','--', 'Color', rgb(136, 14, 79))
plot([0,5],[0,5], 'LineStyle','--','color', [.6,.6,.6])



% text(2, 2, 'Mech+Elec 19', 'Color',rgb(26, 35, 126), 'FontSize',15)
text(2.5, 2, (sprintf('Mech+%.0fuA', tt(up))), 'Color',rgb(183, 28, 28), 'FontSize',15)

% text(2, 1.75, 'Mech+Elec 18', 'Color',rgb(156, 39, 176), 'FontSize',15)
text(2.5, 1.75, (sprintf('Mech+%.0fuA', tt(mm_p))), 'Color',rgb(229, 57, 53), 'FontSize',15)

% text(2, 1.5, 'Mech+Elec 17', 'Color', rgb(103, 58, 183), 'FontSize',15)
text(2.5, 1.5, (sprintf('Mech+%.0fuA', tt(ll_p))), 'Color', rgb(229, 115, 115), 'FontSize',15)
text(2.5, 1.25, 'MechOnly', 'Color',  rgb(136, 14, 79), 'FontSize',15)


xlim([0 3.2])
ylim([0 4.1])
xlabel('Predicted (dPrime)')
ylabel('Observed (dPrime)')
axis square


