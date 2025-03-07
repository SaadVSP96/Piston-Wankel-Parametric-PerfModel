%attempting to plot the saved data
clc;clear variables;close all
%Loading in presaved data
load('reupdated_V_and_Pe.mat')
V_4000 = V_mat(:, 4)*0.868976; %MPH to Knots
eff_4000= Pe_mat(:,4);

V_5000 = V_mat(:, 5)*0.868976;
eff_5000= Pe_mat(:,5);

V_6000 = V_mat(:, 6)*0.868976;
eff_6000= Pe_mat(:,6);

V_7000 = V_mat(:, 7)*0.868976;
eff_7000= Pe_mat(:,7);

V_8000 = V_mat(:,8)*0.868976;
eff_8000= Pe_mat(:,8);

V_9000 = V_mat(:,9)*0.868976;
eff_9000= Pe_mat(:,9);

%using extrapolation in excel
figure()
plot(V_4000,eff_4000,V_5000,eff_5000,V_6000,eff_6000,V_7000,eff_7000,V_8000,eff_8000,V_9000,eff_9000 ,'LineWidth',2); 
xlabel('Velocity(knots)','FontSize',14,'FontWeight','bold','Color','k');
ylabel('Efficiency','FontSize',14,'FontWeight','bold','Color','k'); 
legend('4000 RPM','5000 RPM','6000 RPM','7000 RPM','8000 RPM','9000 RPM');
title('V_{KTAS} vs eeta for prop 28 inches @ 6500ft for AR731','FontSize',14,'FontWeight','bold','Color','k');
grid on

