function [detection_table] = AnalyzeElectTable(input_table)
 x = input_table.TestStimAmp;
[u_stimamps, ~, ia] = unique(x);
p_detect = zeros([length(u_stimamps),1]);
for j = 1:length(u_stimamps)
    correct_idx = strcmp(input_table.Response(ia == j), 'correct');
    p_detect(j) = sum(correct_idx)/length(correct_idx);
end
if any(u_stimamps == 0)
    catch_idx = find(u_stimamps == 0);
    p_detect(catch_idx) = 1 - p_detect(catch_idx);
end
dprime = zeros([length(u_stimamps), 1]);
pmiss = p_detect(1);

% line that was missing
if pmiss == 0
    pmiss = 0.001;
end
for j = 1:length(dprime)-1
    phit = p_detect(j+1);
    if phit == 1
        phit = .999;
    end
    dprime(j+1) = norminv(phit)- norminv(pmiss);
end

detection_table = table(u_stimamps, p_detect, dprime, 'VariableNames', {'StimAmp', 'pDetect', 'dPrime'});



end
 