clear; clc;close all

calculation_condition = "max_thrust";        % min_bsfc, min_bsfc_thrust_ratio, max_thrust

mach = [0.01, 0.05, 0.1, 0.12, 0.15, 0.18, 0.20, 0.21, 0.215];
altitudes = 0:4000:16000;

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

% EFFICIENCY MAP
for i = 1:1:length(altitudes)
    figure(i)
    for j=1:1:length(power_settings)
        plot(mach,efficiency_3D_array(:, i, j),'LineWidth',2);hold on
        title(strcat('Altitude ',num2str(altitudes(i)),' ft'))
    end
    xlabel('Mach');ylabel('Efficiency');grid on
    leg3 = legend(num2str(power_settings'));
    title(leg3,'power settings')
end

% THRUST MAP -> VALID
for i = 1:1:length(altitudes)
    figure(i+5)
    for j=1:1:length(power_settings)
        plot(mach,thrust_pounds_feet_per_second(:, i, j),'LineWidth',2);hold on
        title(strcat('Altitude ',num2str(altitudes(i)),' ft'))
    end
    xlabel('Mach');ylabel('Propeller Thrust (lb_f)');grid on
    leg1 = legend(num2str(power_settings'));
    title(leg1,'power settings')
end

% POWER MAP
for i = 1:1:length(altitudes)
    figure(i+10)
    for j=1:1:length(power_settings)
        plot(mach,Power_Extracted_3D_Matrix(:, i, j),'LineWidth',2);hold on
        title(strcat('Altitude ',num2str(altitudes(i)),' ft'))
    end
    xlabel('Mach');ylabel('Propeller Power');grid on
    leg2 = legend(num2str(power_settings'));
    title(leg2,'power settings')
end

% FUEL FLOW MAP -> VALID
figure()
for i= 1:1:length(altitudes)
    plot(power_settings,fuel_consumption_lb_per_hr(:,i),'LineWidth',2); hold on
end
xlabel('Power Setting %');ylabel('Fuel Flow (lb/hr)')
title(strcat('Fuel Flow map'));grid on
leg4 = legend(num2str(altitudes'),'Location','NorthWest');
title(leg4,'Altitude (ft)')
ylim([0 15])

%A surface plot will also prove valuable for developing a sense of the
%trends in the data
figure()
for i = 1:1:length(power_settings)
    surf(altitudes,mach,thrust_pounds_feet_per_second(:,:,i));hold on
end
xlabel('altitude (ft)');ylabel('Mach No.');
title('thrust map');hold off;

% power data with propeller on the DLA 180cc engine coming from its
% website:
% https://www.muginuav.com/product/dla180-180cc-efi-uav-engine-with-starter-and-alternator/
% figure()
% RPM_DLA_web = [2000,2243.05943000000,2493.48432800000,2732.86123500000,2972.23800300000,3222.66276000000,3462.03952700000,3705.09923800000,3955.52399500000,4198.58342500000,4434.27752900000,4677.33696000000,4924.07933400000,5167.13904600000,5406.51581300000,5660.62323300000,5896.31705600000];
% Power_DLA_web = 1.34102*[0.432431348000000,0.540540559000000,0.684683883000000,0.882881813000000,1.15315209300000,1.42342237300000,1.71171177100000,2.14414311800000,2.59459289700000,3.04504336300000,3.56756755300000,4.23423369200000,4.99099061300000,5.74774753300000,6.61261229000000,7.74774732700000,8.93693696900000];
% % plot(RPM_DLA_web, Power_DLA_web,'b--o','LineWidth',2);hold on
% %deck values
% RPM_deck = [2000, 3000, 4000, 5000, 6000, 7000];
% Power_Deck = [1.002, 1.009, 1.086, 1.141, 1.11, 0.8721];
% %yy plot for comparison
% yyaxis left
% plot(RPM_DLA_web,Power_DLA_web)
% ylabel('Power w Propeller (hp) - Website Values')
% yyaxis right
% plot(RPM_deck,Power_Deck)
% xlabel('RPM')
% ylabel('Power w Propeller (hp) - Deck Values')