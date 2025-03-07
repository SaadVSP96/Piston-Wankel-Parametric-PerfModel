% this is a simple engine model which assumes that RPM and throttle are
% linearly related  and not disjoint.
function [Throttle_Percent, Power_shaft, Fuel_Flow] = Engine_Model_Data_Driven_func(RPM)
% According to the DLA Specs:
% RPM range is ~1100 to ~6200 RPM, so we can make the set:
RPMs = [1100, 2000:500:6000, 6200];
% the trottle can be assumed to be 0% at 1100 and 100% at 6200
throttle = interp1([1100, 6200], [0, 100], RPMs);
% Best just use the RPM I guess :)
% Now we move on to the Shaft power, the manual states that at 6200 rpm, we
% have 18 hp, however, we don't know the same for the lower end, it is
% known that at idle RPM, the shaft power is not zero. 
% let use say that at 0 rpm, the power is 0 hp, then develop a slope of the 
% linear trend to get the power at 1100 rpm.
P_max = 18; %shaft power (hp) at 1100 rpm
slope = (P_max-0)/(RPMs(end) - 0);
P_1 = slope*RPMs(1); %shaft power (hp) at 1100 rpm
P_Shaft = interp1([1100, 6200], [P_1, P_max], RPMs);
% Next we move on to Fuel Consumption aka Fuel Flow Rate. 
% according to the data in manual we have at 2000 rpm - FC of 1.408 lb/hr
% and at 6000 rpm - FC of 12.679 lb/hr.
% to avoid the fuel flow from being linearly extrapolated to a -ve value at
% the lowest RPm of 1100, we have used a 2nd degree polynomial which fits
% the following points: X(RPMs)=[0, 2000, 6000] & Y(FF)=[0, 1.408, 12.679];
% Fuel_Flow = interp1([0, 6000], [0, 12.679], RPMs, 'linear', 'extrap')
% the polynomial was obtained from cftool
p1 =   3.523e-07;
p2 =  -5.833e-07;
p3 =  -2.933e-15;
FFR = (p1.*(RPMs.^2)) + (p2.*RPMs) + p3; %lb/hr
% once the propeller is loaded onto the shaft however, the engine will
% automatically Idle at 2500 to 3000 RPM, it is at unloaded state where it
% can sustain at 1100 rpm.
% Now interpolating between the values against the given RPM
Throttle_Percent = interp1(RPMs, throttle, RPM);
Power_shaft = interp1(RPMs, P_Shaft, RPM);
Fuel_Flow = interp1(RPMs, FFR, RPM);
end
