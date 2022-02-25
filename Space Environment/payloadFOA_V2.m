function [payloadScore] = payloadFOA_V2(architecture)
% Modified to work with the rest of the code by Carson Ohland

%% Initialized database
% Input each equipment data in the form [mass(kg); power(W); volume(cm^3); objectives; data rate(kbps)]
dsi = [25; 37; 6000; 5; 75; 49.3];
cor  = [10; 15; 1696; 5; 40; 49.3];
euvi = [10; 12; 23120; 6; 40; 49.3];
tsi = [7; 14; 2000; 3; 0.4; 49.3];
uvs = [15; 22; 4712; 4; 10; 49.3];
mag = [1.5; 2.5; 1000; 4; 0.6; 49.3];
sw = [10; 15; 13500; 3; 0.2; 49.3];
epp = [9; 9; 6500; 3; 1; 49.3];
rpw = [10; 15; 10603; 2; 5; 49.3];

% Create combined payload array and establish reference value for each parameter
remote_sensing = [dsi cor euvi tsi uvs];
in_situ = [mag sw epp rpw];
payload_stat = [remote_sensing in_situ];

%% Calculating FOA score
% Initialize score array
std_score = zeros(6,9);
weight_SVscore = zeros(6,9);
equipment_SV = zeros(1,9);

% Establish reference design parameter and parameter weights
ref_design = [sum(remote_sensing(1,:)); sum(remote_sensing(2,:)); sum(remote_sensing(3,:)); max(remote_sensing(4,:)); sum(remote_sensing(5,:)); max(remote_sensing(6,:))]; 
SV_weight = [-0.25; -0.10; -0.05; 0.40; 0.10; .10];

% Calculate weighted score array
for index = 1:6
    std_score(index,:) = payload_stat(index,:) ./ ref_design(index);
    weight_SVscore(index,:) = std_score(index,:) .* SV_weight(index);
end

weight_SVscore(6,:) = 0;            % Design Life SV Score Set to Zero Per Excel


% Calculate total weighted score per equipments
for index2 = 1:9
    equipment_SV(index2) = 100 * sum(weight_SVscore(:,index2));
end

%% Updated SO/SV Calculations
% Note: Still Need to Update FOA with Cost FOA calculation. Will have to be
% completed over weekend

rSensing = 1:5;         % Remote Sensing Units
inSitu = 6:9;           % In-Situ Units
all = 1:9;              % Remote Sensing + In-Situ Units

% Science Objective ID:

soID = 1:6;     % Science Objectives 1-6
% Note: Science Objective IDs and their descriptions are listed in Excel FOA
ID= {[1:4, 6],[1:5],[2:3, 5:8],[1:3, 6:9],[1, 3:5],[1:3, 5:9]};     % Science Objective ID
for i = soID
    avgVar = 0;
    for b = ID{i}
        avgVar = avgVar + equipment_SV(b);
    end
    avgVar = avgVar / (length(ID{i}));
    soAVG(i) = avgVar;
end

soAVG2 = 1.25*soAVG;

% Remote Sensing Only/ In-Situ Only/ All Instruments

rSense = sum(equipment_SV(rSensing));
inSit = sum(equipment_SV(inSitu));
allIns = sum(equipment_SV(all));
obVal = std_score(4,:);
intVal_rS = (sum(obVal(rSensing)) - max(obVal(rSensing)))* SV_weight(4) * 100;
intVal_iS = (sum(obVal(inSitu)) - max(obVal(inSitu)))* SV_weight(4) * 100;
intVal_aI = (sum(obVal(all)) - max(obVal)) * SV_weight(4) * 100;
allInsFOA = allIns - intVal_aI;
rSenseFOA = rSense - intVal_rS;
inSituFOA = inSit - intVal_iS;

% Single Objective/ Single + 2nd
singleFOA = mean(soAVG);
singleTwoFOA = mean(soAVG2);

% Outputs
payload_SV = [rSenseFOA, inSituFOA, allInsFOA, singleFOA, singleTwoFOA];
payload_cost = zeros(1,6);      %Placeholder

% Output score based on input architecture
if strcmp(architecture.payload,'Remote Sensing')
    payloadScore = 1.04;
elseif strcmp(architecture.payload, 'In-situ')
    payloadScore = 0.46;
elseif strcmp(architecture.payload, 'All Payload')
    payloadScore = 1.64;
elseif strcmp(architecture.payload, 'Single Objective')
    payloadScore = 0.23;
elseif strcmp(architecture.payload, 'Single+2nd Objective')
    payloadScore = 0.26;
else
    payloadScore = 0.34;
end

% Print Statement SV FOA:

% fprintf("\nPayload SV FOA Scores:\n")
% fprintf("\nRemote Sensing Only: %.4f\n", rSenseFOA)
% fprintf("In-Situ Only: %.4f\n", inSituFOA)
% fprintf("All Instrument Payload: %.4f\n", allInsFOA)
% fprintf("Single Science Objective: %.4f\n", singleFOA)
% fprintf("Single + 2nd Science Objective: %.4f\n", singleTwoFOA)

%% Commented Out
% Calculate science objective (SO) SV score
%SO_SV = [sum(equipment_SV(1,1:4)) + sum(equipment_SV(1,6)), sum(equipment_SV(1,1:5)), sum(equipment_SV(1,2:3)) + sum(equipment_SV(1,5:8)), sum(equipment_SV(1,1:3)) + sum(equipment_SV(1,6:9)), sum(equipment_SV(1,1)) + sum(equipment_SV(1,3:5)), sum(equipment_SV(1,1:3)) + sum(equipment_SV(1,5:9))];

% Calculate payload FOA score
%payload_SV = [sum(equipment_SV(1:5)) sum(equipment_SV(6:9)) sum(equipment_SV) mean(SO_SV) 1.25*mean(SO_SV) equipment_SV(1,3)];
%payload_cost = zeros(1,6); % placeholder

end