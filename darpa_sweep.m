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

    %getting monkey name and sess date for file name

    name_split = strsplit(elect_file(e).name, '_');
    us_idx = find(elect_file(e).name == '_', 1, 'last');
    dt_string = elect_file(e).name(us_idx(1)+1:end-4);
    dt_split = strsplit(dt_string, 'T');
    exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
    monkey_name = name_split{2}(1:end -7);
    fname = sprintf('%s_%s_ElectDetect.mat', monkey_name, exp_date);
    
    if exist(fullfile(elect,fname), 'file') ~= 1 || overwrite
        %loading and formatting data
        raw_data = readcell(fullfile(elect, elect_file(e).name), ...
            'FileType','text', 'NumHeaderLines', 1);
     
        ElectDetect_Table = ElectDetectFormatter(raw_data);

        save(fullfile(elect,fname), 'ElectDetect_Table')
    end

end

%formatting MechDetect folder

for m = 1:size(mech_file,1)
    %getting monkey name and sess date for file name
    name_split = strsplit(mech_file(m).name, '_');
    monkey_name  = name_split{2}(1:end-7);
    dt_name = name_split{4}(1:end-4);
    dt_split = strsplit(dt_name, 'T');
    exp_date = datestr(datenum(dt_split{1}, 'yyyymmdd'));
    fname = sprintf('%s_%s_MechDetect.mat', monkey_name, exp_date);
    
    if exist(fullfile(mech, fname), 'file') ~= 1 || overwrite 

    %loading and formatting data
        raw_data = readcell(fullfile(mech, mech_file(m).name), ...
            "FileType","text", 'NumHeaderLines', 1);
        
        MechDetect_Table = MechDetectFormatter(raw_data);

        save(fullfile(mech,fname), 'MechDetect_Table')
    end

end
%% putting things into block - will need to concat response tables?
block_struct.Date = exp_date;
block_struct.MechTable  = MechDetect_Table;
block_struct.ElectTable = ElectDetect_Table;


for i = 1:length(block_struct)
    %create function for analyzing pdetect and dprime
    %then take dprime and pdetect and use charles function for coeffs

        [results] = AnalyzeMechTable(block_struct.MechTable);

        [otherresults] = Alany
    

end


