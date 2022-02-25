%% README
% Author: Wasif Islam, Nhat Dang (02-24-2022)
% Function: [payloadFOA_V4] - Calculate Payload SV,Cost FOA
% Dependencies: insCost, arcGen_V2
% Input: [payArch] = String array containing architecture type
% Output: [payloadSV, payloadCost] = Outputs payload science value and cost
% respectively
% V4 update note: add SO redundancy factor + add STM options

function [payloadSV, payloadCost] = payloadFOA_V4(payArch)
%% Define Data
% Value Format: [{1}Mass(kg); {2}Power(W); {3}Volume(cm^3); {4:9}SO; {10} 
% Total SO; {11}Data Rate(kbps); {12}Design Life(months)]

if payArch ~= "EUVI only" & payArch ~= "DSI only"
    arcArr = arcGen_V2(payArch); % Instrument Parameters
    arcSize = size(arcArr); % Parameter Array Size
else
end

%% FOA SV Calculation
% Defining reference value from 'Remote Sensing' data set
rSense = arcGen_V2("Remote Sensing"); % 'Remote Sensing' data set
rSize = size(rSense); % Array size
refDes = zeros(rSize(1),1);
for i = 1:rSize(1)
    if (i == 10) || (i == 12)
        sVal = max(rSense(i,:));
    else
        sVal = sum(rSense(i,:));
    end
    
    refDes(i) = sVal;
end

% Set up SV weights
svWeight = [-0.25; -0.10; -0.05; 0; 0; 0; 0; 0; 0; 0.40; 0.10; .10];
W_redundant = 1.00;

% Calculating reference SV score
stdScore_ref = zeros(rSize);
wghtScore_ref = zeros(rSize);
preFOA_ref = zeros(1, rSize(2));
for i = 1:rSize(2)
    stdScore_ref(:,i) = rSense(:,i) ./ refDes;
    wghtScore_ref(:,i) = stdScore_ref(:,i) .* svWeight;
    preFOA_ref(i) = sum(wghtScore_ref(1:rSize(1)-1,i)); % Weird row indexing to remove 'Design Life' from equation
end

% Calculate SO redundancy factor for reference architecture
so_parameter_ref = 6;
so_factor_ref = 1 + sqrt(W_redundant * so_parameter_ref);

sv_ref = sum(preFOA_ref) - (sum(stdScore_ref(10,:)) - max(stdScore_ref(10,:))) * svWeight(10) / so_factor_ref;

% Caluclate each option standardized SV score
if payArch == "EUVI only"
    payloadSV = 34.41 / (100 * sv_ref);
elseif payArch == "DSI only"
    payloadSV = 0.2404003 / sv_ref;
elseif (payArch ~= "Single Objective") && (payArch ~= "Single+2nd Objective") % For Calculating Non-Objective Scores
    stdScore = zeros(arcSize);
    wghtScore = zeros(arcSize);
    preFOA = zeros(1, arcSize(2));
    for i = 1:arcSize(2)
        stdScore(:,i) = arcArr(:,i) ./ refDes;
        wghtScore(:,i) = stdScore(:,i) .* svWeight;
        preFOA(i) = sum(wghtScore(1:arcSize(1)-1,i)); % Weird row indexing to remove 'Design Life' from equation
    end
    
    % Calculate SO redundancy factor
    so_sum = zeros(6,1);
    for j = 4:9
        so_sum(j - 3) = sum(arcArr(j,:)) / sum(rSense(j,:));
    end
    so_parameter = sum(so_sum);
    so_factor = 1 + sqrt(W_redundant * so_parameter);
    
    FOA = sum(preFOA) - (sum(stdScore(10,:)) - max(stdScore(10,:))) * svWeight(10) / so_factor;
    payloadSV = FOA / sv_ref;
    
else
    soID = 1:6; % Science Objective 1-6
    ID = {[1:4, 6],[1:5],[2:3, 5:8],[1:3, 6:9],[1, 3:5],[1:3, 5:9]}; % Science Objective ID
    
    % Redefined from above
    stdScore = zeros(arcSize);
    wghtScore = zeros(arcSize);
    preFOA = zeros(1, arcSize(2));
    for i = 1:arcSize(2)
        stdScore(:,i) = arcArr(:,i) ./ refDes;
        wghtScore(:,i) = stdScore(:,i) .* svWeight;
        preFOA(i) = sum(wghtScore(1:arcSize(1)-1,i)); % Weird row indexing to remove 'Design Life' from equation
    end
    
    soAVG = zeros(length(soID),1);
    for i = soID
        avgVar = sum(preFOA(ID{i})) / length(ID{i});
        soAVG(i) = avgVar;
    end
    
    if payArch == "Single Objective"
        FOA = mean(soAVG);
        payloadSV = FOA / sv_ref;
    else
        FOA = mean(soAVG*1.1);
        payloadSV = FOA / sv_ref;
    end
end

%% FOA Cost Calculation
% Instrument Cost:["COR", "EUVI", "TSI", "UVS", "SW", "EPP", "RPW", "DSI", "MAG"]
iCost = insCost();                          
archID = {[1,8,2,3,4], [9,5,6,7]};  %Instrument ID for cost summation
obID = {[8,1,2,3,9], [1,8,2,3,4], [1,2,4,9,5,6], [8,1,2,9,5,6,7], [8,2,3,4], [1,8,2,4,9,5,6,7]};

if payArch == "Remote Sensing"
    sm = 0;
    for i = archID{1}
        sm = sm + iCost(i);
    end
    payloadCost = sm;
    
elseif payArch == "In-situ"
    sm = 0;
    for i = archID{2}
        sm = sm + iCost(i);
    end
    payloadCost = sm;
    
elseif payArch == "All Payload"
    payloadCost = sum(iCost);
    
elseif payArch == "EUVI only"
    payloadCost = iCost(2);
    
else
    soCost = zeros(length(obID),1);
    for i = 1:length(obID)
        ID = obID{i};
        soCost(i) = mean(iCost(ID));
    end
    
    if payArch == "Single Objective"
        soCost = mean(soCost);
        payloadCost = soCost;
    else
        soCost2 = soCost*1.05;
        soCost2 = mean(soCost2);
        payloadCost = soCost2;
    end
end