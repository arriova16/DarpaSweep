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
    electrode = electrode.name;
    %loading tables
    for m = 1:size(mat_file)
       mat_split = strsplit(mat_file(m).name, '_');
       mat_idx = mat_split{3};
       data(ii).Monkey = mat_split{1};

       if contains(mat_split{2}, 'and')
           and_idx = strfind(mat_split{2}, 'and');
           ee = [str2double(mat_split{2}(1:and_idx-1)), str2double(mat_split{2}(and_idx+3:end))];
       end

       data(ii).Electrode = ee;
       data(ii).Task = mat_split{3};
       if data(m).Task == "ME.mat"
            data(ii).Task = data(m).Task(1:2);
       end
       data(ii).Task= convertCharsToStrings(data(m).Task);
        

       %need to fix
   
       stuff_try = load(fullfile(mat_file(m).folder, mat_file(m).name));
       data(ii).RT = stuff_try;
      
       if data(m).Task == "ME"
           data(ii).RT = data(ii).RT.data;
       end
       ii = ii+1;


    end
 
end

%% Sweep Analysis
%observed detection rates

tasks = vertcat(data(:).Task);
me_idx = strcmpi(tasks, 'ME');
sweep_idx = strcmpi(tasks, 'Sweep');


for i = 1:length(data)
    % icms = unique(data(sweep_idx).)
    sweep_struct = data(i).RT(sweep_idx);
    % sweep_RT = sweep_struct.CatTable;

end


