function [Bottom_Depth, time, Depth, Temperature, Offset] = plot_dropcam_data(filename, Latitude)
%PLOT_DROPCAM_DATA Plot dropcam data
%function [Bottom_Depth, time, Depth, Temperature, offset] = plot_dropcam_data(filename, Latitude)
%inputs:
%   filename = dropcam downloaded data file
%   Latitude = latitude needed for pressure to depth (default 45 degrees)
%
%outputs:
%   Bottom_Depth = [m] bottom depth (averaged to remove noise)
%   Time = [s] time vector
%   Depth = [m] depth vector
%   Temperature = [C] ambient temperature
%   Offset = Estimated Depth Offset (for zeroing surface pressure)
%See also PRESSURE_TO_DEPTH

%Check if Latitude supplied as parameter
if (~exist('Latitude','var'))
    warning('Latitude not defined.  Set to 45 deg');
    Latitude = 45;
end

A = load(filename);

%Extract raw data
raw_time = A(:,1);
AD_temp = A(:,9);
AD_temp_mf = median_filter(AD_temp,3);
AD_pressure = A(:,11);
AD_pressure_mf = median_filter(AD_pressure,5);
AD_pressure_mf_mm = movmean(AD_pressure_mf,10);
AD_battery = A(:,15);
AD_battery_mf = median_filter(AD_battery,3);

%Extract time in seconds
time = raw_time - min(raw_time);

%Check if data is sequential
n = length(time);
index = 1;
while (index<n)
    index = index + 1;
    if ((time(index-1)+1)~=(time(index)))
        index = n;
        warning('Data not sequential, check raw downloaded file');
    end
end

%Convert AD_temp to degreec
alpha1 = 1500;
alpha2 = 9.5;
Temperature = (AD_temp_mf - alpha1)/alpha1;

%Convert AD_pressure to m depth
Pressure = (10000/65535).*AD_pressure_mf_mm;
Depth = pressure_to_depth(Pressure, Latitude);

%Correct Depth for offset using first sample
Offset = Depth(1);
Depth = Depth-Offset;

%Calculate the final depth (average)
d_Depth_dt = Depth - circshift(Depth,1);
d_Depth_dt(1) = 0;
d_Depth_dt_mf = median_filter(d_Depth_dt, 10);
d_Depth_dt_mf_mm = movmean(d_Depth_dt_mf, 10);

%Take a moving mean of d_Depth_dt and set thresholds

Underwater_indices = find(Depth>10);
Bottom_indices = find(abs(d_Depth_dt_mf_mm(Underwater_indices)<0.4));
Diving_indices = find(abs(d_Depth_dt_mf_mm(Underwater_indices)>0.7));

Bottom_Depth = mean(Depth(Bottom_indices));
Diving_Rate = mean(d_Depth_dt(Diving_indices));

%Plot temperature and pressure versus time
figure;
subplot(2,1,1);
title_str1 = ['Depth vs. Time (bottom depth = ', num2str(Bottom_Depth), ' m '];
title_str2 = ['dive velocity = ' num2str(Diving_Rate), ' m/s)'];
plot(time,Depth);
set(gca,'Ydir','reverse')
title([title_str1 title_str2]);
grid on;
ylabel('[m]');
subplot(2,1,2);
title('Temperature vs. Depth');
plot(time,Temperature);
xlabel('Time [s]');
ylabel('[C]');

%Plot temperature depth profile
figure;
title('Temperature vs. Depth');
plot(Depth(Diving_indices),Temperature(Diving_indices), '.k');
grid on;
xlabel('Depth [m]');
ylabel('Temperature [C]');