%This code employs the BET to model the propeller efficiency and the
%thrust, torque and power generated by the propeller. The plan is to
%initially recreate the results given by the excel files created by
%S.Gudmundson and then proceed to replace the data by our own propeller
%The solution as prepared here breaks the propeller blades into 20 elements
%of equal width. Let�s begin the procedure by calculating some preliminaries:
clc;clear;close all

altitude_ft = 0;
V_0_fts = 0.1;%ft/s
RPM = 4000;
propeller_file = "22x8-PERF.PE0";

%Establishing atmospheric Parameters
alt_ft = altitude_ft;%ft
alt_m = alt_ft * 0.3048;%m
%Temp in K, Sound Speed in m/s, Pressure in Pa, rho in kg/m3
[T_si,a_si,P_si,rho_si] = atmoscoesa(alt_m);
%converting atmospheric values to english units
T_eng = 1.8*T_si; %Temperature in English 
a = 3.28084*a_si; %speed of sound in english
P = 0.02088547*P_si;%Pressure in english
rho = 0.00194032*rho_si;%density in english
mew = ((-2.05e-09).*(alt_ft/1000)) + 3.739e-07;%Dynamic Viscoscity curvefit

%Basic Data
Dia_prop = 11.01*2;%inches
Dia_hub = 3.13*2;%inches
a_alt = a;

%Preliminaries
n = RPM/60;%rps
Omega = 2*pi*(RPM/60);%rad/s
R_hub = (Dia_hub/2)*(1/12);%ft
n_blades = 2;
%column 1 which was just serial id's is omitted since the set of
%stations and chords are available from the get go
[r, R, c, Beta_deg] = Read_PropellerData_InFeet(propeller_file);
no_elements = length(r);%no. of elements the prop is divided in
%Column 3 is calculated to allow plotting of results with respect to the 
%fraction of the blade span
x = r./R;
%Column 4 is the chord at the radial
%Column 5 is the area of the blade element
for i = 1:1:(no_elements)
    %Column 5 is the area of the blade element
    if i == 1
        del_r(i) = r(i) - R_hub;
    elseif i ~= 1
        del_r(i) = r(i) - r(i-1);
    end
    del_A(i) = c(i)*del_r(i);
    %Column 6 is the forward speed (i.e. the airplane�s airspeed) converted to 
    %ft/s and is equal for all the rows
    V_o(i) = V_0_fts;
    %Column 7 is the blade�s tangential rotational speed at that segement
    Omega_x_r(i) = Omega*r(i);
    %Column 8 is the resultant velocity for each segment that combines rotation
    %and forward speed
    V_R(i) = sqrt((V_o(i)^2)+(Omega_x_r(i)^2));
    %Column 9 is the Mach Number for each blade segement - some differences may
    %occur due to inaccuracies in the density or a matrices
    M(i) = V_R(i)/a_alt;
    %Columns 10 and 11 contain the helix angle in radians and degrees
    phi_rad(i) = atan(V_o(i)/Omega_x_r(i));
    phi_deg(i) = rad2deg(phi_rad(i)); 
    %Columns 14 and 15 contain the geometric pitch angle B which is specified
    %in the file
    Beta_rad(i) = deg2rad(Beta_deg(i));
    %Columns 16 and 17 contain the AOA of the airfoil.
    Re(i) = (rho*V_R(i)*c(i))/mew;
    alpha_zl_deg(i) = -6.2;% taken from Gudmundson - simplification
    alpha_zl_rad(i) = deg2rad(alpha_zl_deg(i));
