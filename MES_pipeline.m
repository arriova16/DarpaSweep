%Combination of Mech_Elect with SweepTask
sweep_df = 'B:\ProjectFolders\DARPA\Data\ProcessedData\Pinot';
file_list = dir(sweep_df);

 %% Loading mat files

 block_struct = struct(); ii =1;
%need to figure out how to avoid this and go straight to matfiles

subf = fullfile(sweep_df, 'DarpaSweep');
mat_file = dir(fullfile(subf, '*.mat'));

%loading tables 
 for i = 1:size(mat_file,1)
    ME_temp = load(fullfile(mat_file(1).folder, mat_file(1).name));
    sweep_temp = load(fullfile(mat_file(2).folder, mat_file(2).name));
    
    block_struct(ii).MechDetectTable = ME_temp.data.MechDetectTable;
    block_struct(ii).ElectDetectTable = ME_temp.data.ElectDetectTable;
    block_struct(ii).SweepDetectTable = sweep_temp.CatTable;
 
 end

 %% Sweep Analysis

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
    pmiss_big = max([p_detect(1), 1e-3]);
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


%% predicted vs observed pdetect
    stuff_block = struct();
u_icms = unique(block_struct.SweepDetectTable.StimAmp);
[u_mech, ~, ia] = unique(block_struct.SweepDetectTable.IndentorAmp);
[op_strings,pp_string] = deal(cell(1, length(u_icms)));

op_detect_try = zeros([length(u_mech),length(u_icms)]);
pp_detect = zeros([length(u_mech), length(u_icms)]);

for u = 1:length(u_icms)
    %initalize array, number going to 3 decimal pt?
    op_detect = ones([length(u_mech),1]) * 1e-3;
    pp_detect = NaN([length(u_mech),1]) * 1e-3;

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

% sweep_probabilty formula
% P(A)+P(B) - P(A)*(and)P(B)
% P(A) = probability of Mechanical- just mechanical
% P(B) = Probability of Electrical- just electrical 
%predicted is from the formula / observed is icms w/ mechnical
for t = 1:size(sweep_pdetect,2)
    mech = sweep_pdetect(2,2);
    ele = sweep_pdetect(1,3:5);
    for e = 1:size(ele,2)
     pE(e) = num2str(ele{1,e});
     pre(e) = (mech + pE{1,e}) -  (mech .* pE{1,e});
    

    end



end



%% sweep_probabilty formula
% P(A)+P(B) - P(A)*(and)P(B)
% P(A) = probability of Mechanical- is this just mechanical
% P(B) = Probability of Electrical- is this electrical with mechanical
% DONT HARD CODE!!!
 hold on
plot([0,1],[0,1], 'LineStyle','--','color', [.6,.6,.6])
for d = 1:size(DetectionRates,2)
    DT = table2array(DetectionRates);
   %
    p17 = (DT(2,2) + DT(1,3)) - (DT(2,2) .*  DT(1,3));
    p18 = (DT(2,2) + DT(1,4)) - (DT(2,2) .* DT(1,4));
    p19 = (DT(2,2) + DT(1,5)) - (DT(2,2) .*  DT(1,5));
    mech = (DT(2,2));

    datapts = [mech p17 p18 p19];

    %work on plots?
    ll_c = rgb(103, 58, 183);
    up_c = rgb(26, 35, 126);
    mm_c  = rgb(156, 39, 176);
    scatter(p17, DT(2,3), 'filled', 'MarkerEdgeColor', rgb(103, 58, 183), 'MarkerFaceColor',rgb(103, 58, 183))
    scatter(p18, DT(2,4), 'filled', 'MarkerEdgeColor', rgb(156, 39, 176), 'MarkerFaceColor',rgb(156, 39, 176))
    scatter(p19, DT(2,5), 'filled', 'MarkerEdgeColor',rgb(26, 35, 126), 'MarkerFaceColor',rgb(26, 35, 126))
    plot([0 mech mech], [mech mech 0],'LineStyle','--')
    

   % scatter(datapts, DT(2,2:5), 'filled', 'MarkerEdgeColor', rgb(156, 39, 176), 'MarkerFaceColor',rgb(156, 39, 176))
     xlim([0 1])
     ylim([0 1])
    xlabel('Pdetect(disjoint)')
    ylabel('pDetect', 'FontSize', 18)
    axis square
end

%%  


%mech table dt
[MechDetect_DT] = AnalyzeMechTable(block_struct.MechDetectTable);
x_mech = MechDetect_DT.MechAmp;
y_mech_dprime = MechDetect_DT.dPrime;
%pinot
 [~,coeffs, ~,~,~, warn] = FitSigmoid(x_mech, y_mech_dprime, 'NumCoeffs', 3,'Constraints', [0, 200; -5, 5],  'PlotFit', true);


