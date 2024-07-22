% MES formatter
%changes the rsp to mat files

tld = 'Z:\UserFolders\ToriArriola\DARPA_updated\RawData';
monkey_list = dir(tld);
monkey_list = monkey_list(3:end);

%% Formatting files in folder

for m = 1:length(monkey_list) %monkey names
    %getting list of electrodes(regardless of sweeptask present)
    electrode_list = dir(fullfile(tld,monkey_list(m).name, 'Electrode*'));
    for e = 1:size(electrode_list,1)
         %go through each folder
        sweep_tld = fullfile(tld, monkey_list(m).name, electrode_list(e).name, 'SweepTask');
        electrode_sweep = electrode_list(e).name;
        elect = fullfile(sweep_tld, 'ElectDetect');
        mech = fullfile(sweep_tld, 'MechDetect');
        sweep = fullfile(sweep_tld,'SweepDetect');

         elect_file = dir(fullfile(elect, '*rsp'));
         mech_file = dir(fullfile(mech, '*rsp'));
         sweep_file = dir(fullfile(sweep,'*rsp'));

        for ef = 1:size(elect_file,1)
            name_split = strsplit(elect_file(ef).name, '_');
            us_idx = find(elect_file(ef).name == '_', 1, 'last');
            dt_string = elect_file(ef).name(us_idx(1)+1:end-4);
            dt_split = strsplit(dt_string, 'T');      
            fname = sprintf('%s_%s_%s_ElectDetect.mat', monkey_list(m).name, dt_split{1},electrode_sweep);  
                if exist(fullfile(elect,fname), 'file') ~= 1 || overwrite
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
            fname = sprintf('%s_%s_%s_MechDetect.mat',  monkey_list(m).name, dt_split{1},electrode_sweep);
                if exist(fullfile(mech, fname), 'file') ~= 1 || overwrite 
                    raw_data = readcell(fullfile(mech, mech_file(mf).name), ...
                        "FileType","text", 'NumHeaderLines', 1); 
                    MechDetect_Table = MechDetectFormatter(raw_data);
                    save(fullfile(mech,fname), 'MechDetect_Table')
                end
        end

        for sf = 1:size(sweep_file,1)
            name_split = strsplit(sweep_file(sf).name, '_');
            dt_name = name_split{4}(1:end-4);
            dt_split = strsplit(dt_name, 'T');
            fname = sprintf('%s_%s_%s_SweepDetect.mat', monkey_list(m).name, dt_split{1}, electrode_sweep);
            if exist(fullfile(sweep, fname), 'file') ~= 1 || overwrite
                raw_data = readcell(fullfile(sweep, sweep_file(sf).name), ...
                    "FileType","text", "NumHeaderLines",1);
                    SweepDetect_Table = SweepDetectFormatter(raw_data);
                    save(fullfile(sweep,fname), 'SweepDetect_Table')
            end
       end
    
    end %electrode_llist
end %monkey_list

