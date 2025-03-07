function [V_mat,J_mat,Pe_mat,Ct_mat,Cp_mat,PWR_mat,Torque_mat,Thrust_mat, RPM_array]...
         = prop_data_read_write_function_28()
     
     filename = "PER3_28x20-4.dat";
fid = fopen(filename, 'r');         % fid is a variable that is assigned to a text file opened in read mode (same case for write, only 'r' is replaced with 'w')

tline = fgetl(fid);         % fgetl is MATLAB function to pick a line from file id (fid). Calling it again will fetch the next line

line_skip_counter = 0;
prop_rpm_found = false;

% initializing arrays to store data w.r.t rpm
RPM_array = [];
V_mat = nan(1,1);
J_mat = nan(1,1);
Pe_mat = nan(1,1);
Ct_mat = nan(1,1);
Cp_mat = nan(1,1);
PWR_mat = nan(1,1);
Torque_mat = nan(1,1);
Thrust_mat = nan(1,1);

rpm_counter = 0;
row_counter = 0;

while ischar(tline)
    if tline(10:17) == "PROP RPM"
        rpm = str2double(tline(23:36));
        RPM_array = [RPM_array rpm];
        rpm_counter = rpm_counter + 1;
        prop_rpm_found = true;
        tline = fgetl(fid);
        continue
    end
    if prop_rpm_found
        line_skip_counter = line_skip_counter + 1;
    end
    
    if line_skip_counter >= 4
        split_data = split(tline);      % splits the line w.r.t spaces
        if length(split_data) < 3
            row_counter = 0;
            line_skip_counter = 0;
            prop_rpm_found = false;
            tline = fgetl(fid);
            continue %continue restarts the loop /  goes to next loop iteration of immediate extrernal loop
            
        end
        row_counter = row_counter + 1;
        V = str2double(split_data(2));
%         J = str2double(split_data(3));
        Pe = str2double(split_data(4));
%         Ct = str2double(split_data(5));
%         Cp = str2double(split_data(6));
%         PWR = str2double(split_data(7));
%         Torque = str2double(split_data(8));
%         Thrust = str2double(split_data(9));
        
        V_mat(row_counter, rpm_counter) = V;
%         J_mat(row_counter, rpm_counter) = J;
        Pe_mat(row_counter, rpm_counter) = Pe;
%         Ct_mat(row_counter, rpm_counter) = Ct;
%         Cp_mat(row_counter, rpm_counter) = Cp;
%         PWR_mat(row_counter, rpm_counter) = PWR;
%         Torque_mat(row_counter, rpm_counter) = Torque;
%         Thrust_mat(row_counter, rpm_counter) = Thrust;     
    end   
    tline = fgetl(fid);
    
end
fclose(fid);            % closes the file


%RPM 5000

new_rpm = [8000 9000];
total_rows = 30;

for rpm = new_rpm
    max_velocities = V_mat(end, :);
    max_velocity_curve = fit(RPM_array(:), max_velocities(:), 'poly1');
    new_max_velocity = max_velocity_curve.p1*rpm + max_velocity_curve.p2;
    new_velocities_array = linspace(0, new_max_velocity, total_rows);
    
    rpm_last_two = [RPM_array(end-1) RPM_array(end)];
    vel_1 = V_mat(:,end-1);
    vel_2 = V_mat(:,end);
    eff_1 = Pe_mat(:,end-1);
    eff_2 = Pe_mat(:,end);
    %applying siple extrapolation formula
    new_efficiencies = eff_1 + (eff_2 - eff_1)*((rpm - rpm_last_two(1))/(rpm_last_two(2) - rpm_last_two(1)));
    new_velocities_array = vel_1 + (vel_2 - vel_1)*((rpm - rpm_last_two(1))/(rpm_last_two(2) - rpm_last_two(1)));
    
    V_mat = [V_mat new_velocities_array];
    Pe_mat = [Pe_mat new_efficiencies];
    RPM_array = [RPM_array rpm];
    
end

end