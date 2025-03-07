function [power_settings, RPMs, P_TPS, BSFC_TPS] =...
                    AR_731_partial_and_full_throttle_ground_performance()
%General Data
power_settings = [20, 25, 30, 40, 50, 70, 100];
RPMs = 2000:500:8000;%Adjusting the RPMS aray based on the rpm range of AR731 data
RPM_pseudo = 3000:500:6500;
%Introducing the AR 731 data:
RPM_partials = [2870.712401055409, 3010.52631600000,3500,4005.26315800000,4510.52631600000,5000,5505.26315800000,5978.94736800000,6484.21052600000,6989.47368400000,7510.52631600000,7984.21052600000];
Power_AR_731_original = [9.35361216730038, 10.1140684400000,12.9277566500000,15.7414448700000,18.8593155900000,21.8250950600000,25.0950570300000,27.9847908700000,31.1026616000000,33.9163498100000,36.2737642600000,38.4030418300000];%bhp
Power_AR_731_extrapolated = interp1(RPM_partials,Power_AR_731_original, RPMs,'cubic','extrap');%Hp
%Introducing the TOA data  
%SHAFT POWER DATA
Power_TOA = [[3.0, 3.1, 3.2, 3.5, 4.3, 5.1, 5.4, 5.5]
            [3.9, 4.0, 3.95, 4.5, 5.0, 6.2, 6.7, 6.85]
            [4.4, 4.5, 4.8, 5.3, 6.1, 7.2, 8.05, 8.3]
            [5.1, 5.8, 6.3, 7.2, 8.1, 8.9, 9.7, 10.2]
            [5.3, 6.5, 7.2, 8.0, 8.8, 9.4, 10.7, 11.3]
            [5.7, 7.2, 8.1, 9.5, 10.3, 11.2, 12.5, 13]
            [6.2, 7.8, 8.8, 10.2, 11.7, 12.7, 14, 14.7]];

for i = 1:1:length(Power_TOA(:,1))
    P_Temp(i,:) =  interp1(RPM_pseudo,Power_TOA(i,:),RPMs,'linear','extrap');
end
%Normalizing the arrays
for i = 1:1:length(P_Temp(1,:))  
    P_Temp_normal(:,i) = P_Temp(:,i)./P_Temp(end,i);
end
%Now multiplying with the AR 731 data which is later to be
%converted to kW
%multiplication feasible
%figure(1)
for i = 1:1:length(P_Temp_normal(:,1))  
    P_TPS_hp(i,:) = (((P_Temp_normal(i,:)).*(Power_AR_731_extrapolated)));
%     plot(RPMs, P_TPS_hp(i,:), 'LineWidth',1.5);hold on
end
P_TPS = (1/1.34102)*P_TPS_hp; %kW
% l1 = legend(num2str(power_settings'),'Location','NorthWest'); xlabel('RPM');ylabel('Shaft Power (hp)')
% title('Shaft Power Data');grid on
% title(l1,'Throttle Setting')


%BRAKE SPECIFIC FUEL CONSUMPTION DATA
%Introducing the AR 731 data:
RPM_partial = [4010.55409000000,4501.31926100000,4992.08443300000,5498.68073900000,6005.27704500000,6496.04221600000,7018.46965700000,7525.06596300000,8000];
SFC_AR_731_original = [0.628787879000000,0.630303030000000,0.628787879000000,0.627272727000000,0.624242424000000,0.618181818000000,0.609090909000000,0.584848485000000,0.559090909000000];
SFC_AR_731_extrapolated = interp1(RPM_partial,SFC_AR_731_original, RPMs,'cubic','extrap');%lb/bhp hr

%Introducing the TOA data  
SFC_TOA = [[398, 418, 420, 411, 350, 318, 310, 320]
            [387, 396, 394, 342, 322, 287, 272, 298]
            [367, 363, 355, 330, 308, 290, 285, 300]
            [367, 342, 333, 310, 290, 288, 285, 300]
            [380, 322, 318, 300, 298, 307, 298, 318]
            [390, 338, 325, 306, 310, 318, 315, 330]
            [393, 380, 397, 370, 368, 388, 377, 388]];   %g/kWh
% figure(2)
for i = 1:1:length(Power_TOA(:,1))  
    SFC_Temp(i,:) =  interp1(RPM_pseudo,SFC_TOA(i,:),RPMs,'linear','extrap');
%     plot(RPMs,SFC_Temp(i,:),'LineWidth',1.5);hold on
end
% legend(num2str(power_settings'))
%we now have to normalize the entire original BSFC_temp array using the 
%last value for each column.
for i = 1:1:length(SFC_Temp(1,:))  
    SFC_Temp_normal(:,i) = SFC_Temp(:,i)./SFC_Temp(end,i);
end
%With the normmalized matrix and the SFC array available, we can
%finally move onto multiplying them both. We use a similar method as we did
%for power
% figure(2)
for i = 1:1:length(SFC_Temp_normal(:,1))
    SFC_TPS_lb_bhp_hr(i,:) = SFC_Temp_normal(i,:).*SFC_AR_731_extrapolated;%lb/bhp/hr
%     plot(RPMs, SFC_TPS_lb_bhp_hr(i,:), 'LineWidth',1.5);hold on
end
BSFC_TPS = SFC_TPS_lb_bhp_hr*608.27738784; %g/kWh
% l2 = legend(num2str(power_settings'),'Location','NorthEast'); xlabel('RPM');ylabel('SFC (%lb/bhp/hr)')
% title('SFC Data');grid on
% title(l2,'Throttle Setting')
end

