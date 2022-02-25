%% README
% Author: Wasif Islam, Nhat Dang (02-24-2022)
% Function: Payload Architecture Definer. Initializes Science Instrument
% Data for a Specific System Architecture
% Inputs: payArch: Payload Architecture
%         Format: String Array ["String"]
% V2 update note: add indiividual SO for each instrument and STM options

function [arcData] = arcGen_V2(payArch)

% Value Format: [{1}Mass(kg); {2}Power(W); {3}Volume(cm^3); {4:9}SO; {10} 
% Total SO; {11}Data Rate(kbps); {12}Design Life(months)]

DSI = [25; 37; 6000; 1; 1; 0; 1; 1; 1; 5; 75; 49.3];
COR  = [10; 15; 1696; 1; 1; 1; 1; 0; 1; 5; 40; 49.3];
EUVI = [10; 12; 23120; 1; 1; 1; 1; 1; 1; 6; 40; 49.3];
TSI = [7; 14; 2000; 1; 1; 0; 0; 1; 0; 3; 0.4; 49.3];
UVS = [15; 22; 4712; 0; 1; 1; 0; 1; 1; 4; 10; 49.3];
MAG = [1.5; 2.5; 1000; 1; 0; 1; 1; 0; 1; 4; 0.6; 49.3];
SW = [10; 15; 13500; 0; 0; 1; 1; 0; 1; 3; 0.2; 49.3];
EPP = [9; 9; 6500; 0; 0; 1; 1; 0; 1; 3; 1; 49.3];
RPW = [10; 15; 10603; 0; 0; 0; 1; 0; 1; 2; 5; 49.3];

if payArch == "Remote Sensing"
    arcData = [DSI, COR, EUVI, TSI, UVS];
    
elseif payArch == "In-situ"
    arcData = [MAG, SW, EPP, RPW];
    
elseif payArch == "All Payload"
    arcData = [DSI, COR, EUVI, TSI, UVS, MAG, SW, EPP, RPW];
    
elseif payArch == ("Single Objective") || (payArch == "Single+2nd Objective")
    arcData = [DSI, COR, EUVI, TSI, UVS, MAG, SW, EPP, RPW];
    
elseif payArch == ("DSI+UVS")
    arcData = [DSI UVS];
    
elseif payArch == ["MAG+COR+EPP"]
    arcData = [MAG COR EPP];
    
end

end