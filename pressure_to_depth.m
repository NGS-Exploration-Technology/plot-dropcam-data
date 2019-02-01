function Depth=pressure_to_depth(Pressure,Latitude)
%function Depth=pressure_to_depth(Pressure,Latitude)
%   Uses pressure depth data from 'Algorithms for computation of
%   fundamental properties of seawater' (Unesco 1983) and performs a 2d
%   spline interpolation to find the depth in meters.
%Inputs:
%   Pressure = Pressure of gauge reading in psi
%   Latitude = Latitude of pressure reading   
%
%Outputs
%   Depth = Depth in meters interpolated from table.
%
%National Geographic Society
%July 7, 2014
%Eric Berkenpas

Depth_Table=load('Depth_Table.csv');
Latitudes=[0 30 45 60 90];
Pressures=[725 1450 2900 4351 5801 7252 8702 10153 11603 13053 14504];
Depth=interp2(Latitudes,Pressures,Depth_Table,Latitude,Pressure, 'spline');