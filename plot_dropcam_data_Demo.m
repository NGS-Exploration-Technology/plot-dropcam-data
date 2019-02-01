%Demonstration plots and exports a sample data file from the dropcam
%Type 'help plot_dropcam_data' to get help.

filename = 'DOEX0034_201901150519_DOD013.txt'; %Name of the file
Latitude = 64.57679; %[degrees] Specifiying Latitude can improve depth accuracy by up to 5m

[Bottom_Depth, time, Depth, Temperature, Offset] = plot_dropcam_data(filename, Latitude);

disp(['Bottom Depth = ' num2str(Bottom_Depth) ' m']);