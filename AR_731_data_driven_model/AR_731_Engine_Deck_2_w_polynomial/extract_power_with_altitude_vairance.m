% calculating the impact of altitude over the entire engine ground 
% power performance data
function [power_settings, RPMs, power_to_propeller_w_losses, Fuel_flow_w_alt] =...
          extract_power_with_altitude_vairance(altitudes)
% importing in the engine power performance directly
[power_settings, RPMs, P_TPS, BSFC_TPS] =...
                AR_731_partial_and_full_throttle_ground_performance();
kW_to_HP = 1.34102;
shaft_power_HP = P_TPS * kW_to_HP;
% multiplying each density ratio with the entire power (setting, rpm)
% matrix
for i = 1:1:length(altitudes)
    power_to_propeller_w_losses(:,:,i) = altitude_variations_with_losses...
    (altitudes(i), shaft_power_HP);
end
% converting the data for SFC into english units
g_per_kWh_to_lb_per_HPh = 0.001643987;
BSFC_lb_per_HPh = g_per_kWh_to_lb_per_HPh * BSFC_TPS;
%Now multiplying the SFC data to Power to get Fuel Flow
for i = 1:1:length(altitudes)
    power_to_propeller_w_o_losses(:,:,i) = ...
        power_to_propeller_w_losses(:,:,i)/0.8;
    Fuel_flow_w_alt(:,:,i) = power_to_propeller_w_o_losses(:,:,i).*BSFC_lb_per_HPh;
end
end