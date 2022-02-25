%% README
% Author: Wasif Islam (02-20-2022)
% Function: Output Power Source COST Value
% Inputs: [payArch] - Payload Architecture Type
% Output: [pSourceCost] - Power Source Operation Cost
% Output Format: Row Vector [Solar Panel Cost, RTG Cost] in Dollars

function [pSourceCost] = powerSourceFOA_V2(payArch)
%% Define Data

% Data Definition: [$/Power, $/Mass, $/Vol, $/Opt-time
SP = [561.47; 3562.05; 1.45; 4.61];
RTG = [4037.0; 21247.35; 7.60; 1.58];
opWght = [0.5; 0.15; 0.05; 0.3];
rowID = [2, 1, 3, 6];
sParam = [SP, RTG];                   % Build Source Array for Enumeration

hCost = [1211099, 76485293];          % Hardware Cost [SP, RTG]

%% Calculating COST Scores
if payArch ~= "EUVI only"
    arcArr = arcGen(payArch);
    arcSize = size(arcArr);
else
    euviARR = arcGen("Remote Sensing");
    euviARR = euviARR(:,3);
end

if payArch == "EUVI only"
    sourceCost = zeros(2,1);
    for j = 1:2
        costV = opWght(1:length(opWght)-1) .* sParam(1:length(opWght)-1,j) .* euviARR(1:length(opWght)-1);
        costV(4) = opWght(4)* sParam(4,j) * euviARR(6) * 730;
        sourceCost(j) = sum(costV);
    end
    pSourceCost = sourceCost;
    
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
    pSourceCost = sourceCost;
else

    [rsSV,~] = payloadFOA_V3("Remote Sensing");
    [archSV,~] = payloadFOA_V3(payArch);
    rsPCost = powerSourceFOA_V2("Remote Sensing");
    for i = 1:length(rsPCost)
        sourceCost(i) = (archSV/rsSV) * rsPCost(i);
    end
    if payArch == "Single Objective"
        pSourceCost = sourceCost;
    else
        pSourceCost = 1.25 * sourceCost;
    end
        
end

end