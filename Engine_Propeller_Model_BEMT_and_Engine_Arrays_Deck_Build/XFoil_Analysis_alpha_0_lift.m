function [aoa_0_lift, cd] = XFoil_Analysis_alpha_0_lift(mach, Re_number, cl, airfoil_dat_file,...
                    Xtrip_c_top, Xtrip_c_bottom, Ncrit, vacc)


    %% Writing XFoil Input File

    fid = fopen("xfoil_alpha_0_lift.in", 'w');

    fprintf(fid, "load %s\n",airfoil_dat_file);
    fprintf(fid, "pane\n");
    fprintf(fid, "ppar\n");
    fprintf(fid, "N\n");
    fprintf(fid, "400\n");
    fprintf(fid, "\n");
    fprintf(fid, "\n");
    fprintf(fid, "pane\n");
    fprintf(fid, "oper\n");
    fprintf(fid, "visc %f\n",Re_number);
    fprintf(fid, "mach %f\n",mach);
    fprintf(fid, "iter\n");
    fprintf(fid, "600\n");
    fprintf(fid, "vpar\n");
    fprintf(fid, "xtr\n");
    fprintf(fid, "%f\n",Xtrip_c_top);
    fprintf(fid, "%f\n",Xtrip_c_bottom);
    fprintf(fid, "N\n");
    fprintf(fid, "%f\n",Ncrit);
    fprintf(fid, "vacc\n");
    fprintf(fid, "%f\n", vacc);
    fprintf(fid, "\n");
    fprintf(fid, "pacc\n");
    fprintf(fid, "\n");
    fprintf(fid, "\n");
    fprintf(fid, "cl %f\n", cl);
    fprintf(fid, "cpwr cp_values_alpha_0_lift.txt\n");
    fprintf(fid, "pwrt\n");
    fprintf(fid, "xfoil_alpha_0_lift.out\n");
    fprintf(fid, "\n");
    fprintf(fid, "quit\n");

    fclose(fid);

    %% Executing XFoil
    command = "xfoil.exe < xfoil_alpha_0_lift.in";
    system(command)
    
    %% Reading XFoil Outputs
    
    data_start = false;
    skip_line_after_data_start = false;
    
    fid = fopen("xfoil_alpha_0_lift.out", "r");
    
    tline = fgetl(fid);
    while ischar(tline)
        
        if length(tline) > 43 %why this?
            if tline(4:24)=="alpha    CL        CD"
                data_start = true;
                tline = fgetl(fid);
                continue
            end
        end
        if data_start
            skip_line_after_data_start = true;
            data_start = false;     % not required
            tline = fgetl(fid);
            continue
        end
        if skip_line_after_data_start
            aoa_0_lift = str2double(tline(3:8));
%             cl = str2double(tline(11:17));
            cd = str2double(tline(21:27));
        end
        tline = fgetl(fid);
    end
    
    fclose(fid);
    
    
end