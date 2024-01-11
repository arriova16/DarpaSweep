
tld = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\ProcessedData\Pinot';
file_list = dir(tld);
%% loading matfiles
data = struct('Monkey', [], 'Date', [], 'ResponseTable', [] );

subf = fullfile(tld, 'DarpaSweep');
mat_files = dir(fullfile(subf, '*.mat'));
sweep_table = cell(size(mat_files,1),1);

for i  = 1:size(mat_files,1)
    temp = load(fullfile(mat_files(i).folder, mat_files(i).name));
    sweep_table{i} = [temp.response_table];
    name_split = strsplit(mat_files(i).name, '_');
    for m = 1:length(data)
        data(m).Date = name_split{2};

    end
end


CatTable = cat(1,sweep_table{:});

%% Analysis

