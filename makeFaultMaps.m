function [byteER, faultAnomalies, faultMap] = makeFaultMaps(data_directory, numDataSets, rows, cols)

% makeFaultMaps
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu
% UCLA NanoCAD Lab
% 2013
%
% Use this function to generate byte error rates and fault anomalies as a
% function of data sets (voltages). It also outputs a combined fault map for all
% data sets, which can be used for further analysis.
%
% ARGUMENTS:
%   data_directory
%       string representing relative path to the data directory containing
%       separate CSV files for each data set in the run
%   numDataSets
%       number of full passes per run (e.g. at different voltages)
%   rows
%       number of rows tested (for full 8 kB bank, this should be 2048)
%   cols
%       number of cols tested, byte granularity (this should be 4)
%
% RETURN VALUES:
%   byteER
%       numDataSets x 1 column vector of byte-wise error rates
%   faultAnomalies
%       numDataSets-1 x 1 column vector of fault anomaly rates, defined as
%       the number of faults detected at this voltage level but not present
%       in the immediately lower voltage level
%   faultMap
%       rows x cols x numDataSets 3D matrix, where each element
%       is a 0 if no fault was detected, and a 1 if a fault was detected.
%       Note that the matrix does not store what voltage each data set was
%       computed for.

byteER = NaN(numDataSets,1);
faultMap = NaN(rows,cols,numDataSets);


for i = 1 : numDataSets
    display (['Analyzing fault map ' num2str(i) '...']);
    data_i = csvread([data_directory 'DATA' num2str(i-1) '.CSV'],1,2);
    [byteER_i, faultMap_i] = makeSingleFaultMap(data_i,rows,cols);

    byteER(i) = byteER_i;
    faultMap(:,:,i) = faultMap_i;
end

byteER = flipud(byteER);


% Determine the degree of fault inclusion as we move from high to low
% voltages -- i.e. faults at a voltage X, X < Y should be a superset of faults
% at Y.
faultInclusionMap = NaN(rows,cols,numDataSets-1);
for i = 1 : numDataSets-1
    faultInclusionMap(:,:,i) = faultMap(:,:,i) - faultMap(:,:,i+1); % 0 means fault at a given location was same. -1 means lower voltage had a fault that higher voltage didn't. 1 means a fault DISAPPEARED by going to lower voltage.
end


for i = 1 : numDataSets-1
    faultAnomalies(i) = sum(sum((faultInclusionMap(:,:,i) > 0)));
end

faultAnomalies = faultAnomalies';
faultAnomalies = flipud(faultAnomalies);