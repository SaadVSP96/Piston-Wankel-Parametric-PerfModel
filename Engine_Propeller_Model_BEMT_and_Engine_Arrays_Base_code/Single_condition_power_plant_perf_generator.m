clc;clear;close all
% Inputs for the desired flight condition:
altitude_ft = 0;%ft
V_fwd_fts = 15;%ft/s
RPM = 4000;
Prop_dia_inch = 33;%inches
% the prop dia is kept variable while the rest of the geometry is being
% generated within the BEMT code using sets of ratios of c(r)/R, r/R. We
% are basically scaling up the geometry of a 9x5 propeller on avaiable on
% the UIUC propeller data site.
[Throttle_Percent, Power_shaft, Fuel_Flow] = Engine_Model_Data_Driven_func(RPM);
% now here is the main point of contention, if the shaft power is less than
% the power obtained for the propeller at the given condition, it would
% imply that the engine will be unable to generate the power needed to
% sustain that load  at that particular RPM and so it will have to increase
% RPM. This factor is more important for lower RPMs
[Thrust, Torque, Power, C_T, C_Q, C_P, J, eeta_p] = ...
          Prop_perf_BEMT_XFOIL_UIUC_geometry_ratios_9x5_func...
          (altitude_ft, V_fwd_fts, RPM, Prop_dia_inch);
Power_prop_hp = Power/550;