end
%now we need the AOA at each segment and of course that uses the formula:
%alpha = Beta - phi - alpha_i + alpha_ZL
%now in the example, it has been stated that the example propeller uses a
%single airfoil and so the zero lift AOA will remain the same trough out
%however we will probably have a more complicated scenario with different
%airfoils at different segments and thereby causing different zerolift
%AOAs, in which case, a set will have to be populated for this manually:
%for now use the sigular example value in all positions
%Column 18 contains the Reynolds number for the blade elements
%for now the assumption is that the prop is made out of a single airfoil,
%that probably wont be the case in reality thereby making it a necessity to
%have a lift and drag equation for every different airfoil used in the prop
%and then access it at the respective section's AOA against the AOA at that
%section.
%Columns 19 and 20 will contain the C_l and C_d values of the airfoil
%section of the segment in question against the Alpha calculated apriori. 
%Columns 21 and 22 contain the differential lift and drag acting on element 
w(1:no_elements,1) = 1;%ft/s
alpha_deg(1:no_elements,1) = 7.143;%deg;
alpha_rad(1:no_elements,1) = deg2rad(alpha_deg(1:no_elements,1));%rad
% starting the loops:
for i = 1:1:(no_elements)
    for j = 1:1:10
        V_E(i,j) = sqrt(((w(i,j)+V_0_fts)^2)+(Omega_x_r(i)^2));
        
        C_l(i,j) = ((-4.582e-6)*(alpha_deg(i,j)^4)) + ((-2.926e-5)*(alpha_deg(i,j)^3))...
                    + ((2.490e-4)*(alpha_deg(i,j)^2)) + ((7.239e-2)*(alpha_deg(i,j)^1)) + (4.426e-1);
        
        C_d(i,j) = ((6.844e-6)*(alpha_deg(i,j)^3)) + ((3.439e-4)*(alpha_deg(i,j)^2))...
                    + ((3.488e-3)*(alpha_deg(i,j)^1)) + ((1.996e-2));
     
        f_w(i,j) = (((8*pi*r(i))/(n_blades*c(i)))*w(i,j))-((V_E(i,j)/...
        (V_0_fts+w(i,j)))*(C_l(i,j)*Omega_x_r(i))-(C_d(i,j)*(w(i,j)*V_0_fts)));
    
        f_prime_w(i,j) = ((8*pi*r(i))/(n_blades*c(i))) - (((C_l(i,j)...
        *Omega_x_r(i)))*((1/V_E(i,j))-(V_E(i,j)/((V_0_fts+w...
        (i,j))^2)))) + (C_d(i,j)*((w(i,j)*V_0_fts)/(V_E(i,j))));
    
        w(i,j+1) = w(i,j) - ((f_w(i,j))/(f_prime_w(i,j)));
        
        diff(i,j) = w(i,j+1) - w(i,j);
        
        alpha_i_rad(i,j) = atan(w(i,j)/V_E(i,j));  
        alpha_i_deg(i,j) = rad2deg(alpha_i_rad(i,j));
        
        alpha_rad(i,j+1) = Beta_rad(i)-phi_rad(i)-alpha_i_rad(i,j)+alpha_zl_rad(i);
        alpha_deg(i,j+1) = rad2deg(alpha_rad(i,j+1));
    end
    C_l(i) = C_l(i,end);
    C_d(i) = C_d(i,end);
    d_L(i) = 0.5*rho*V_E(i,end)*V_E(i,end)*c(i)*C_l(i)*del_r(i);
    d_D(i) = 0.5*rho*V_E(i,end)*V_E(i,end)*c(i)*C_d(i)*del_r(i);
end
% WITH CORRECTIONS
for i = 1:1:(no_elements)
    %defining the prandtl tip and hub loss corrections
    P_tip(i) = (n_blades/2)*((R-r(i))/(r(i)*sin(phi_rad(i))));
    F_tip(i) = (2/pi)*acos(exp(-P_tip(i)));
    P_hub(i) = (n_blades/2)*((r(i)-R_hub)/(r(i)*sin(phi_rad(i))));
    F_hub(i) = (2/pi)*acos(exp(-P_hub(i)));
    F_P(i) = F_tip(i)*F_hub(i);
    d_T(i) = F_P(i)*((d_L(i)*cos(phi_rad(i)+alpha_i_rad(i,end))) - ...
    (d_D(i)*sin(phi_rad(i)+alpha_i_rad(i,end))));
    d_Q(i) = F_P(i)*(r(i)*((d_L(i)*sin(phi_rad(i)+alpha_i_rad(i,end)))+(d_D(i)*cos...
    (phi_rad(i)+alpha_i_rad(i,end)))));
    d_P(i) = F_P(i)*(Omega_x_r(i)*((d_L(i)*sin(phi_rad(i)+alpha_i_rad(i,end)))+...
    (d_D(i)*cos(phi_rad(i)+alpha_i_rad(i,end)))));
end
%Total values
Thrust = n_blades*sum(d_T);
Torque = n_blades*sum(d_Q);
Power = n_blades*sum(d_P);
%Coefficients
C_P = Power/(rho*(n^3)*((Dia_prop/12)^5));
C_T = Thrust/(rho*(n^2)*((Dia_prop/12)^4));
C_Q = Torque/(rho*(n^2)*((Dia_prop/12)^5));
%prop efficiency calculation
J = V_0_fts/(n*(Dia_prop/12));
eeta_p = J*(C_T/C_P);
