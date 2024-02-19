%Getting PDetect and DPrime of MechTable
function[detection_table] = AnalyzeMechTable(input_table)
%rewrite all of this
    % c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
    % sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4); 

x = input_table.MechAmp;

[u_mechamps, ~, ia] = unique(x);
p_detect = zeros([length(u_mechamps),1]);
for j = 1:length(u_mechamps)
    correct_idx = strcmp(input_table.Response(ia == j), 'correct');
    p_detect(j) = sum(correct_idx)/length(correct_idx);
end
if any(u_mechamps == 0)
    catch_idx = find(u_mechamps == 0);
    p_detect(catch_idx) = 1 - p_detect(catch_idx);
end
dprime = zeros([length(u_mechamps), 1]);
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

detection_table = table(u_mechamps, p_detect, dprime, 'VariableNames', {'MechAmp', 'pDetect', 'dPrime'});

end


% 
%     x = input_table.MechAmp;
%     y = strcmpi(input_table.Response, 'correct');
% 
%     [ux, ~, ic] = unique(x);
% %trouble starts here
%     detection_vector = zeros(length(ux));
%     for d = 1:length(detection_vector)
%         if ux(d) == 0
%             detection_vector(d) = mean(~y(ic == d));
% 
%         else
%             detection_vector(d) = mean(y(ic == d));
%         end
%     end
% 
%     %Make d'
%     if detection_vector(1) < 1e-3
%         z_fa = norminv(1e-3);
%     else
%         z_fa = norminv(detection_vector(1));
%     end
% 
%     z_hit = norminv(detection_vector);
%     z_hit(isinf(z_hit)) = norminv(1-1e-3);
%     dprime = z_hit-z_fa;
% 
%     detection_table = table(ux, detection_vector, dprime, 'VariableNames', {'MechAmp', 'pDetect', 'dPrime'});
      
 



