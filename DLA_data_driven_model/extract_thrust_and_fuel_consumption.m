function [power_settings, fuel_consumption_lb_per_hr, power_to_propeller_HP_w_mech_effects, ...
    thrust_pounds_feet_per_second,Power_Extracted_3D_Matrix, efficiency_3D_array, RPM_Array] =...
    extract_thrust_and_fuel_consumption(mach, altitudes, calculation_condition)
    %% Reading BSFC and Shaft Power From Engine Data
    [power_settings, BSFC_Array, Shaft_Power_Array, RPM_Array] = ...
        bsfc_and_shaft_power_from_engine(calculation_condition);

    kW_to_HP = 1.34102;
    power_to_propeller = altitude_variations_with_losses(altitudes, Shaft_Power_Array);
    power_to_propeller_HP = power_to_propeller * kW_to_HP;
    
    %% calculating fuel consumption in pounds per hour
    g_per_kWh_to_lb_per_HPh = 0.001643987;
    BSFC_lb_per_HPh = g_per_kWh_to_lb_per_HPh * BSFC_Array;
    power_to_propeller_HP_w_mech_effects = (power_to_propeller_HP / 0.8);
    fuel_consumption_lb_per_hr = BSFC_lb_per_HPh .* power_to_propeller_HP_w_mech_effects;

    %% calculating power extracted
    
    feet_to_meters = 0.3048;
    altitude_in_meters = altitudes * feet_to_meters;
    [~, a, ~, ~] = atmosisa(altitude_in_meters);
    
    meters_per_second_to_mph = 2.23694;
    velocities = mach' * a;% in SI Units
    velocities_mph = velocities * meters_per_second_to_mph;

    [Power_Extracted_3D_Matrix, efficiency_3D_array] = Calculate_Power_Extracted(velocities_mph, ...
        power_to_propeller_HP, RPM_Array);
    
    meters_to_feet = 3.28084;
    velocities_ft_per_second = velocities * meters_to_feet;
    
    thrust_pounds_feet_per_second = 550 * Power_Extracted_3D_Matrix ./ velocities_ft_per_second;
    
    
end