%%New Mech Elect Detect Task
%going from raw data and saving as mat files
tld = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\RawData';
monkey_list = dir(tld);
monkey_list = monkey_list(3:end);

%% Formatting files in folder

for m = 1:length(monkey_list) %monkey names
    %getting list of electrodes(regardless of sweeptask present)
    electrode_list = dir(fullfile(tld,monkey_list(m).name, 'Electrode*'));
    for e = 1:size(electrode_list,1)
         %go through each folder
        sweep_tld = fullfile(tld, monkey_list(m).name, electrode_list(e).name, 'SweepTask');
        %not a good way to save electrodes
        split_sweep = strsplit(sweep_tld, '\');
%         electrode_sweep = split_sweep{7};
        electrode_sweep = split_sweep{11};
        
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
    
    end
end
     

%% Loading mat files and creating block_struct (gotta fix this later)


block_struct = struct(); ii=1;
for m = 1:length(monkey_list)
    electrode_list = dir(fullfile(tld,monkey_list(m).name, 'Electrode*'));
    for e = 1:size(electrode_list,1)
        sweep_tld = fullfile(tld, monkey_list(m).name, electrode_list(e).name, 'SweepTask');
        subf_mech = fullfile(sweep_tld, 'MechDetect');
        subf_elect = fullfile(sweep_tld, 'ElectDetect');
        subf_sweep = fullfile(sweep_tld, 'SweepDetect');
        elect_file_list = dir(fullfile(subf_elect, '*.mat'));
        mech_file_list = dir(fullfile(subf_mech, '*.mat'));
        sweep_file_list = dir(fullfile(subf_sweep, '*.mat'));
        elect_table = cell(size(elect_file_list,1),1);
        mech_table = cell(size(mech_file_list,1),1);
        sweep_table = cell(size(sweep_file_list,1),1);

        for b = 1:size(mech_file_list,1)
        
            % Get the date of the current mech file
            fname_split = strsplit(mech_file_list(b).name, '_');
            block_struct(ii).Monkey = fname_split{1};
            electrode_numbers = fname_split{4};
            and_idx = strfind(electrode_numbers, 'and');
            ee = [str2double(electrode_numbers(1:and_idx-1)), str2double(electrode_numbers(and_idx+3:end))];

            block_struct(ii).Electrode = ee;
            date_split = str2double(fname_split{2});
        
            %doesn't work with array of dates?
            date_try = datestr(datetime(date_split, 'ConvertFrom', 'yyyyMMdd', 'Format', 'yyyy-MM-dd'));
            block_struct(ii).Date = date_try;
            %incorrectly added for elecRT files
            temp_mech = load(fullfile(mech_file_list(b).folder, mech_file_list(b).name));
            mech_table{b} = [temp_mech.MechDetect_Table];
            block_struct(ii).MechRT = mech_table{b};
        
        
            for c = 1:size(elect_file_list,1)
                elect_fname_split = strsplit(elect_file_list(c).name, '_');
                elect_date_split = str2double(fname_split{2});
                date_try_elect = datestr(datetime(elect_date_split, 'ConvertFrom', 'yyyyMMdd', 'Format', 'yyyy-MM-dd'));
                block_struct(ii).elect_date = date_try_elect;
   

        %         % cell2table(repmat(date_try_elect, [size(temp_elect,1),1]), 'VariableNames', {'Date'});
                temp_elect = load(fullfile(elect_file_list(c).folder, elect_file_list(c).name));
                elect_table{c} = [temp_elect.ElectDetect_Table];
                block_struct(ii).ElectRT =elect_table{c};
        % 
      
           end %elect file loop
        
            ii = ii+1;
        end %mech file loop

    end %electrode_list
    
end %monkey_list

 %% data struct from block struct
data_struct = struct(); 
%getting unique electrodes from block_struct
electrode_stuffed = vertcat(block_struct(:).Electrode);
u_electrode = unique(electrode_stuffed,'rows');

% for m = 1:length(block_struct)
%     for i = 1:size(u_electrode,1)
%         data_struct(i).Electrode = u_electrode(i,:);
% 
%         if block_struct(m).Electrode == data_struct(i).Electrode
%             data_struct(i).Monkey = block_struct(m).Monkey;
%         end
% 
% 
%         %getting all of the daily rt for each task to go into one cell per
%         %electrode
% 
%         % if block_struct(m).Electrode == block_struct(m).Electrode
%         %     data_struct(i).MechRT = cat(1,block_struct(m).MechRT);
%         % end
% 
%     end
% end
% 





