%loading matfiles
tld = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\ProcessedData\Pinot';
file_list = dir(tld);
%%

subf = fullfile(tld, 'DarpaSweep');
mat_files = dir(fullfile(subf, '*.mat'));

for i  = 1:size(mat_files,1)
    name_split = strsplit(mat_files(i).name, '_');
    
    


end