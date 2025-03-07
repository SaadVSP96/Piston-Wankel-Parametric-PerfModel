function power_to_propeller = altitude_variations_with_losses(altitudes, shaft_power)

    % altitudes in feet
    feet_to_meters = 0.3048;
    
    altitudes_meters = altitudes * feet_to_meters;
    
    [~, ~, ~, rho_SL_si] = atmosisa(0);
    [~, ~, ~, rho_si] = atmosisa(altitudes_meters);
    rho_factor = rho_si / rho_SL_si;
    loss_factor = 0.8;%ask sir on what to keep it as ?
    
    power_to_propeller = shaft_power .* rho_factor * loss_factor;

end