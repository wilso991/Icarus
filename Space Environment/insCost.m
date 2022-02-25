%% README
% Author: Wasif Islam
% Function: Payload Instrument Cost Estimator (SMAD)
% Output: [Array] --> Cost of payload architecture
%         Format: ["COR", "EUVI", "TSI", "UVS", "SW", "EPP", "RPW", "DSI",
%         "MAG"]


function [iCost] = insCost()
%% Payload Classification

% Value Format: [{1}Mass(kg); {2}Power(W); {3}Volume(cm^3); {4}OBJ; {5}Data
% Rate(kbps); {6}Design Life(months)] (Dollars)

DSI = [25; 37; 6000; 5; 75; 49.3];
COR  = [10; 15; 1696; 5; 40; 49.3];
EUVI = [10; 12; 23120; 6; 40; 49.3];
TSI = [7; 14; 2000; 3; 0.4; 49.3];
UVS = [15; 22; 4712; 4; 10; 49.3];
MAG = [1.5; 2.5; 1000; 4; 0.6; 49.3];
SW = [10; 15; 13500; 3; 0.2; 49.3];
EPP = [9; 9; 6500; 3; 1; 49.3];
RPW = [10; 15; 10603; 2; 5; 49.3];


optPlan = [COR, EUVI, TSI, UVS];           % Optical Planetary Instruments
partPay = [SW, EPP, RPW];                  % Particles Payload Instruments
fPay = [DSI, MAG];                         % Fields Payload Instruments

% Optical Planetary Instruments
for i = 1:4
    cost = 1.28*328*(optPlan(1,i)^0.426)*(optPlan(2,i)^0.414)*(optPlan(6,i)^0.375)*1000;
    optCost(i) = cost;
end

% Particles Payload Instruments
for i = 1:3
    cost = 1.28*980*(partPay(1,i)^0.327)*(partPay(2,i)^0.525)*(partPay(6,i)^0.171)*1000;
    partCost(i) = cost;
end

% Field Payload Instruments

for i = 1:2
    cost = 1.28*1130*(fPay(1,i)^0.184)*(fPay(2,i)^0.238)*(fPay(6,i)^0.274)*1000;
    fCost(i) = cost;
end

iCost = [optCost, partCost, fCost];




end