%New script for summary data of sweep task
tld = 'B:\ProjectFolders\DARPA\Data\ProcessedData';
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
    electrodes = electrodes.name;
    %loading tables
    % for m = 1:size(mat_file)
    %    mat_split = strsplit(mat_file(m).name, '_');
    % 
    %    mat_idx = string(mat_split{3});
    %    data(ii).Monkey = mat_split{1};
    %    if mat_idx == "ME"
    %        data(ii).Task = 'MechandElect';
    %    else
    %        data(ii).Task = 'Sweep';
    %    end
    %    % data(ii).Task = mat_split{3};
    % 
    % 
    % 
    %  % me_temp=load(fullfile(mat_file(m).folder, mat_file(m).name));
    %  % data(ii).RT = me_temp;
    %  % 
    % end
    % ii = ii+1;
end



