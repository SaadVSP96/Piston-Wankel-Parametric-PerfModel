function y = linear_interpolation(temp_rpm_array, temp_efficiency_array, rpm_ps)

    x1 = temp_rpm_array(1);
    y1 = temp_efficiency_array(1);
    x2 = temp_rpm_array(2);
    y2 = temp_efficiency_array(2);
    x = rpm_ps;
    
    y = y1 + (x - x1) * ((y2 - y1) / (x2 - x1));
    
end