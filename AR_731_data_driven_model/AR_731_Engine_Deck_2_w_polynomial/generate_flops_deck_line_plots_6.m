clear; clc;close all

calculation_condition = "min_bsfc_thrust_ratio";        % min_bsfc, min_bsfc_thrust_ratio, max_thrust

% mach = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.1, 0.12, 0.15, 0.18, 0.20, 0.21, 0.3];
mach = [0.01, 0.05, 0.1, 0.12, 0.15, 0.18, 0.20, 0.21, 0.3];

altitudes = 0 :5000 :50000;

[power_settings, fuel_consumption_lb_per_hr, power_to_propeller_HP_w_mech_effects,...
thrust_pounds_feet_per_second, Power_Extracted_3D_Matrix, efficiency_3D_array, RPM_PS] = ...
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

figure_no = 0;


% SHAFT POWER MAP
[power_settings, RPMs, power_to_propeller_w_losses] =...
                        extract_power_with_altitude_vairance(altitudes);
for i = 1:1:length(altitudes)
    figure_no = figure_no + 1;
    figure(figure_no)
    for j=1:1:length(power_settings)
        plot(RPMs, power_to_propeller_w_losses(j, :, i),'LineWidth',2);hold on
        title(strcat('Altitude =  ',num2str(altitudes(i)),' ft'))
    end
    xlabel('RPM');ylabel('Shaft Power (hp)');grid on
    leg1 = legend(num2str(power_settings'), 'Location','NorthWest');
    title(leg1,'power settings')
    ylim([0 30])
end


% % THRUST MAP -> VALID
% for i = 1:1:length(altitudes)
%     figure_no = figure_no + 1;
%     figure(figure_no)
%     for j=1:1:length(power_settings)
%         mach_new = linspace(mach(1), mach(end), 30);
%         thrust_pounds_feet_per_second_new(:, i, j) = spline(mach, thrust_pounds_feet_per_second(:, i, j)', mach_new);
%         plot(mach_new,thrust_pounds_feet_per_second_new(:, i, j),'LineWidth',2);hold on
%         title(strcat('Altitude =  ',num2str(altitudes(i)),' ft'))
%     end
%     xlabel('Mach');ylabel('Thrust (lb_f)');grid on
%     leg1 = legend(num2str(power_settings'));
%     title(leg1,'power settings')
% end


%FUEL FLOW MAP -> VALID
figure()
for i= 1:1:length(altitudes)
    plot(power_settings,smooth(fuel_consumption_lb_per_hr(:,i),'lowess'),...
        'LineWidth',2); hold on
end
xlabel('Power Setting %');ylabel('Fuel Flow (lb/hr)')
title(strcat('Fuel Flow map'));grid on
leg2 = legend(num2str(altitudes'),'Location','NorthWest');
title(leg2,'Altitude (ft)')
ylim([0 32])


% %SFC MAP ->
figure()
for i = 1:1:length(power_settings)
    plot(altitudes./1000,...
        (fuel_consumption_lb_per_hr(i,:)./power_to_propeller_HP_w_mech_effects(i,:))...
        ,'LineWidth',2);hold on
end
xlabel('Altitude x10^3');ylabel('SFC')
title(strcat('SFC map'));grid on
leg3 = legend(num2str(power_settings'),'Location','NorthEast');
title(leg3,'Power Setting %')
ylim([0 1])


% %A surface plot will also prove valuable for developing a sense of the
% %trends in the data
% figure()
% for i = 1:1:length(power_settings)
%     surf(altitudes,mach,thrust_pounds_feet_per_second(:,:,i));hold on
% end
% xlabel('altitude (ft)');ylabel('Mach No.');
% title('thrust map');hold off;



% %POWER MAP
% for i = 1:1:length(altitudes)
%     figure(i)
%     for j=1:1:length(power_settings)
%         plot(mach,Power_Extracted_3D_Matrix(:, i, j),'LineWidth',2);hold on
%         title(strcat('Altitude ',num2str(altitudes(i)),' ft'))
%     end
%     xlabel('Mach');ylabel('Thrust (lb_f)');grid on
%     leg1 = legend(num2str(power_settings'));
%     title(leg1,'power settings')
% end

%EFFICIENCY MAP
% for i = 1:1:length(altitudes)
%     figure(i)
%     for j=1:1:length(power_settings)
%         plot(mach,efficiency_3D_array(:, i, j),'LineWidth',2);hold on
%         title(strcat('Altitude ',num2str(altitudes(i)),' ft'))
%     end
%     xlabel('Mach');ylabel('Thrust (lb_f)');grid on
%     leg1 = legend(num2str(power_settings'));
%     title(leg1,'power settings')
% end


% clearing commmand prompt
clc