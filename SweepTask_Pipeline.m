
tld = 'B:\ProjectFolders\DARPA\Data\ProcessedData\Pinot';
file_list = dir(tld);
%% loading matfiles
data = struct(); ii = 1;

subf = fullfile(tld, 'DarpaSweep');
mat_files = dir(fullfile(subf, '*.mat'));
sweep_table = cell(size(mat_files,1),1);

for i  = 1:size(mat_files,1)
    temp = load(fullfile(mat_files(i).folder, mat_files(i).name));
    sweep_table{i} = [temp.response_table];
    name_split = strsplit(mat_files(i).name, '_');
    data(ii).Animal = name_split{1};
    data(ii).Data = name_split{2};
    data(ii).ResponseTable = [temp.response_table];
   

    ii = ii+1;
end


CatTable = cat(1,sweep_table{:});

%% Analysis
%% Analysis
%create pdetect and dprime for each day

for i = 1:length(data)
    u_mech_amps = unique(data(i).ResponseTable.IndentorAmp);
    [u_icms_amps, ~, ia] = unique(data(i).ResponseTable.StimAmp);
    [pd_strings, dp_strings] = deal(cell(1,length(u_mech_amps)));
    p_detect = zeros([length(u_icms_amps), length(u_mech_amps)]);
    dprime = NaN([length(u_icms_amps), length(u_mech_amps)]);

    for u = 1:length(u_mech_amps)
        p_detect = ones([length(u_icms_amps), 1]) *1e-3;
        dprime = NaN([length(u_icms_amps),1]);
        for j = 1:length(u_icms_amps)
            trial_idx = ia ==j & [data(i).ResponseTable.IndentorAmp]== u_mech_amps(u);
            correct_idx = strcmp(data(i).ResponseTable.Response(trial_idx), 'correct');
            
            if u_icms_amps(j) ==0
                p_detect(j) = 1 - (sum(correct_idx)/sum(trial_idx));
            else
                p_detect(j) = sum(correct_idx)/sum(trial_idx);

            end
        end
        p_detect(:,u) = p_detect;
        pmiss = max([p_detect(1), 1e-3]);

        for j = 1:length(dprime)-1
            phit = p_detect(j+1);
            if phit == 1
                phit = .99;
            elseif phit == 0 
                phit = 1e-3;

            end

            dprime(j+1) = norminv(phit)-norminv(pmiss);

        end
        
        dprime(:,u) = dprime;
              
        pd_strings{u} = sprintf('pDetect_%d', u_mech_amps(u));
        dp_strings{u} = sprintf('dPrime_%d', u_mech_amps(u));
        
    end
   data(i).DetectionRates = array2table([u_icms_amps, p_detect, dprime], 'VariableNames',['ICMSAmps', pd_strings, dp_strings]);

end

%% Plotting
SetFont('Arial', 12)
c = [rgb(66, 66, 66); rgb(198, 40, 40)];
for i = 1:length(data)
    figure;
     subplot(1,2,1); hold on

      plot(data(i).DetectionRates{:,1}, data(i).DetectionRates{:,2}, 'Color', c(g,:), 'LineWidth', 3)

      ax = gca;
      ax.FontSize = 20;
    xlabel(sprintf('Stimulus Amplitude (%sm)', GetUnicodeChar('mu')), 'FontSize', 18)
    ylabel('p(Detected)', 'FontSize', 18)
             
     text(1,.4, 'Without ICMS', 'Color', rgb(66, 66, 66),'FontSize',18);
%     text(1,.38, 'With ICMS', 'Color', rgb(198, 40, 40), 'FontSize',18);
box off

    subplot(1,2,2); hold on
    for g = 1:num_groups
        plot(data(i).DetectionRates{:,1}, data(i).DetectionRates{:,g+num_groups+1}, 'Color', c(g,:),'LineWidth', 3)
    end
      ax = gca;
      ax.FontSize = 20;
    xlabel(sprintf('Stimulus Amplitude (%sm)', GetUnicodeChar('mu')), 'FontSize', 18)
    ylabel('d''', 'FontSize', 18)
 end




