%Darpa Sweep Mechanical 
%goals I want to be able pull files and be able to formatt them here
%I also want to be able to save those formatted files and analyze them

data_folder = 'B:\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_22and24\SweepTask\Training';
file_list = dir(data_folder);

%% Loading folders
%load folders then load files from there 
%save formatted mat files

tasktype = {'Mech', 'Elect'};
block_struct = struct(); ii = 1;

%loading electdetect folder
elect = fullfile(data_folder, 'ElectDetect');
elect_file = dir(fullfile(elect, '*rsp'));
    
%loading mechdetect folder
mech = fullfile(data_folder, 'MechDetect');
mech_file = dir(fullfile(mech, '*rsp'));


%formatting electdetect files name
for e = 1:size(elect_file,1)
    name_split = strsplit(elect_file(e).name, '_');
    us_idx = find(elect_file(e).name == '_', 1, 'last');
    dt_string = elect_file(e).name(us_idx(1)+1:end-4);
    dt_split = strsplit(dt_string, 'T');
    exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
    monkey_name = name_split{2}(1:end -7);
    fname = sprintf('%s_%s_ElectDetect.mat', monkey_name, exp_date);
    
    if exist(fullfile(elect,fname), 'file') ~= 2 || overwrite
        raw_data = readcell(fullfile(elect, elect_file(e).name), ...
            'FileType','text', 'NumHeaderLines', 1);




    end




end