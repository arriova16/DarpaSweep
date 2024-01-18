function [detection_table, coeff_table] = AnalyzeDetectionTable(input_table)
    % c(1) = rate of change, c(2) = x-offset, c(3) = multiplier, c(4) = offset
    sigfun = @(c,x) (c(3) .* (1./(1 + exp(-c(1).*(x-c(2)))))) + c(4); 

    x = input_table.TestStimAmp;
%     x = input_table.CondStimAmp;
    y = strcmpi(input_table.Response, 'correct');
    [ux, ~, ic] = unique(x);
    detection_vector = zeros(size(ux));
    for d = 1:length(detection_vector)
        if ux(d) == 0
            detection_vector(d) = mean(~y(ic == d));
        else
            detection_vector(d) = mean(y(ic == d));
        end
    end
    
    % Make d'
    if detection_vector(1) < 1e-3
        z_fa = norminv(1e-3);
    else
        z_fa = norminv(detection_vector(1));
    end
    z_hit = norminv(detection_vector);
    z_hit(isinf(z_hit)) = norminv(1-1e-3);
    dprime = z_hit - z_fa;

    detection_table = table(ux, detection_vector, dprime, 'VariableNames', {'StimAmp',  'pDetect', 'dPrime'});
    
  end