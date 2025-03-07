function [power_settings, RPMs, P_TPS, BSFC_TPS] = engine_data_rotapower_150cc()
%General Data
power_settings = [20, 25, 30, 40, 50, 70, 100];
RPMs = 3000:500:9000;%Adjusting the RPMS aray based on the rpm range of rotamotors data
RPM_pseudo = 3000:500:6500;
%Introducing the scaled rotapower data:
RPM_partials = [3000, 3600, 4200, 4800, 5400, 6000, 6600, 7200, 7800];
Power_rotapower_original = [3, 5.25, 7.7, 10.1, 12.5, 14.6, 16.2, 17.5, 18.5];
Power_rotapower_extrapolated = interp1(RPM_partials,Power_rotapower_original, RPMs,'cubic','extrap').*1.3;%Hp
%Introducing the TOA data  
%SHAFT POWER DATA
Power_TOA = [[3.0, 3.1, 3.2, 3.5, 4.3, 5.1, 5.4, 5.5]
            [3.9, 4.0, 3.95, 4.5, 5.0, 6.2, 6.7, 6.85]
            [4.4, 4.5, 4.8, 5.3, 6.1, 7.2, 8.05, 8.3]
            [5.1, 5.8, 6.3, 7.2, 8.1, 8.9, 9.7, 10.2]
            [5.3, 6.5, 7.2, 8.0, 8.8, 9.4, 10.7, 11.3]
            [5.7, 7.2, 8.1, 9.5, 10.3, 11.2, 12.5, 13]
            [6.2, 7.8, 8.8, 10.2, 11.7, 12.7, 14, 14.7]];   %kW
%             figure(1)
%     for i = 1:1:length(Power_TOA(:,1))  
%         plot(RPM_pseudo,Power_TOA(i,:),'LineWidth',1.5);hold on
%     end
%         grid on
%     legend(num2str(power_settings'))

for i = 1:1:length(Power_TOA(:,1))  
    P_Temp(i,:) =  interp1(RPM_pseudo,Power_TOA(i,:),RPMs,'linear','extrap');
end
%Normalizing the arrays
for i = 1:1:length(P_Temp(1,:))  
    P_Temp_normal(:,i) = P_Temp(:,i)./P_Temp(end,i);
end
%Now multiplying with the Rotapower data which is later to be
%converted to kW
%multiplication feasible
%figure(1)
for i = 1:1:length(P_Temp_normal(:,1))  
    P_TPS_hp(i,:) = (((P_Temp_normal(i,:)).*(Power_rotapower_extrapolated)));
    P_TPS(i,:) = (((P_Temp_normal(i,:)).*(Power_rotapower_extrapolated)))./1.34102;
%    plot(RPMs, P_TPS(i,:), 'LineWidth',1.5);hold on
end
% l1 = legend(num2str(power_settings'),'Location','NorthWest'); xlabel('RPM');ylabel('Shaft Power (kW)')
% title('Shaft Power Data');grid on
% title(l1,'Throttle Setting')
%BRAKE SPECIFIC FUEL CONSUMPTION DATA
BSFC_TOA = [[398, 418, 420, 411, 350, 318, 310, 320]
            [387, 396, 394, 342, 322, 287, 272, 298]
            [367, 363, 355, 330, 308, 290, 285, 300]
            [367, 342, 333, 310, 290, 288, 285, 300]
            [380, 322, 318, 300, 298, 307, 298, 318]
            [390, 338, 325, 306, 310, 318, 315, 330]
            [393, 380, 397, 370, 368, 388, 377, 388]];   %g/kWh
%  figure(2)
for i = 1:1:length(Power_TOA(:,1))  
    BSFC_Temp(i,:) =  interp1(RPM_pseudo,BSFC_TOA(i,:),RPMs,'linear','extrap');
%       plot(RPMs,BSFC_Temp(i,:),'LineWidth',1.5);hold on
end
%   legend(num2str(power_settings'))

%Now that we have extrapolated the BSFC data to 9000 rpms effectively, we 
%will proceed to manipulate the SFC matrix. before that, we need the
%website value scaled from 15 to 25 hp:
SFC_rated = (25/15)*305;%g/kWh
%Step # 1 - we start making the scaling vector by normalizing the last row
%of the SFC matrix with the last value of the SFC matrix
SFC_scaling_array_norm = BSFC_Temp(end,:)./BSFC_Temp(end,end);
%Step # 2 - we multiply the normalized array with the scaled up SFC value
%obtained prior to step 1
SFC_scaling_array = SFC_scaling_array_norm.*SFC_rated;
%Step # 3 - with the obtained scaling array, we now have to normalize the
%entire original BSFC_temp array using the last value for each column.
for i = 1:1:length(BSFC_Temp(1,:))  
    BSFC_Temp_normal(:,i) = BSFC_Temp(:,i)./BSFC_Temp(end,i);
end
%With the normmalized matrix and the scaling array available, we can
%finally move onto multiplying them both. We use a similar method as we did
%for power
%figure(2)
for i = 1:1:length(BSFC_Temp_normal(:,1))  
    BSFC_TPS(i,:) = (((BSFC_Temp_normal(i,:)).*(SFC_scaling_array)));%g/kWh
%    plot(RPMs, BSFC_TPS(i,:), 'LineWidth',1.5);hold on
end
% l2 = legend(num2str(power_settings'),'Location','NorthWest'); xlabel('RPM');ylabel('SFC (g/kWh)')
% title('SFC Data');grid on;ylim([300 630])
% title(l2,'Throttle Setting')
end
