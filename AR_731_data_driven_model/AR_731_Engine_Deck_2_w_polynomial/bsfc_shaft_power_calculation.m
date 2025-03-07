function [power_settings, BSFC_Min_Array, Shaft_Power_Array, RPM_Array] = bsfc_shaft_power_calculation()

    % Considering the BSFC's of the engine corresponding to different RPM's and
    % power settings

    % For a given power setting, selecting the minimum BSFC and taking
    % corresponding RPM

    % For selected power setting and RPM, finding the shaft power

    [power_settings, RPMs, P_TPS, BSFC_TPS] = AR_731_partial_and_full_throttle_ground_performance();


    total_power_settings = length(power_settings);

    BSFC_Min_Array = nan(total_power_settings, 1);
    Shaft_Power_Array = nan(total_power_settings, 1);
    RPM_Array = nan(total_power_settings, 1);

    for i = 1 : total_power_settings
%         ps = power_settings(i);
        bsfc_against_ps = BSFC_TPS(i, :);
        power_against_ps = P_TPS(i, :);

        % applying logic
        bsfc_min = min(bsfc_against_ps);
        rpm_corresponding_min_bsfc = RPMs(bsfc_against_ps == bsfc_min);
        RPM_Array(i) = min(rpm_corresponding_min_bsfc);
        shaft_power_corresponding_min_bsfc = power_against_ps(RPMs == min(rpm_corresponding_min_bsfc));


        BSFC_Min_Array(i) = bsfc_min;
        Shaft_Power_Array(i) = shaft_power_corresponding_min_bsfc;
    end

end

