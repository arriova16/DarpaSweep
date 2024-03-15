%SweepDetectFormatter
function output_table = SweepDetectFormatter(input_cell_array)
  [num_trials,num_cols] = size(input_cell_array);

  %removing table
  if num_cols == 37
      input_cell_array = input_cell_array(:,[25:27, 29,30,32,33,34,37]);
  elseif num_cols == 38
      input_cell_array = input_cell_array(:,[25:27, 29, 30,32, 33, 34, 37]);
  end

  %Remove aborted trials
  input_cell_array = input_cell_array(~strcmpi(input_cell_array(:,9), 'empty response') | ...
                                    strcmpi(input_cell_array(:,9), 'no'),:);


  output_table = cell2table(input_cell_array, 'VariableNames',{'Trial', 'CorrectInterval', 'CorrectAnswer', ...
                                                        'StimAmp', 'StimFreq', 'Electrode', 'IndentorFreq', ...
                                                        'IndentorAmp', 'Response'});

end