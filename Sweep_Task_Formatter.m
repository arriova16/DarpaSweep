%Working on Formatting the Sweep Detection Task
tld = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\RawData\Pinot\Electrode_22and24\SweepTask\Training\SweepDetect';
process_loc = 'C:\Users\arrio\Box\BensmaiaLab\ProjectFolders\DARPA\Data\ProcessedData\Pinot\DarpaSweep';
file_list = dir(tld);

%% Loading rsp files and formatting

block_struct = struct();ii=1;

for i = 1:length(file_list)
 % Check if file is .rsp
    if ~contains(file_list(i).name, '.rsp') || ~contains(file_list(i).name, 'darpa')
        continue
    end
    
    fname_split = strsplit(file_list(i).name, '_');
    block_struct(ii).Animal = fname_split{2}(1:end-7);
    monkey_name = fname_split{2}(1:end-7);
    t_idx = find(fname_split{4} == 'T');
    dt_name = datestr(datenum(fname_split{4}(1:t_idx-1), 'yyyymmdd'), 1);
    block_struct(ii).Date = datestr(datenum(fname_split{4}(1:t_idx-1), 'yyyymmdd'), 1);

    % load the data
    temp = readcell(fullfile(tld, file_list(i).name), "FileType",'text', 'NumHeaderLines',1);
     
    if size(temp,2) == 37
        temp = temp(:, [25:27, 29, 30, 32, 33, 34, 37]);

    end
    
    abort_idx = strcmpi(temp(:,9), 'empty response') | strcmpi(temp(:,9), 'no');
    temp = temp(~abort_idx,:);
    
    response_table = cell2table(temp, 'VariableNames',{'Trial', 'CorrectInterval', 'CorrectAnswer', ...
                                                        'StimAmp', 'StimFreq', 'Electrode', 'IndentorFreq', ...
                                                        'IndentorAmp', 'Response'});

    block_struct(ii).ResponseTable = response_table;

    ii = ii+1;
    
    %saving in matfiles
    
     fname = sprintf('%s_%s_DarpaSweep.mat', monkey_name, dt_name);
     
     if exist(fullfile(process_loc, fname), 'file') ~=1 || overwrite
     
         save(fullfile(process_loc, fname), 'response_table')
     end
end



