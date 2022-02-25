%% README
% Author: Wasif Islam, Nhat Dang (02-24-2022)
% Function: Output Power Source COST Value
% Inputs: [payArch] - Payload Architecture Type
% Output: [pSourceCost] - Power Source Operation Cost
% Output Format: Row Vector [Solar Panel Cost, RTG Cost] in Dollars
% V3 update note: give logarithmic average cost instead of minimum
% (payload operational) cost and STM options

function [pSourceCost] = powerSourceFOA_V3(payArch)
%% Define Data
% Data Definition: [$/Power, $/Mass, $/Vol, $/Opt-time
SP = [561.47; 3562.05; 1.45; 4.61];
RTG = [4037.0; 21247.35; 7.60; 1.58];
opWght = [0.5; 0.15; 0.05; 0.3];
rowID = [2, 1, 3, 6];
sParam = [SP, RTG]; % Build source array for enumeration

hCost = [1211099; 3769097]; % Maximum scaled power source cost [SP, RTG]

%% Calculating COST Scores
if payArch ~= "EUVI only" & payArch ~= "DSI only"
    arcArr = arcGen_V2(payArch);
    arcSize = size(arcArr);
elseif payArch == "EUVI only"
    euviARR = arcGen_V2("Remote Sensing");
    euviARR = euviARR(:,3);
elseif payArch == "DSI only"
    euviARR = arcGen_V2("Remote Sensing");
    euviARR = euviARR(:,1);
end

if payArch == "EUVI only" | payArch == "DSI only"
    sourceCost = zeros(2,1);
    for j = 1:2
        costV = opWght(1:length(opWght)-1) .* sParam(1:length(opWght)-1,j) .* euviARR(1:length(opWght)-1);
        costV(4) = opWght(4)* sParam(4,j) * euviARR(6) * 730;
        sourceCost(j) = sum(costV);
    end
    pSourceCost = sqrt(sourceCost .* hCost);
    
elseif (payArch ~= "Single Objective") && (payArch ~= "Single+2nd Objective")
    sourceCost = zeros(2,1);
    for j = 1:2
        costS = 0;
        for i = 1:length(opWght)
            if i ~= length(opWght)
                costV = opWght(i)*sParam(i,j)*sum(arcArr(rowID(i),:));
            else
                costV = opWght(i)*sParam(i,j)*max(arcArr(rowID(i),:))*730;
            end
            
            costS = costS + costV;
        end
        sourceCost(j) = costS;
    end
    pSourceCost = sqrt(sourceCost .* hCost);
    
else
    [rsSV,~] = payloadFOA_V4("Remote Sensing");
    [archSV,~] = payloadFOA_V4(payArch);
    rsPCost = powerSourceFOA_V3("Remote Sensing");
    for i = 1:length(rsPCost)
        sourceCost(i) = (archSV/rsSV) * rsPCost(i);
    end
    if payArch == "Single Objective"
        pSourceCost = sqrt(sourceCost .* hCost);
    else
        pSourceCost = 1.25 * sqrt(sourceCost .* hCost);
    end   
end