function [] = plotFaultMap(faultMap, rows, cols, figTitle, figNum)

% plotFaultMap
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu
% UCLA NanoCAD Lab
% 2013
%
% Use this function to plot a 3D graphical representaiton of a fault map
% generated for a single data set (voltage) and run.
%
% ARGUMENTS:
%   faultMap
%       rows x cols 2D matrix, where each element
%       is a 0 if no fault was detected, and a 1 if a fault was detected.
%       Note that the matrix does not store what voltage each data set was
%       computed for.
%   rows
%       number of rows tested (for full 8 kB bank, this should be 2048)
%   cols
%       number of cols tested, byte granularity (this should be 4)
%   figTitle
%       figure label
%   figNum
%       which MATLAB figure handle to use
%
% RETURN VALUES: N/A

        figure(figNum);
        ribbon(faultMap(:,:));
        set(gca, 'PlotBoxAspectRatioMode', 'manual');
        set(gca, 'PlotBoxAspectRatio', [4 32 1]);
        set(gca, 'FontSize', 12);
        title(figTitle);
        axis([0.5 cols+0.5 0.5 rows+0.5 0 1]);
        set(gca, 'FontSize', 12);
        xlabel 'Col #';
        set(gca, 'FontSize', 12);
        ylabel 'Row #';
        set(gca, 'FontSize', 12);
        zlabel 'Fault';
        set(gca, 'FontSize', 12);
        set(gca, 'ztick', [0 1]);
end

