function [Power_Extracted_3D_Matrix, efficiency_3D_array] = Calculate_Power_Extracted(velocities, ...
    power_to_propeller_array, RPM_Corresponding_PS)

    [rows, cols] = size(velocities);
    [V_mat,~,Pe_mat,~,~,~,~,~, RPM_array]...
        = prop_data_read_write_function_28();

    total_mach = rows;
    total_altitudes = cols;
    total_rpms = length(RPM_Corresponding_PS);
    
    power_extracted_3D_array = nan(total_mach, total_altitudes, total_rpms);
    efficiency_3D_array = nan(total_mach, total_altitudes, total_rpms);
    
    for i = 1 : total_mach
        for j = 1 : total_altitudes
            speed = velocities(i, j);
            for k = 1 : total_rpms
                rpm_ps = RPM_Corresponding_PS(k);
                power_to_propeller = power_to_propeller_array(k, j);

                rpm_index_low_array = find(rpm_ps >= RPM_array);
                rpm_index_low = rpm_index_low_array(end);
                rpm_low = RPM_array(rpm_index_low);

                if length(RPM_array) == rpm_index_low
                    rpm_low = RPM_array(rpm_index_low - 1);
                    rpm_high = RPM_array(rpm_index_low);
                    velocity_low_rpm_array = V_mat(:, rpm_index_low-1);
                    efficiency_low_rpm_array = Pe_mat(:, rpm_index_low-1);
                    velocity_high_rpm_array = V_mat(:, rpm_index_low);
                    efficiency_high_rpm_array = Pe_mat(:, rpm_index_low);
                else
                    rpm_index_high_array = find(rpm_ps <= RPM_array);
                    rpm_index_high = rpm_index_high_array(1);
                    rpm_high = RPM_array(rpm_index_high);
                    velocity_low_rpm_array = V_mat(:, rpm_index_low);
                    efficiency_low_rpm_array = Pe_mat(:, rpm_index_low);
                    velocity_high_rpm_array = V_mat(:, rpm_index_high);
                    efficiency_high_rpm_array = Pe_mat(:, rpm_index_high);
                end

                if (speed > velocity_low_rpm_array(end))
                    temp_velocity_extrapolation_array = [velocity_low_rpm_array(end-1) velocity_low_rpm_array(end)];
                    efficiency_low_rpm = linear_interpolation(temp_velocity_extrapolation_array, efficiency_low_rpm_array,...
                    speed);
                else
                    efficiency_low_rpm = interp1(velocity_low_rpm_array, efficiency_low_rpm_array,...
                        speed);
                end
                if (speed > velocity_high_rpm_array(end))
                    temp_velocity_extrapolation_array = [velocity_high_rpm_array(end-1) velocity_high_rpm_array(end)];
                    efficiency_high_rpm = linear_interpolation(temp_velocity_extrapolation_array, efficiency_high_rpm_array,...
                        speed);
                else
                    efficiency_high_rpm = interp1(velocity_high_rpm_array, efficiency_high_rpm_array,...
                        speed);
                end

%                 if (isnan(efficiency_low_rpm_array) | isnan(efficiency_high_rpm))
%                     disp("Warning: Mismatch in Propeller Data and Given Inputs")
%                 end
                
                if (efficiency_low_rpm == efficiency_high_rpm)
                    efficiency = efficiency_low_rpm;
                else
                    temp_rpm_array = [rpm_low rpm_high];
                    temp_efficiency_array = [efficiency_low_rpm efficiency_high_rpm];
%                     efficiency = interp1(temp_rpm_array, temp_efficiency_array, rpm_ps);
                    efficiency = linear_interpolation(temp_rpm_array, temp_efficiency_array, rpm_ps);
                end
                power_extracted_3D_array(i, j, k) = efficiency * power_to_propeller;
                efficiency_3D_array(i, j, k) = efficiency;
            end
        end
    end

    Power_Extracted_3D_Matrix = power_extracted_3D_array;

end