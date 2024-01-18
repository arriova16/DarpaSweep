
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
%ttest of observed
for b = 1:length(data)
[detection_table{b}, dprime_table{b},~] = AnalyzeHybridTable(data(b).ResponseTable);


end

