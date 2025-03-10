%This code employs the BET to model the propeller efficiency and the
%thrust, torque and power generated by the propeller. The plan is to
%initially recreate the results given by the excel files created by
%S.Gudmundson and then proceed to replace the data by owr own propeller
%should the data become available.
clc;clear variables;close all
%The solution as prepared here breaks the propeller blades into 20 elements
%of equal width. Let�s begin the procedure by calculating some preliminaries:

propeller_file = "22x8-PERF.PE0";
airfoil_dat_file = "ClarkY.dat";

%Establishing atmospheric Parameters
alt_ft = 1000:1000:50000;%limit is 36K 
alt_m = alt_ft * 0.3048;
%Temp in K, Sound Speed in m/s, Pressure in Pa, rho in kg/m3
[T_si,a_si,P_si,rho_si] = atmoscoesa(alt_m);
%converting atmospheric values to english units
T_eng = 1.8*T_si; %Temperature in English 
a = 3.28084*a_si; %speed of sound in english
P = 0.02088547*P_si;%Pressure in english
rho = 0.00194032*rho_si;%density in english
mew = ((-2.05e-09).*(alt_ft/1000)) + 3.739e-07;%Dynamic Viscoscity curvefit
%Specifying all of the Mach Numbers
Machs = 0.01:0.01:1.0;

%Basic Data
Scale_factor = 1;%scale prop geometry roughly
V_0_fts = 10.5*1.46667;%mph to ft/s
RPM = 4000;
Dia_prop = 11.01*2*Scale_factor;%inches
Dia_hub = 3.13*2*Scale_factor;%inches
alt_op = 1;% n*1000 ft
a_alt = a(alt_op);

%Preliminaries
n = RPM/60;%rps
Omega = 2*pi*(RPM/60);%rad/s
R_hub = (Dia_hub/2)*(1/12);%ft
n_blades = 2;
%column 1 which was just serial id's is omitted since the set of
%stations and chords are available from the get go
[r, R, c, Beta_deg] = Read_PropellerData_InFeet(propeller_file);
no_elements = length(r);%no. of elements the prop is divided in
del_r = r(7)-r(6);%ft - the value seems to be equal between all successive elements
%Column 3 is calculated to allow plotting of results with respect to the 
%fraction of the blade span
x = r./R;
%Column 4 is the chord at the radial
%Column 5 is the area of the blade element
for i = 1:1:length(r)
    %Column 5 is the area of the blade element
    del_A(i) = c(i)*del_r;
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
    %Columns 12 and 13 contain the induced flow angle, ai, ahead of the 
    %propeller, which reduces the overall AOA on the blade element
    alpha_i_rad(i) = 0;
    alpha_i_deg(i) = rad2deg(alpha_i_rad(i));
end
%Columns 14 and 15 contain the geometric pitch angle B which is specified
%in the file
Beta_rad = deg2rad(Beta_deg);
%now we need the AOA at each segment and of course that uses the formula:
%alpha = Beta - phi - alpha_i + alpha_ZL
%now in the example, it has been stated that the example propeller uses a
%single airfoil and so the zero lift AOA will remain the same trough out
%however we will probably have a more complicated scenario with different
%airfoils at different segments and thereby causing different zerolift
%AOAs, in which case, a set will have to be populated for this manually:
%for now use the sigular example value in all positions
zero_lift_aoa = 0;%deg
alpha_zl_deg = ones(1,no_elements)*(zero_lift_aoa);
alpha_zl_rad = deg2rad(alpha_zl_deg);
%Columns 19 and 20 will contain the C_l and C_d values of the airfoil
%section of the segment in question against the Alpha calculated apriori. 
%For now we assumed that there is only one airfoil making up the whole prop
%but later on we will have 2x the number of airfoils that make up the
%propeller
%inport this data from XFLR5 against the analysis of the CLARKY airfoil at
%the average reynold number and the Mach at the nearest index to that
%Reynolds number
for i = 1:1:length(r)
    %Columns 16 and 17 contain the AOA of the airfoil.
    alpha_rad(i) = Beta_rad(i) - phi_rad(i) - alpha_i_rad(i) + alpha_zl_rad(i);
    alpha_deg(i) = round(rad2deg(alpha_rad(i)),0);
    %Column 18 contains the Reynolds number for the blade elements
    Re(i) = (rho(alt_op)*V_R(i)*c(i))/mew(alt_op);
    mach = M(i);
    %Columns 19 and 20 will contain the C_l and C_d values of the airfoil
    %section of the segment in question against the Alpha calculated apriori.
	[cl, cd] = XFoil_Analysis(mach, Re(i), alpha_deg(i), airfoil_dat_file);
    C_l(i) = cl;
    C_d(i) = cd;
    %Columns 21 and 22 contain the differential lift and drag acting on element 
    d_L(i) = 0.5*rho(alt_op)*V_R(i)*V_R(i)*c(i)*C_l(i)*del_r;
    d_D(i) = 0.5*rho(alt_op)*V_R(i)*V_R(i)*c(i)*C_d(i)*del_r; 
end
for i = 1:1:no_elements
    d_T(i) = ((d_L(i)*cos(phi_rad(i)+alpha_i_rad(i))) - ...
             (d_D(i)*sin(phi_rad(i)+alpha_i_rad(i))));
    d_Q(i) = r(i)*((d_L(i)*sin(phi_rad(i)+alpha_i_rad(i)))+(d_D(i)*cos...
             (phi_rad(i)+alpha_i_rad(i))));
    d_P(i) = Omega_x_r(i)*((d_L(i)*sin(phi_rad(i)+alpha_i_rad(i)))+...
             (d_D(i)*cos(phi_rad(i)+alpha_i_rad(i))));
end

%Total values
Thrust_lbf = n_blades*sum(d_T)
Torque_ft_lbf = n_blades*sum(d_Q)
Power_lb_fts = n_blades*sum(d_P)
Power_hp = (n_blades*sum(d_P))/550

%Coefficients
C_P = Power_lb_fts/(rho(alt_op)*(n^3)*((Dia_prop/12)^5))
C_T = Thrust_lbf/(rho(alt_op)*(n^2)*((Dia_prop/12)^4))
C_Q = Torque_ft_lbf/(rho(alt_op)*(n^2)*((Dia_prop/12)^5))

%prop efficiency calculation
J = V_0_fts/(n*(Dia_prop/12))
eeta_p = J*(C_T/C_P)
