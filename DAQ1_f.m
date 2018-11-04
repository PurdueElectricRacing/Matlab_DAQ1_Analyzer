function DAQ1_f( log_file )
    %DAQ1.m
    %Brad Smrdel
    %Processes data taken from RPI logging as csv and converts to graphs, plots
    delete *.csv;
    
    parse_script = 'parser.py'; 
    system(strjoin({'python', parse_script, log_file}, ' ')); %file is parsed into 7 files
    %dd-mm-yyyy
    
    csv_names = dir('*.csv');
    csv_names = {csv_names.name};
    accel_x = [0, 0];
    accel_y = [0, 0];
    accel_z = [0, 0];
    gyro_x = [0, 0];
    gyro_y = [0, 0];
    gyro_z = [0, 0];
    bms_curr = [0, 0];
    bms_volt = [0, 0];
    bms_soc = [0, 0];
    steer = [0, 0];
    plot_accel = 1;
    plot_gyro = 1;
    plot_bms = 1;
    plot_steer = 1;
    %Read in csv files generated by Python Script
    try
        accel_x = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'acc_x'))))));
        size_x_accel = size(accel_x);
    catch
       fprintf('Empty file Accel X\n');
       size_x_accel = [intmax, intmax];
       plot_accel = 0;
    end
    try
        accel_y = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'acc_y'))))));
        size_y_accel  = size(accel_y);
    catch
       fprintf('Empty file Accel Y\n');
       size_y_accel = [intmax, intmax];
       plot_accel = 0;
    end
    try
        accel_z = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'acc_z'))))));
        size_z_accel = size(accel_z);
    catch
       fprintf('Empty file Accel Z\n');
       size_z_accel = [intmax, intmax];
       plot_accel = 0;
    end
    try
        gyro_x = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'gyro_x'))))));
        size_x_gyro  = size(gyro_x);
    catch
       fprintf('Empty file Gyro x\n');
       size_x_gyro = [intmax, intmax];
       plot_gyro = 0;
    end
    try
        gyro_y = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'gyro_y'))))));
        size_y_gyro  = size(gyro_y);
    catch
       fprintf('Empty file Gyro Y\n');
       size_y_gyro = [intmax, intmax];
       plot_gyro = 0;
    end
    try
        gyro_z = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'gyro_z'))))));
        size_z_gyro  = size(gyro_z);
    catch
        fprintf('Empty file Gyro z\n');
        size_z_gyro = [intmax, intmax];
        plot_gyro = 0;
    end
    try
        bms_curr = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'bms_curr'))))));
        size_bms_curr = size(bms_curr);
    catch
       fprintf('Empty file Current\n');
       size_bms_curr = [intmax,intmax];
        plot_bms = 0;
    end
    try
        bms_volt = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'bms_volt'))))));
        size_bms_volt= size(bms_volt);
    catch
       fprintf('Empty file Volt\n');
       size_bms_volt= [intmax, intmax];
       plot_bms = 0;
    end
    try
        bms_soc = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'bms_soc'))))));
        size_bms_soc = size(bms_soc);
    catch
       fprintf('Empty file SOC\n');
       size_bms_soc = [intmax, intmax];
       plot_bms = 0;
    end
    try
        steer = csvread(cell2mat(csv_names(find(~cellfun(@isempty, strfind(csv_names, 'steer'))))));
    catch
       fprintf('Empty file Steer\n');
       plot_steer = 0;    
    end
    %Convert Accel to g's (the 0.122 taken from Chris's IMU code)
    accel_x(:,2) = accel_x(:,2) * 0.122 / 1000;
    accel_y(:,2) = accel_y(:,2) * 0.122 / 1000;
    accel_z(:,2) = accel_z(:,2) * 0.122 / 1000;

    %Convert Gyro to Degrees (the 8.75 taken from Chris's IMU code)
    gyro_x(:,2) = gyro_x(:,2) * 8.75 / 1000;
    gyro_y(:,2) = gyro_y(:,2) * 8.75 / 1000;
    gyro_z(:,2) = gyro_z(:,2) * 8.75 / 1000;

    %Convert BMS Current to acutal Current (divide by 10)
    bms_curr(:, 2) = bms_curr(:,2) * .1;
    
    %Convert BMS Voltage to acutal Voltage (divide by 10)
    bms_volt(:, 2) = bms_volt(:,2) * .1;
    
    %Convert BMS SOC to actual SOC (each number is half a percent)
    bms_soc(:,2) = bms_soc(:,2) * .5;
   
    %Steering angle degree conversion being done in python script

    %Should be: +X forward, +Y left, +Z up for referencing car direction
    %Currently is: +X left, +Y rear, +Z up on DAQ1 board
    %Format to reflect car is sensor_direction_car
    gyro_x_car = gyro_y(:,2) * -1;
    gyro_y_car = gyro_x(:,2);
    gyro_z_car = gyro_z(:,2);
    accel_x_car = accel_y(:,2) * -1;
    accel_y_car = accel_x(:,2);
    accel_z_car = accel_z(:,2);
    
    min_size = min([size_x_accel(1), size_y_accel(1), ...
        size_z_accel(1), size_x_gyro(1), size_y_gyro(1)...
        , size_z_gyro(1), size_bms_curr(1), size_bms_volt(1),...
        size_bms_soc(1)]);
    
    %subplot(3,2,1); %Accel Plot
    if (plot_accel)
        figure(1);
        hold on;
        plot(accel_x(1:min_size,1) / 1000, accel_x_car(1:min_size));
        hold on;
        plot(accel_y(1:min_size,1) / 1000, accel_y_car(1:min_size));
        hold on;
        plot(accel_z(1:min_size,1) / 1000, accel_z_car(1:min_size));
        grid on;
        title('Acceleration Plot');
        xlabel('Time [seconds]');
        ylabel('g');
        legend('X', 'Y', 'Z');
        ylim([-4, 4]);
    end
    %subplot(3,1,2); %Gyro Plot
    if (plot_gyro)
        figure(2);
        hold on;
        plot(gyro_x(1:min_size,1) / 1000, gyro_x_car(1:min_size));
        hold on;
        plot(gyro_y(1:min_size,1) / 1000, gyro_y_car(1:min_size));
        hold on;
        plot(gyro_z(1:min_size,1) / 1000, gyro_z_car(1:min_size));
        grid on;
        title('Gyroscope Plot');
        xlabel('Time [seconds]');
        ylabel('Degrees Per Second');
        legend('X', 'Y', 'Z');
        ylim([-245, 245]);
    end
    
    %subplot(3,1,2); %BMS Current
    if (plot_bms)
        figure(3);
        plot(bms_curr(1:min_size,1) / 1000, bms_curr(1:min_size, 2));
        grid on;
        title('BMS Current');
        xlabel('Time [seconds]');
        ylabel('Current in Amps');

        figure(4);
        plot(bms_volt(1:min_size,1) / 1000, bms_volt(1:min_size, 2));
        grid on;
        title('BMS Voltage');
        xlabel('Time [seconds]');
        ylabel('Volts (v)');
        ylim([0, 320]);

        figure(5);
        plot(bms_soc(1:min_size,1) / 1000, bms_soc(1:min_size, 2));
        grid on;
        title('BMS SOC');
        xlabel('Time [seconds]');
        ylabel('SOC in %');
        ylim([0, 100]);
    end

    %subplot(3,1,3); %Steering Angle Plot
    if (plot_steer)
        figure(6);
        steer_deg = steer(:,2) * (70 +76) -76;
        plot(steer(:,1) / 1000, steer_deg);
        grid on;
        title('Steering Angle Plot');
        xlabel('Time [seconds]');
        ylabel('Degrees [+ Left, - Right]');
        ylim([-80, 80]); %TODO confirm actual values
    end
end

