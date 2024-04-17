%New script for summary data of sweep task
tld = 'B:\ProjectFolders\DARPA\Data\ProcessedData';
file_list = dir(tld);

%% loading files

monkeys = file_list(3:end);

for i = 1:length(monkeys)

    monkey_folders = fullfile(tld, monkey(i).name, 'DarpaSweep');
    
    
    
    

end



