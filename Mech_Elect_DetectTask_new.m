%%New Mech Elect Detect Task
%going from raw data and saving as mat files
tld = 'B:\ProjectFolders\DARPA\Data\RawData';
monkey_list = dir(tld); monkey_list = monkey_list(3:end);
for m = 1:length(monkey_list) %monkey names
    %getting list of electrodes(regardless of sweeptask present)
    electrode_list = dir(fullfile(tld,monkey_list(m).name, 'Electrode*'));
    for e = 1:size(electrode_list,1)
         %go through each folder
        sweep_tld = fullfile(tld, monkey_list(m).name, electrode_list(e).name, 'SweepTask');
        
         elect = fullfile(sweep_tld, 'ElectDetect');
         mech = fullfile(sweep_tld, 'MechDetect');
        
         elect_file = dir(fullfile(elect, '*rsp'));
         mech_file = dir(fullfile(mech, '*rsp'));
%  
  
        for ef = 1:size(elect_file,1)
        name_split = strsplit(elect_file(ef).name, '_');
        us_idx = find(elect_file(ef).name == '_', 1, 'last');
        dt_string = elect_file(ef).name(us_idx(1)+1:end-4);
        dt_split = strsplit(dt_string, 'T');
        fname = sprintf('%s_%s_ElectDetect.mat', monkey_list(m).name, dt_split{1});
         
            if exist(fullfile(elect,fname), 'file') ~= 1 || overwrite
                %loading and formatting data
                raw_data = readcell(fullfile(elect, elect_file(ef).name), ...
                    'FileType','text', 'NumHeaderLines', 1);
        
                ElectDetect_Table = ElectDetectFormatter(raw_data);
        
                save(fullfile(elect,fname), 'ElectDetect_Table')
            end
    
        end
        for mf = 1:size(mech_file,1)
        name_split = strsplit(mech_file(mf).name, '_');
        dt_name = name_split{4}(1:end-4);
        dt_split = strsplit(dt_name, 'T');
        fname = sprintf('%s_%s_MechDetect.mat',  monkey_list(m).name, dt_split{1});
            if exist(fullfile(mech, fname), 'file') ~= 1 || overwrite 
    
            %loading and formatting data
                raw_data = readcell(fullfile(mech, mech_file(mf).name), ...
                    "FileType","text", 'NumHeaderLines', 1);
    
                MechDetect_Table = MechDetectFormatter(raw_data);
    
                save(fullfile(mech,fname), 'MechDetect_Table')
            end
        end
    end
end

%% Loading mat files

data = struct();

    
