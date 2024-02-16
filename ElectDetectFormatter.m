function output_table = ElectDetectFormatter(input_cell_array)

[num_trials, num_cols] = size(input_cell_array);

if num_cols == 10 
    input_cell_array = input_cell_array(:, [1:3,5:6, 8, 10]);
elseif num_cols ==11
    input_cell_array = input_cell_array(:, [1:3,5:6, 8, 10]);
end


%Remove aborted trials

input_cell_array = input_cell_array(~strcmpi(input_cell_array(:,7), 'empty response') | ...
                                    strcmpi(input_cell_array(:,7), 'no'), :);

%converting

output_table = cell2table(input_cell_array, 'VariableNames', {'Trial', 'CorrectAnswer', 'CorrectAnserText', ...
                                                               'TestStimAmp', 'TestStimFreq', 'Electrode', 'Response'});

end