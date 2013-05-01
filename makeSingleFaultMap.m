function [byteER, faultMap] = makeSingleFaultMap(data, rows, cols)


% makeSingleFaultMap
%
% Author: Mark Gottscho
% Email: mgottscho@ucla.edu
% UCLA NanoCAD Lab
% 2013
%
% Use this function to generate a single byte error rate for a single data
% set (voltage). It also outputs a single fault map for the given data from
% a single run and single data set (voltage).
%
% ARGUMENTS:
%   data
%       2D matrix. Each row is a different march test element. Odd columns
%       are raw addresses, while even columns are fault codes. The code
%       assumes that addresses are in word (32-bit, or 4 byte) granularity,
%       while being byte-addressable. Thus, fault codes range from 0-15
%       (b0000-b1111) representing detection of a fault in each byte of the
%       word.
%   rows
%       number of rows tested (for full 8 kB bank, this should be 2048)
%   cols
%       number of cols tested, byte granularity (this should be 4)
%
% RETURN VALUES:
%   byteER
%       scalar byte-wise error rate
%   faultMap
%       rows x cols 2D matrix, where each element
%       is a 0 if no fault was detected, and a 1 if a fault was detected.
%       Note that the matrix does not store what voltage each data set was
%       computed for.


numMarchElements = 5;
wordSize = 4;


% Extract addresses and faults
addresses = data(1,1:2:size(data,2)-1); % Get appropriate addresses for the bank
faults = data(1:numMarchElements,2:2:size(data,2));

errorCount = 0;

% Construct fault lookup table for bank 0
faultLookupTable = containers.Map({addresses(1)},{faults(1,1)}); % Initialize the fault map for bank 0 with the first key-value pair
for n = 1 : size(addresses,2)
   faultLookupTable(addresses(n)) = 0; % Initialize 
end

for m = 1 : size(faults,1) % Iterate over each march element for the selected SRAM bank
    for n = 1 : size(addresses,2) % Iterate over each address
       faultLookupTable(addresses(n)) = bitor(faultLookupTable(addresses(n)),faults(m,n)); % Bitwise-OR the fault codes for the given address. This will make sure we capture the results from each march element
    end
end

% Generate 2D fault map
faultMap = zeros(rows,cols);
faultValue = 0;

for m = 1 : rows
   for n = 1 : cols/wordSize
        faultValue = faultLookupTable(addresses((m-1)*cols/wordSize+n));
        if bitand(faultValue, 1) > 0 % Check byte0
            errorCount = errorCount + 1;
            faultMap(m,(n-1)*wordSize+1) = 1;
        end 
        if bitand(faultValue, 2) > 0 % Check byte1
            errorCount = errorCount + 1;
            faultMap(m,(n-1)*wordSize+2) = 1;
        end 
        if bitand(faultValue, 4) > 0 % Check byte2
            errorCount = errorCount + 1;
            faultMap(m,(n-1)*wordSize+3) = 1;
        end 
        if bitand(faultValue, 8) > 0 % Check byte3
            errorCount = errorCount + 1;
            faultMap(m,(n-1)*wordSize+4) = 1;
        end 
   end
end


byteER = errorCount / rows*cols;