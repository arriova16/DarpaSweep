%Darpa Sweep Mechanical 
%goals I want to be able pull files and be able to formatt them here
%I also want to be able to save those formatted files and analyze them

data_folder = 'C:\Users\Somlab\Box\BensmaiaLab\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_22and24\SweepTask\12_14';
file_list = dir(data_folder);

%% Load rsp file
% this can be a function

ii = 1;
block_struct = struct();
for i = 1:length(file_list)
    % Check if file is .rsp
    if ~contains(file_list(i).name, '.rsp') || ~contains(file_list(i).name, 'physical')
        continue
    end
    
    % Parse filename
    fname_split = strsplit(file_list(i).name, '_');
    %data_struct(ii).StudyID = fname_split{1};
    block_struct(ii).Animal = fname_split{2}(1:end-7);
    block_struct(ii).Protocol = fname_split{3};
    t_idx = find(fname_split{4} == 'T');
    block_struct(ii).Date = datestr(datenum(fname_split{4}(1:t_idx-1), 'yyyymmdd'), 1);
    %data_struct(ii).Time = datestr(datenum(fname_split{4}(t_idx+1:end-4), 'hhmmss'), 13);

     % Load the data
    temp_data = readcell(fullfile(data_folder, file_list(i).name), 'FileType', 'text', 'NumHeaderLines', 1);
     if size(temp_data,2) == 15
          % Remove 2nd column
         temp_data = temp_data(:,[8:10, 12:13, 15]);
    end
   
    % Remove aborted trials
     abort_idx = strcmpi(temp_data(:,6), 'empty response') | strcmpi(temp_data(:,6), 'empty');
      temp_data = temp_data(~abort_idx,:); 
% %     % Convert to table
    response_table = cell2table(temp_data(1:end,:), 'VariableNames',{'Trial','CorrectAnswer', 'CorrectAnswerText', 'IndentFreq','IndentAmp','Response'});
    block_struct(ii).ResponseTable = response_table;



    ii = ii + 1;
end
%%
for i = 1:length(block_struct)
    [u_test_amps, ~, ia] = unique(block_struct(i).ResponseTable.IndentAmp);
    p_detect_comb = zeros([length(u_test_amps),1]);
    for j = 1:length(u_test_amps)
        correct_idx = strcmp(block_struct(i).ResponseTable.Response(ia == j), 'correct');
        p_detect_comb(j) = sum(correct_idx) / length(correct_idx);
        
    end
    % Correct for catch trials
    if any(u_test_amps == 0)
        catch_idx = find(u_test_amps == 0);
        p_detect_comb(catch_idx) = 1 - p_detect_comb(catch_idx);
    end
    
    % Compute d' from p(detect) where  d' = norminv(p(hit)) - norminv(p(false alarm))
    dprime = NaN([length(u_test_amps),1]);
    pmiss = p_detect_comb(1);
    if pmiss == 0 % Correct for 0 false alarm
        pmiss = 0.001;
    end
    for j = 1:length(dprime)-1
        phit = p_detect_comb(j+1);
        if phit == 1 % Correct for infinite hit rate
            phit = .999;
        end
        dprime(j+1) = norminv(phit) - norminv(pmiss);        
    end
    
    % Make a table & add to struct
    block_struct(i).DetectionRates = array2table([u_test_amps, p_detect_comb, dprime], 'VariableNames', {'Amplitude', 'pDetect', 'dPrime'});
end
%% Plotting 

dprime_threshold = 1.35; 
sigfun = @(c,x) 1./(1 + exp(-c(1).*(x-c(2))));
for i = 1:length(block_struct)

 %    % not working but will make multiple plots
 %figure('Name', sprintf('%s - %s', block_struct(i).Animal, block_struct(i).Date));

c = ColorGradient(rgb(239, 154, 154), rgb(198, 40, 40), length(block_struct));
% c = [rgb(66, 66, 66); rgb(198, 40, 40)];
     subplot(1,2,1); hold on


   plot(block_struct(i).DetectionRates{:,1}, block_struct(i).DetectionRates{:,2},'o-', 'MarkerFaceColor', 'red','Color', c(i,:),  'LineWidth', 3)
   %plot(bigtable_DetectionRates{:,1}, bigtable_DetectionRates{:,3}, 'Color',rgb(198, 40, 40), 'LineWidth', 3)

    ax = gca;
    ax.FontSize = 18;
    xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18 )
    ylabel('p(Detected)','FontSize',18)
             
%      text(1,.4, 'Without ICMS', 'Color', rgb(66, 66, 66),'FontSize',18);
%     text(1,.38, 'With ICMS', 'Color', rgb(198, 40, 40), 'FontSize',18);
    
   subplot(1,2,2); hold on

      plot(block_struct(i).DetectionRates{:,1}, block_struct(i).DetectionRates{:,3},'o-', 'MarkerFaceColor', 'red','Color', c(i,:), 'LineWidth', 3)
      ax = gca;
      ax.FontSize = 18;
     % yline(1.35,'-', 'Threshold 24.8 \muA ', 'FontSize',18,'LabelHorizontalAlignment','left', 'LineWidth',2);
%     title("Electrode 12")
    xlabel(sprintf('Amplitude (%sA)', GetUnicodeChar('mu')),'FontSize', 18)
    ylabel('d''','FontSize',18) 
    box off
%16.53 \muA23.39 \muA
end

%% Darpa sweep pipeline

tld = 'B:\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_22and24\SweepTask\12_12';
file_list = dir(tld);

type_task = {'mech', 'elect'};



%% loading rsp files



day_struct = struct(); ii = 1;
for m =4:size(file_list)
    %selected only rsp files
    rsp_file = dir(fullfile(tld, '*.rsp'));
    temp_data = readcell(fullfile(tld, file_list(m).name), 'FileType', 'text', 'NumHeaderLines', 1);
    mechdata = FormatMechTaskData(temp_data);
   
    ii = ii+1;
end