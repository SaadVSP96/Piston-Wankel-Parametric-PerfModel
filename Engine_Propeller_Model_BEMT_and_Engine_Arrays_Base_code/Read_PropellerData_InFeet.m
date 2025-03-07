function [r_feet, radius, chord_feet, twists] = Read_PropellerData_InFeet(filename)

    fid = fopen(filename, 'r');
    
    tline = fgetl(fid);
    
    data_start_cond = false;
    skip_lines_count = 0;
    
    station_array = [];
    chord_array = [];
    twist_array = [];
    
    while ischar(tline)
        if length(tline) > 35
            if tline(7:35) == "STATION     CHORD       PITCH"
                data_start_cond = true;
                tline = fgetl(fid);
                continue;
            end
        end
        if data_start_cond
            skip_lines_count = skip_lines_count + 1;
        end
        if skip_lines_count >= 3
            if isempty(tline)
                data_start_cond = false;
                skip_lines_count = 0;
                tline = fgetl(fid);
                continue
            end
            split_line = split(tline);

            station = str2double(split_line(2));
            station_array = [station_array station];

            chord = str2double(split_line(3));
            chord_array = [chord_array chord];
            
            twist = str2double(split_line(9));
            twist_array = [twist_array twist];
        end
        if length(tline) >= 25
            if tline(2:8) == "RADIUS:"
                radius = str2double(tline(9:16));
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);

    
    r_feet = (station_array / 12);
    chord_feet = chord_array * (1/12);
    radius = radius / 12;
    twists = twist_array;


end