% New MES_pipeline to edit and grab everything
sweep_task = 'B:\ProjectFolders\DARPA\Data\ProcessedData';
file_list = dir(sweep_task);

%% Loading mat files

data_struct = struct(); %ii = 1;
