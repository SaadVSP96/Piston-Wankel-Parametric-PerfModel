function [V_mat,J_mat,Pe_mat,Ct_mat,Cp_mat,PWR_mat,Torque_mat,Thrust_mat]...
         = prop_data_read_function(filename)
% filename = "PER3_27x13E.dat";

fid = fopen(filename, 'r');         % fid is a variable that is assigned to a text file opened in read mode (same case for write, only 'r' is replaced with 'w')

tline = fgetl(fid);         % fgetl is MATLAB function to pick a line from file id (fid). Calling it again will fetch the next line

line_skip_counter = 0;
prop_rpm_found = false;

% initializing arrays to store data w.r.t rpm
rpm_array = [];
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
        rpm_array = [rpm_array rpm];
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
            continue
        end
        row_counter = row_counter + 1;
        V = str2double(split_data(2));
        J = str2double(split_data(3));
        Pe = str2double(split_data(4));
        Ct = str2double(split_data(5));
        Cp = str2double(split_data(6));
        PWR = str2double(split_data(7));
        Torque = str2double(split_data(8));
        Thrust = str2double(split_data(9));
        
        V_mat(row_counter, rpm_counter) = V;
        J_mat(row_counter, rpm_counter) = J;
        Pe_mat(row_counter, rpm_counter) = Pe;
        Ct_mat(row_counter, rpm_counter) = Ct;
        Cp_mat(row_counter, rpm_counter) = Cp;
        PWR_mat(row_counter, rpm_counter) = PWR;
        Torque_mat(row_counter, rpm_counter) = Torque;
        Thrust_mat(row_counter, rpm_counter) = Thrust;        
    end   
    tline = fgetl(fid);
end
fclose(fid);            % closes the file
end