%Elect table dt

[ElectDetect_DT] = AnalyzeElectTable(block_struct.ElectDetectTable);
x_elect = ElectDetect_DT.StimAmp;
y_elect = ElectDetect_DT.dPrime;
%pinot
[~,coeffs_elect,~, ~, ~, warn_elect] = FitSigmoid(x_elect,y_elect ,'NumCoeffs', 3,'CoeffInit', [.5,15,NaN,NaN],'PlotFit', true);


%% pdetect plots

%c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
% sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4);
sigfun = GetSigmoid(3);
dprime_threshold = 1.35;
 SetFont('Arial', 18)

 subplot(1,3,1); hold on  
 title('Mech dPrime')

scatter(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(MechDetect_DT.MechAmp, MechDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle', '-')

 xq = linspace(0, x_mech(end));
 yq = sigfun(coeffs,xq);
 [~, b] = min(abs(yq-dprime_threshold));
 plot(xq,yq,'Color', [.1 .1 .1])
 plot([0 xq(b) xq(b)], [dprime_threshold, dprime_threshold, 0], 'Color',rgb(233, 30, 99),'LineStyle','--')
  text(.07,1,(sprintf('%.3f',xq(b))), 'Color', rgb(233, 30, 99), 'FontSize',18);
 xlabel('Amplitude (mm)','FontSize', 18)
 ylabel('d''','FontSize',18)
 ylim([0 6])

 axis square


 subplot(1,3,2); hold on
 title('Elect dPrime')
 scatter(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 50, [.1 .1 .1], 'filled')
plot(ElectDetect_DT.StimAmp, ElectDetect_DT.dPrime, 'Color', [.1 .1 .1], 'LineStyle', '-')

axis square

 ll = 0.45;
 mm = 0.9;

 tt = linspace(0,x_elect(end));
 tq = sigfun(coeffs_elect,tt);

 [~, np] = min(abs(tq-dprime_threshold));
 plot([0 tt(np) tt(np)], [dprime_threshold, dprime_threshold, 0], 'Color',rgb(26, 35, 126),'LineStyle', '--')
 up = (tt(np));
 text(30,3,(sprintf('%.0f',up)), 'Color', rgb(26, 35, 126), 'FontSize',18);

  [~, ll_np] = min(abs(tq-ll));
  lp = (tt(ll_np));
  plot([0 tt(ll_np) tt(ll_np)], [ll, ll, 0],'Color', rgb(103, 58, 183), 'LineStyle', '--')
  text(30,2.4,(sprintf('%.0f',tt(ll_np))), 'Color', rgb(103, 58, 183), 'FontSize',18);
  
  [~, mm_np] = min(abs(tq-mm));
  plot([0 tt(mm_np) tt(mm_np)], [mm, mm, 0], 'Color', rgb(156, 39, 176),'LineStyle', '--')
 text(30,2.7,(sprintf('%.0f',tt(mm_np))), 'Color', rgb(156, 39, 176), 'FontSize',18);
  
  
  plot(tt,tq,'Color',rgb(69, 90, 100))
 xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
 ylabel('d''','FontSize',18)
 ylim([0 6])

 subplot(1,3,3);  hold on
 title('Sweep Detect')
 plot([0,1],[0,1], 'LineStyle','--','color', [.6,.6,.6])
 %fix this
 scatter(p17, DT(2,3), 'filled', 'MarkerEdgeColor', rgb(103, 58, 183), 'MarkerFaceColor',rgb(103, 58, 183))
 scatter(p18, DT(2,4), 'filled', 'MarkerEdgeColor', rgb(156, 39, 176), 'MarkerFaceColor',rgb(156, 39, 176))
 scatter(p19, DT(2,5), 'filled', 'MarkerEdgeColor',rgb(26, 35, 126), 'MarkerFaceColor',rgb(26, 35, 126))
 scatter(mech, mech, 'filled', 'MarkerEdgeColor',rgb(233, 30, 99), 'MarkerFaceColor',rgb(233, 30, 99))
  plot([0 mech mech], [mech mech 0],'LineStyle','--', 'Color', rgb(233, 30, 99))

  text(0.7, .4, 'Mech+Elec19', 'Color',rgb(26, 35, 126), 'FontSize',15)
  text(0.7, .35, 'Mech+Elec18', 'Color',rgb(156, 39, 176), 'FontSize',15)
  text(0.7, .3, 'Mech+Elec16', 'Color', rgb(103, 58, 183), 'FontSize',15)
  text(0.7, .25, 'MechOnly', 'Color',  rgb(233, 30, 99), 'FontSize',15)

     xlim([0 1])
 
    xlabel('Pdetect(disjoint)')
    ylabel('pDetect', 'FontSize', 18)
    axis square
