%Darpa Sweep Mechanical 
%goals I want to be able pull files and be able to formatt them here
%I also want to be able to save those formatted files and analyze them

data_folder = 'B:\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_22and24\SweepTask\Training';
file_list = dir(data_folder);

%% Loading folders
%load folders then load files from there

task_type = {'Mech', 'Elect'};
block_struct = struct(); ii = 1;
