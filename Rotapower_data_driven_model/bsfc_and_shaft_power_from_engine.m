function [power_settings, BSFC_Array, Shaft_Power_Array, RPM_Array] = ...
    bsfc_and_shaft_power_from_engine(calculation_condition)

    [power_settings, RPMs, P_TPS, BSFC_TPS] = engine_data_rotapower_150cc();

    
    total_power_settings = length(power_settings);

    BSFC_Array = nan(total_power_settings, 1);
    Shaft_Power_Array = nan(total_power_settings, 1);
    RPM_Array = nan(total_power_settings, 1);

    for i = 1 : total_power_settings
        %first of all, the following two arrays, which keep changing with
        %the loop, are responsible for extracting the power and sfc arrays
        %against the current power setting from the above imported 2-D
        %matrices, i.e. P_TPS & BSFC_TPS.
            bsfc_against_ps = BSFC_TPS(i, :);
            power_against_ps = P_TPS(i, :);
        if calculation_condition == "min_bsfc"
            % applying logic
            % Considering the BSFC's of the engine corresponding to different RPM's and
            % power settings
            % For a given power setting, selecting the minimum BSFC and taking
            % corresponding RPM
            % For selected power setting and RPM, finding the shaft power
            bsfc_min = min(bsfc_against_ps);
            rpm_corresponding_min_bsfc = RPMs(bsfc_against_ps == bsfc_min);
            shaft_power_corresponding_min_bsfc = power_against_ps(RPMs == min(rpm_corresponding_min_bsfc));
            RPM_Array(i) = min(rpm_corresponding_min_bsfc);
            BSFC_Array(i) = bsfc_min;
            Shaft_Power_Array(i) = shaft_power_corresponding_min_bsfc;
        elseif calculation_condition == "min_bsfc_thrust_ratio"
            bsfc_power_ratio = bsfc_against_ps ./ power_against_ps;
            bsfc_power_ratio_min = min(bsfc_power_ratio);
            bsfc_corresponding = bsfc_against_ps(bsfc_power_ratio == bsfc_power_ratio_min);
            rpm_corresponding = RPMs(bsfc_power_ratio == bsfc_power_ratio_min);
            shaft_power_corresponding = power_against_ps(RPMs == rpm_corresponding);
            RPM_Array(i) = rpm_corresponding;
            BSFC_Array(i) = bsfc_corresponding;
            Shaft_Power_Array(i) = shaft_power_corresponding;
        elseif calculation_condition == "max_thrust"
            shaft_power_max = max(power_against_ps);
            rpm_corresponding = RPMs(power_against_ps == shaft_power_max);
            bsfc_corresponding = bsfc_against_ps(RPMs == rpm_corresponding);
            RPM_Array(i) = rpm_corresponding;
            BSFC_Array(i) = bsfc_corresponding;
            Shaft_Power_Array(i) = shaft_power_max;
        end
    end

end

