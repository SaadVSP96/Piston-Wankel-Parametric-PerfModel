%Graph of velocity and efficiency for AR 731 Engine at different RPMs
clc;clear variables;close all
%Establishing atmospheric Parameters
%alt_ft = 1000:1000:50000;      %limit is 36K 
alt_ft = 6500;
alt_m = alt_ft * 0.3048;
V_given = 80;                         %Velocity in knots
%Temp in K, Sound Speed in m/s, Pressure in Pa, rho in kg/m3
[T_si,a_si,P_si,rho_si] = atmoscoesa(alt_m);


%Momentum theory code to calculate efficiency at different velocities
%converting atmospheric values to english units
T_eng = 1.8*T_si;               %Temperature in English 
P = 0.02088547*P_si;            %Pressure in english
rho = 0.00194032*rho_si;         %density in english

rho_nod = 0.0022971;

PA_given_sealevel = 38; %Power in hp at sea level

%a_1 = 0.8;        %Installed engine factor
%P_A = P_A_given_5000  *(rho/rho_nod); %Power at 3000ft atltitude with installed engine factor


[V_mat,J_mat,Pe_mat,Ct_mat,Cp_mat,PWR_mat,Torque_mat,Thrust_mat]...
         = prop_data_read_function('PER3_28x20-4.dat');



%J=V/nD;

   

V_4000 = V_mat(:, 4)*0.868976; %MPH to Knots
eff_4000= Pe_mat(:,4);

V_5000 = V_mat(:, 5)*0.868976;
eff_5000= Pe_mat(:,5);

V_6000 = V_mat(:, 6)*0.868976;
eff_6000= Pe_mat(:,6);

V_7000 = V_mat(:, 7)*0.868976;
eff_7000= Pe_mat(:,7);



figure()

plot(V_4000,eff_4000,V_5000,eff_5000,V_6000,eff_6000,V_7000,eff_7000,'LineWidth',2); 
xlabel('Velocity(knots)','FontSize',14,'FontWeight','bold','Color','k');
ylabel('Efficiency','FontSize',14,'FontWeight','bold','Color','k'); 
legend('4000 RPM','5000 RPM','6000 RPM','7000 RPM');
title('V_{KTAS} vs eeta for prop 28 inches @ 6500ft for AR731','FontSize',14,'FontWeight','bold','Color','k');
grid on
figure()


% At power setting



P_A_4 =  4.7 *(rho/rho_nod);
P_A_5 =  9.3 *(rho/rho_nod);
P_A_6 =  16 *(rho/rho_nod);
P_A_7 =  25.4 *(rho/rho_nod);



P_A_4000_final= Pe_mat(:,4)*P_A_4;
P_A_5000_final= Pe_mat(:,5)*P_A_5;
P_A_6000_final= Pe_mat(:,6)*P_A_6;
P_A_7000_final= Pe_mat(:,7)*P_A_7;


plot(P_A_4000_final,eff_4000,P_A_5000_final,eff_5000,P_A_6000_final,eff_6000,P_A_7000_final,eff_7000,'LineWidth',2); 
xlabel('Power(hp)','FontSize',14,'FontWeight','bold','Color','k');
ylabel('Efficiency','FontSize',14,'FontWeight','bold','Color','k'); 
legend('4000 RPM','5000 RPM','6000 RPM','7000 RPM','Location','SouthEast');
title('eeta vs power for prop 28 inches @ 6500ft for Ar 731','FontSize',14,'FontWeight','bold','Color','k');
grid on


figure()

%title('Optimum RPM efficiencies')


max_eff = [0 0.7914 0.7949 0.8046 0.7221 0]
max_vel = [0 66.22 86.64 103.8 120.4 146]

plot(max_vel,max_eff)




