function [powerSourceSV, powerSourceCost] = powerSourceFOA_V1()
% Author: Wasif Islam, Nhat Dang
% Date: 02-10-2022
% Function: powerSourceFOA--> Calculate science value (SV) and cost for the power
% source of the spacecraft

%% Initialize Power Source Data

% Parameter ID: [Solar Panel, RTG, Fuel Cells]
power = [2157, 300, 620];           % Power [Watts]
mass = [340, 57, 62];               % Mass [kg]
vol = [832424, 159448, 56450];      % Volume [cm^3]
opTime = [262800, 768252, 840];     % Operation Time [Hours]
mtimeTot = 61320;                   % Total Mission Time (Baseline) [Hours]

% Source Cost: [Solar Panel, RTG, Fuel Cells]
sCost = [1211099.68; 76485293.70; 5208.0];

% Reference Value
refParam = [max(power); max(mass); max(vol); mtimeTot];
paramArray = [power; mass; vol; opTime];
svWeight = [0.5; -0.15; -.05; 0.3];

%% SV FOA Calculations

for i = 1:length(power)
    pOne = paramArray(1:3,i) ./ refParam(1:3);
    pTwo = (paramArray(4,i)-refParam(4)) ./ refParam(4);
    normP(:,i) = [pOne; pTwo];
    svPS(:,i) = (normP(:,i) .* svWeight);
    SV(i) = sum(svPS(:,i)) * 100;
end

%% Outputs

% fprintf("Power Source SV FOA Values: \n")
% fprintf("\nSolar Panel: %.4f\n", SV(1))
% fprintf("RTG: %.4f\n", SV(2))
% fprintf("Fuel Cells: %.4f\n", SV(3))

powerSourceSV = SV;
powerSourceCost = sCost;



end