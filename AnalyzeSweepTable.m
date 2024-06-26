function [detection_table] = AnalyzeSweepTable(input_table)

    icms_amps = input_table.StimAmp;
    mech_amps = input_table.IndentorAmp;
    y = strcmpi(input_table.Response, 'correct');
    u_icms_amps = unique(icms_amps);
    u_mech_amps = unique(mech_amps);
    
    detection_table = zeros(length(u_mech_amps), length(u_icms_amps));
    for d1 = 1:length(u_icms_amps)
        for d2 = 1:length(u_mech_amps)
            d_idx = icms_amps == u_icms_amps(d1) & mech_amps == u_mech_amps(d2);
            if u_mech_amps(d2) == 0
                detection_table(d2,d1) = mean(~y(d_idx));
            else
                detection_table(d2,d1) = mean(y(d_idx));
            end
        end
    end
    ux1_str = cell(size(u_icms_amps));
    for d1 = 1:length(u_icms_amps)
        ux1_str{d1} = num2str(u_icms_amps(d1));
    end
    ux2_str = cell(size(u_mech_amps));
    for d2 = 1:length(u_mech_amps)
        ux2_str{d2} = num2str(u_mech_amps(d2));
    end
    detection_table = array2table(detection_table,...
        'VariableNames', ux1_str, 'RowNames', ux2_str);
 


    end

% %dprime - adjusted - z(hit)-z(FA)-- shared false alarm rate
% % 
