
tld = 'Z:\UserFolders\ToriArriola\DARPA_updated\RawData\Pinot\Electrode_3and23\SweepTask';
process_loc = 'Z:\UserFolders\ToriArriola\DARPA_updated\ProcessedData\Pinot\DarpaSweep\Electrode_3and23';
file_list = dir(tld);
%% loading matfiles
%need to load 
data = struct(); ii = 1;

subf = fullfile(tld, 'SweepDetect');
mat_files = dir(fullfile(subf, '*.mat'));
sweep_table = cell(size(mat_files,1),1);

for i  = 1:size(mat_files,1)
    name_split = strsplit(mat_files(i).name, '_');
    animal = name_split{1};
    electrode = name_split{4};
    data(ii).Animal = name_split{1};
    data(ii).Date = name_split{2};

    temp = load(fullfile(mat_files(i).folder, mat_files(i).name));
    sweep_table{i} = [temp.SweepDetect_Table];

    data(ii).ResponseTable = sweep_table{i};

    ii = ii+1;
end

CatTable = cat(1,sweep_table{:});

save_fname = sprintf('%s_%s_Sweep_comb.mat', animal, electrode);
if exist(fullfile(process_loc, save_fname), 'file') ~=1 || overwrite
    save(fullfile(process_loc, save_fname), 'CatTable')
end

%% Analysis

u_icms_big = unique(CatTable.StimAmp);
[u_test_amps_big, ~, ia] = unique(CatTable.IndentorAmp);
[pd_strings_big, dp_strings_big] = deal(cell(1, length(u_icms_big)));
p_detect_big = zeros([length(u_test_amps_big),length(u_icms_big)]);
dprime_big = NaN([length(u_test_amps_big),length(u_icms_big)]);
for u = 1:length(u_icms_big)
    % Initalize arrays
    p_detect = ones([length(u_test_amps_big),1]) * 1e-3;
    dprime = NaN([length(u_test_amps_big),1]);
    for j = 1:length(u_test_amps_big)
        trial_idx_big = ia == j & [CatTable.StimAmp] == u_icms_big(u);
        correct_idx_big = strcmp(CatTable.Response(trial_idx_big), 'correct');
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


%fix this function in rewrite


%% probability formula
% P(A)+P(B) - P(A)*(and)P(B)
% P(A) = probability of Mechanical- is this just mechanical
% P(B) = Probability of Electrical- is this electrical with mechanical
% DONT HARD CODE!!!
clf; hold on
plot([0,1],[0,1], 'LineStyle','--','color', [.6,.6,.6])
for d = 1:size(DetectionRates,2)
    DT = table2array(DetectionRates);
   %
    p17 = (DT(2,2) + DT(1,3)) - (DT(2,2) .*  DT(1,3));
    p18 = (DT(2,2) + DT(1,4)) - (DT(2,2) .* DT(1,4));
    p19 = (DT(2,2) + DT(1,5)) - (DT(2,2) .*  DT(1,5));

    datapts = [p17 p18 p19];
    %work on plots?
     scatter(datapts, DT(2,3:5), 'filled', 'MarkerEdgeColor', rgb(156, 39, 176), 'MarkerFaceColor',rgb(156, 39, 176))
     xlim([0 1])
     ylim([0 1])
    xlabel('Pdetect(disjoint)')
    ylabel('pDetect', 'FontSize', 18)
    axis square
end










