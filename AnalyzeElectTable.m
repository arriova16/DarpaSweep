function [detection_table] = AnalyzeElectTable(input_table)

%rewrite all of this
    % c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
    % sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4); 

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
  %   y = strcmpi(input_table.Response, 'correct');
  % 
  %   [ux, ~, ic] = unique(x);
  % 
  %   detection_vector = zeros(size(ux));
  %   for d = 1:length(detection_vector)
  %       if ux(d) == 0
  %           detection_vector(d) = mean(~y(ic == d));
  %       else
  %           detection_vector(d) = mean(y(ic == d));
  %       end
  %   end
  % 
  %   % Make d'
  %   z_fa = max([detection_vector(1), 1e-3]);
  % 
  %   if detection_vector(1) < 1e-3
  %       z_fa = norminv(1e-3);
  %   else
  %       z_fa = norminv(detection_vector(1));
  %   end
  %   z_hit = norminv(detection_vector);
  %   z_hit(isinf(z_hit)) = norminv(1-1e-3);
  %   dprime = z_hit - z_fa;
  % 
  %   detection_table = table(ux, detection_vector, dprime, 'VariableNames', {'StimAmp',  'pDetect', 'dPrime'});
  % 
  % end