%% README
% Author: Wasif Islam, Nhat Dang (02-20-2022)
% Function: [payloadFOA_V3]: Calculate Payload SV,Cost FOA
% Dependencies: insCost, arcGen
% Input: [payArch] = String array containing architecture type
% Output: [payloadSV, payloadCost] = Outputs payload science value and cost
% respectively

function [payloadSV, payloadCost] = payloadFOA_V3(payArch)
%% Define Data

% Value Format: [{1}Mass(kg); {2}Power(W); {3}Volume(cm^3); {4}OBJ; {5}Data
% Rate(kbps); {6}Design Life(months)]

if payArch ~= "EUVI only"
    arcArr = arcGen(payArch);               % Instrument Parameters
    arcSize = size(arcArr);                 % Parameter Array Size
else
end

%% FOA SV Calculation

% Defining Reference Value: (Remote Sensing Data Set)
rSense = arcGen("Remote Sensing");      % Remote Sensing Data Set
rSize = size(rSense);                   % Array Size
refDes = zeros(rSize(1),1);
for i = 1:rSize(1)
    if (i == 4) || (i == 6)
        sVal = max(rSense(i,:));
    else
        sVal = sum(rSense(i,:));
    end
    
    refDes(i) = sVal;
end

% Calculating SV Score
svWeight = [-0.25; -0.10; -0.05; 0.40; 0.10; .10];
if payArch == "EUVI only"
    payloadSV = 34.41;
elseif (payArch ~= "Single Objective") && (payArch ~= "Single+2nd Objective")   % For Calculating Non-Objective Scores
    stdScore = zeros(arcSize);
    wghtScore = zeros(arcSize);
    preFOA = zeros(1, arcSize(2));
    for i = 1:arcSize(2)
        stdScore(:,i) = arcArr(:,i) ./ refDes;
        wghtScore(:,i) = stdScore(:,i) .* svWeight;
        preFOA(i) = sum(wghtScore(1:arcSize(1)-1,i))*100;                       % Weird Row Indexing to Remove Design Life From Equation
    end
    
    FOA = sum(preFOA) - (sum(stdScore(4,:)) - max(stdScore(4,:))) * svWeight(4) * 100;
    payloadSV = FOA;
    
else
    soID = 1:6;         % Science Objective 1-6
    ID = {[1:4, 6],[1:5],[2:3, 5:8],[1:3, 6:9],[1, 3:5],[1:3, 5:9]};            % Science Objective ID
    
    % Redefined From Above
    stdScore = zeros(arcSize);
    wghtScore = zeros(arcSize);
    preFOA = zeros(1, arcSize(2));
    for i = 1:arcSize(2)
        stdScore(:,i) = arcArr(:,i) ./ refDes;
        wghtScore(:,i) = stdScore(:,i) .* svWeight;
        preFOA(i) = sum(wghtScore(1:arcSize(1)-1,i))*100;                       % Weird Row Indexing to Remove Design Life From Equation
    end
    
    soAVG = zeros(length(soID),1);
    for i = soID
        avgVar = sum(preFOA(ID{i})) / length(ID{i});
        soAVG(i) = avgVar;
    end
    
    if payArch == "Single Objective"
        FOA = mean(soAVG);
        payloadSV = FOA;
    else
        FOA = mean(soAVG*1.1);
        payloadSV = FOA;
    end
    
end

%% FOA Cost Calculation

% Instrument Cost:["COR", "EUVI", "TSI", "UVS", "SW", "EPP", "RPW", "DSI", "MAG"]
iCost = insCost();                          
archID = {[1,8,2,3,4], [9,5,6,7]};  %Instrument ID for Cost Summation
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
            

end