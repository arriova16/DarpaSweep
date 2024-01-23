function output_table = MechDetectFormatter(input_cell_array)

[num_trials, num_cols] = size(input_cell_array);


if num_cols == 15

    input_cell_array = input_cell_array(:, [8:10, 12:13, 15]);
elseif num_cols == 16
    input_cell_array = input_cell_array(:, [8:10, 12:13, 15]);

end

%Remove aborted trials

input_cell_array = input_cell_array(~strcmpi(input_cell_array(:, 6), 'empty response') | ...
                                    strcmpi(input_cell_array(:,6), 'no'), :);


%converting

output_table = cell2table(input_cell_array, 'VariableNames', {'Trial', 'CorrectAnswer', 'CorrectAnswerText' ...
                                                              'MechFreq', 'MechAmp', 'Response'});
end