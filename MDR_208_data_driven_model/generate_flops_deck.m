clear; clc;close all

calculation_condition = "max_thrust";        % min_bsfc, min_bsfc_thrust_ratio, max_thrust

mach = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.1, 0.12, 0.15, 0.18, 0.20, 0.21, 0.3];
altitudes = 0 :5000 :50000;

[power_settings, fuel_consumption_lb_per_hr, thrust_pounds_feet_per_second, RPM_PS] = ...
    extract_thrust_and_fuel_consumption(mach, altitudes, calculation_condition);

fid = fopen("engine_deck_28.deck", "w");
fid_engine = fopen("engine_deck_28_w_RPM.deck", "w");
fprintf(fid_engine, "%4s    %10s    %5s   %5s      %10s      %10s      %10s\n", ...
    " Mach No.", "Altitude", "Power Setting", "Thrust", "Ram Drag", "Fuel Flow", "RPM");
for i = 1 : length(mach)
    m = mach(i);
    for j = 1 : length(altitudes)
        alt = altitudes(j);
        thrust_corresponding_ps = thrust_pounds_feet_per_second(i, j, :);
        for k = 1 : length(power_settings)
            ps = power_settings(k);
            thrust = thrust_corresponding_ps(k);
            fuel_flow = fuel_consumption_lb_per_hr(k, j);
            rpm = RPM_PS(k);
            
            fprintf(fid, "%5.3f%10.3f%5d%10.3f%10.3f%10.3f\n", m, alt, ps, thrust, 0, fuel_flow);
            fprintf(fid_engine, " %5.3f      %10.3f      %5d      %10.3f      %10.3f      %10.3f      %10.3f\n", m, alt, ps, thrust, 0, fuel_flow, rpm);
            
        end
    end
end

fclose(fid);
fclose(fid_engine);
