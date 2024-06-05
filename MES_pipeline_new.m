% % New MES_pipeline to edit and grab everything

%Combination of Mech_Elect with SweepTask
sweep_df = 'Z:\UserFolders\ToriArriola\DARPA_updated\RawData';
file_list = dir(sweep_df);


%% loading mat files
data_struct = struct();





%% Loading mat files
% 
%  block_struct = struct(); ii =1;
% %need to figure out how to avoid this and go straight to matfiles
% 
% mat_file = dir(fullfile(sweep_df, '*.mat'));
% name_split = strsplit(sweep_df, '\');
% Monkey = name_split{6};
% electrode = (name_split{8}(11:end));
% 
% %loading tables 
%  for i = 1:size(mat_file,1)
%     ME_temp = load(fullfile(mat_file(1).folder, mat_file(1).name));
%     sweep_temp = load(fullfile(mat_file(2).folder, mat_file(2).name));
% 
%     block_struct(ii).MechDetectTable = ME_temp.data.MechDetectTable;
%     block_struct(ii).ElectDetectTable = ME_temp.data.ElectDetectTable;
%     block_struct(ii).SweepDetectTable = sweep_temp.CatTable;
% 
%  end

 %% pdetect and dprime from sweep task

 % [dt] = AnalyzeSweepTable(block_struct.SweepDetectTable);





 %% p detect observed vs predicted






 %% dprime observed vs predicted
