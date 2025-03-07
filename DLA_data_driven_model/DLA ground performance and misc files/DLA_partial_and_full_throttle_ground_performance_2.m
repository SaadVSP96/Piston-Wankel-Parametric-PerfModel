clc;clear;close all
power_settings = [20, 25, 30, 40, 50, 70, 100];
RPMs_TOA = 1500:500:6500;
RPM_end = 7000;
RPMs = [RPMs_TOA, RPM_end];
%Introducing the TOA data  
%SHAFT POWER DATA
Power_TOA = [[2.57627127000000,2.54915097000000,2.98305094400000,3.17288063100000,3.06440563700000,3.09152386800000,3.47118531200000,4.23050819800000,5.04406754600000,5.34237222600000,5.28813473000000];
             [2.58686358500000,3.12923648400000,3.61737292100000,3.78008437700000,3.96991406400000,3.91567760100000,4.48516873100000,4.97330413300000,6.13940669400000,6.57330253000000,6.76313532000000];
             [2.83093180400000,3.26482970900000,3.88855937000000,4.43093123500000,4.43093123500000,4.83771090900000,5.32584734500000,6.11228742800000,7.14279572900000,8.03771184000000,8.06483007100000];
             [2.96652502800000,3.94279583200000,4.67499738400000,5.16313485500000,5.70550775400000,6.32923638100000,7.27838895400000,8.09194830200000,8.87838941900000,9.61059304000000,9.42076231800000];
             [2.83093180400000,3.94279583200000,4.89194840600000,5.46144057000000,6.51906710200000,7.16991499500000,7.98347434300000,8.76991442600000,9.47499981500000,10.6139831100000,11.2648299700000];
             [2.88516826600000,4.15974582000000,4.89194840600000,5.75974318200000,7.08855926700000,8.06483007100000,9.58347377400000,10.3156773900000,11.1563560100000,12.4038132600000,12.7563554400000];
             [2.77669327200000,4.26821874400000,5.21737028300000,6.16652285600000,7.71228789400000,8.79703369100000,10.2072034400000,11.6716096400000,12.6478814800000,14.0580496700000,14.6817793300000]]; %kW
%We are aware that the TOA data is missing for higher RPMs of the DLA
%engine and although different websites quote different operating ranges of
%the DLA, we will use the upper performance extent of 18hp at 7000 RPMs 
%provided by SAMI to extrapolate the power and SFC data:
for i = 1:1:length(Power_TOA(:,1))
    Power_Temp(i,:) =  interp1(RPMs_TOA,Power_TOA(i,:),RPMs,'linear','extrap');
end
%Now that we have extrapolated the power data to 7000 rpms effectively, we 
%will proceed to manipulate the power matrix. before that, we define the
%maximum power value to 18hp since that is the maximum performance
%specified in the SAMI data
Power_rated = 18;%hp
%Step # 1 - we start making the scaling vector by normalizing the last row
%of the Power_TOA matrix with the last value of the Power_TOA matrix
Power_scaling_array_norm = Power_Temp(end,:)./Power_Temp(end,end);
%Step # 2 - we multiply the normalized array with the Power_rated value
%obtained prior to step 1
Power_scaling_array = Power_scaling_array_norm.*Power_rated;
%Step # 3 - with the obtained scaling array, we now have to normalize the
%entire original Power_Temp array using the last value for each column.
for i = 1:1:length(Power_Temp(1,:))  
    Power_Temp_normal(:,i) = Power_Temp(:,i)./Power_Temp(end,i);
end
%With the normmalized matrix and the scaling array available, we can
%finally move onto multiplying them both
figure(1)
for i = 1:1:length(Power_Temp_normal(:,1))  
    P_TPS_hp(i,:) = (((Power_Temp_normal(i,:)).*(Power_scaling_array)));%hp
    P_TPS(i,:) = (((Power_Temp_normal(i,:)).*(Power_scaling_array)))./1.34102;%kW
    plot(RPMs, P_TPS_hp(i,:), 'LineWidth',2);hold on
end
l1 = legend(num2str(power_settings'),'Location','NorthWest'); xlabel('RPM');ylabel('Power (hp)')
title('Power Data');grid on;xlim([1500 7000])
title(l1,'Throttle Setting')


%Introducing the TOA data  
%BRAKE SPECIFIC FUEL CONSUMPTION DATA
SFC_TOA = [[415.783980900000,434.738688100000,412.229983200000,398.606295100000,415.191655500000,418.153327800000,411.045309700000,349.442516900000,318.048795100000,310.348429000000,301.463412200000];
           [420.754035500000,394.098984800000,381.067622200000,383.436923900000,394.098984800000,392.914311400000,341.973534300000,321.241828300000,288.071107600000,272.670420700000,297.548449900000];
           [483.541501800000,410.092019800000,376.921299100000,366.851608800000,362.705217800000,353.820200900000,330.126845200000,307.025837400000,291.032779900000,283.924784400000,321.241828300000];
           [484.726152600000,406.538022000000,381.659970200000,366.851608800000,340.788883500000,329.534519700000,307.618162800000,288.071107600000,287.478782200000,283.924784400000,298.733145900000];
           [487.095499500000,435.562397000000,394.098984800000,379.290623400000,333.680888100000,317.095505100000,300.510122200000,296.956124500000,304.656490500000,296.956124500000,312.949182000000];
           [512.565876700000,410.092019800000,400.614677500000,389.360268500000,337.827211200000,324.203500600000,301.694818200000,307.025837400000,318.280156000000,312.949182000000,330.126845200000];
           [510.196552400000,417.200037800000,404.761000600000,391.729660600000,379.882971400000,395.875983700000,368.036282200000,366.259260700000,387.583314800000,374.551907000000,387.583314800000]];   %g/kWh
% since the TOA and DLA are 2 cylinder piston engines, their SFC trends are
% expected to be similar. Although a power or SFC curve solely for the
% engine has not been found, an SFC curve with a 32 inch propeller shows an
% erratic trend with values similar to those of the TOA. Since the SFC data
% does not follow a clearly discernable increasing or decreasing trend, we
% will not adjust it for a singular value of the DLA trend, instead we will
% simply extrapolate the TOA trend for the missing RPMs.
figure(2)
%Now we add the extrapolated data of TOA
for i = 1:1:length(Power_TOA(:,1))  
    BSFC_TPS(i,:) =  interp1(RPMs_TOA,SFC_TOA(i,:),RPMs,'linear','extrap');%g/kWh
    plot(RPMs,BSFC_TPS(i,:),'LineWidth',2);hold on
end
l2 = legend(num2str(power_settings'),'Location','NorthEast'); xlabel('RPM');ylabel('SFC (g/kWh)')
title('SFC Data');grid on;xlim([1500 7000])
title(l2,'Throttle Setting')
%We will also include a scatter plot of the DLA data (with propeller) to
%show that the TOA data is quite similar to it:
%Data from the link:
%https://www.muginuav.com/product/dla180-180cc-efi-uav-engine-with-starter-and-alternator/
% RPMs_DLA = [2000 2500 3000 3500 4000 4500 5000 5500 5900];
% SFC_DLA = [983, 756, 558, 431, 360, 340, 349, 430, 419];%g/kWh
% scatter(RPMs_DLA, SFC_DLA, 50, 'd', 'filled','red');hold on


