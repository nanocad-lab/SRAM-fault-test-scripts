function [byteER, faultAnomalies, faultMap] = automateSRAMFaultMaps(chipNum, data_directory, numDataSets, voltages, numRuns, rows, cols, numKB)

% automateSRAMFaultMaps
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu
% UCLA NanoCAD Lab
% 2013
%
% ARGUMENTS:
%   chipNum
%       numerical identifier for the chip, for plotting purposes only
%   data_directory
%       string representing relative path to the data
%       directory for this analysis, with subfolders for each run (e.g.,
%       run1, run2, run3, ...)
%   numDataSets
%       number of full passes per run (e.g. at different voltages)
%   voltages
%       vector of voltage values to be used as graph labels
%   numRuns
%       number of repetitions of the full experiment
%   rows
%       number of rows tested (for full 8 kB bank, this should be 2048)
%   cols
%       number of cols tested, byte granularity (this should be 4)
%
% RETURN VALUES:
%   byteER
%       numDataSets x numRuns 2D matrix of byte-wise error rates
%   faultAnomalies
%       numDataSets x numRuns 2D matrix of fault anomaly rates, defined as
%       the number of faults detected at this voltage level but not present
%       in the immediately lower voltage level
%   faultMap
%       rows x cols x numDataSets x numRuns 4D matrix, where each element
%       is a 0 if no fault was detected, and a 1 if a fault was detected.
%       Note that the matrix does not store what voltage each data set was
%       computed for.





% aggregate data from each run
byteER = NaN(numDataSets,numRuns);
faultAnomalies = zeros(numDataSets,numRuns);
faultMap = NaN(rows,cols,numDataSets,numRuns);

for i = 1 : numRuns
    display(['Run ' num2str(i) '...']);

    [byteER_run_i, faultAnomalies_run_i, faultMap_run_i] = makeFaultMaps([data_directory 'run' num2str(i) '/'], numDataSets, rows, cols);
    byteER(:,i) = byteER_run_i;
    faultAnomalies(:,i) = faultAnomalies_run_i;
    faultMap(:,:,:,i) = faultMap_run_i;
end


%Plot the byte error rates
figure;
hold on;
myColors = {'b-'};
errorbar(voltages, mean(byteER,2), std(byteER,0,2), myColors{1});
set(gca, 'FontSize', 12);
title(['SRAM Byte Error Rate Across ' int2str(numRuns) ' Runs, Chip ' int2str(chipNum) ', ' int2str(numKB) ' kB Tested']);
set(gca, 'FontSize', 12);
set(gca, 'xtick', voltages);
xlabel 'Voltage (mV)';
set(gca, 'FontSize', 12);
ylabel 'Byte Error Rate';
set(gca, 'FontSize', 12);
hold off;


figure;
hold on;
myColors = {'b-'};
errorbar(voltages, mean(faultAnomalies,2), std(faultAnomalies,0,2), myColors{1});
set(gca, 'FontSize', 12);
title(['Proportion of Faults Not Present in Next Lower Voltage Across ' int2str(numRuns) ' Runs, Chip ' int2str(chipNum) ', ' int2str(numKB) ' kB Tested']);
set(gca, 'FontSize', 12);
set(gca, 'xtick', voltages);
xlabel 'Voltage (mV)';
set(gca, 'FontSize', 12);
ylabel 'Anomaly Rate';
set(gca, 'FontSize', 12);
hold off;

tilefig

end

