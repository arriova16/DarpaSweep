function [obs_pdetect, pred_pdetect] = ObsVsPred(input_table)

    icms_amps = input_table.StimAmp;
    mech_amps = input_table.IndentorAmp;
    y = strcmpi(input_table.Response, 'correct');
    u_icms_amps = unique(icms_amps);
    u_mech_amps = unique(mech_amps);

    obs_pdetect = zeros(length(u_mech_amps), length(u_icms_amps));
    pred_pdetect = zeros(length(u_mech_amps), length(u_icms_amps));
    
    for d1 = 1:length(u_icms_amps)
        

    end
end