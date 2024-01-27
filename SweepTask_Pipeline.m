
tld = 'B:\ProjectFolders\DARPA\Data\ProcessedData\Pinot';
file_list = dir(tld);
%% loading matfiles
%need to load 
data = struct(); ii = 1;

subf = fullfile(tld, 'DarpaSweep');
mat_files = dir(fullfile(subf, '*.mat'));
sweep_table = cell(size(mat_files,1),1);

for i  = 1:size(mat_files,1)
    temp = load(fullfile(mat_files(i).folder, mat_files(i).name));
    sweep_table{i} = [temp.response_table];
    name_split = strsplit(mat_files(i).name, '_');
    data(ii).Animal = name_split{1};
    data(ii).Date = name_split{2};
    data(ii).ResponseTable = [temp.response_table];
   

    ii = ii+1;
end


CatTable = cat(1,sweep_table{:});


%% Analysis
% Dprime and Pdetect of w and wo icms
[detection_table, dprime_table] = AnalyzeSweepTable(CatTable);


%% Plotting pdetect and dprimes


elect_amp = detection_table.Properties.VariableNames;
mech_amp = str2double(detection_table.Properties.RowNames);


SetFont('Arial', 18)
figure; hold on; axis square

%better to do array? or easier to plot if array
%curly braces better
% detection_table{1,:}
%  tt = table2array(detection_table);
%  plot(tt(1,:))
% plot(detection_table.Row,detection_table.("19"),'Color', rgb(66, 66, 66), 'LineWidth', 4)

%%

% SetFont('Arial', 18)
% figure;
% % subplot(1,2,1); 
% hold on
% axis square
% for b = 1:size(detection_table)
%  varnames = detection_table.Properties.VariableNames;
%  % rownames = detection_table.Properties.RowNames;
%  rownames = [1:4];
%  var = [0 10 15 17];
% plot(var, detection_table{1,:},'o-','Color', rgb(66, 66, 66), 'LineWidth', 4)
% plot(var, detection_table{2,:},'o-','Color', rgb(198, 40, 40), 'LineWidth', 4)
% xlabel('ICMS')
% ylabel('pdetect')
% text(15,0.6, 'ICMS', 'Color', rgb(198, 40, 40), 'FontSize', 18)
% text(15,0.5, 'No ICMS', 'Color', rgb(66, 66, 66), 'FontSize', 18)
% % subplot(1,2,2); hold on
% % axis square
% % plot(var, dprime_table{1,:},'o-','Color', rgb(66, 66, 66), 'LineWidth', 4)
% % plot(var, dprime_table{2,:},'o-','Color', rgb(198, 40, 40), 'LineWidth', 4)
% 
% end
%% Analysis 
%ttest of observed


