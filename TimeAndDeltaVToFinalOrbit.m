function [time, deltaVReq, valid] = TimeAndDeltaVToFinalOrbit(vInfMax, architecture, timeToTarget)
% Author: Carson Ohland
% Date: 02-13-2022
% Function: function [time] = TimeToFinalOrbit(inclination, target)
% Purpose: Calculate the total time to a final orbit given a gravity assist
% target and initial inclination

time = 0;
deltaVReq = 0;
gravityassist = true;
SunGM = 1.327124400e11; % Sun gravitational parameter
deltaVAdd = 0;
inclination = 0;
valid = true;

if isnan(vInfMax) || isnan(timeToTarget)
    valid = false;
    return
end

% Define planetary constants based on target planet. SMA = semi major axis 
% (km), Radius = planetary equatorial radius (km), GM = Gravitational
% parameter (km^3/s^2)
if strcmp(architecture.gravityassist,'Direct Transfer Orbit')
    target.SMA = 149597888;
    target.Radius = 6378;
    target.GM = 3.986004e5;
    gravityassist = false;
    inclination = asind(vInfMax/2/(sqrt(SunGM/target.SMA)))*2;
elseif strcmp(architecture.gravityassist,'Jupiter')
    target.SMA = 778479000;
    target.Radius = 71492;
    target.GM = 1.266865e8;
elseif strcmp(architecture.gravityassist,'Earth')
    target.SMA = 149597888;
    target.Radius = 6378;
    target.GM = 3.986004e5;
    inclination = asind(vInfMax/2/(sqrt(SunGM/target.SMA)))*2;
    vInfMax = 0;
elseif strcmp(architecture.gravityassist,'Venus')
    target.SMA = 108210000;
    target.Radius = 6051;
    target.GM = 3.24859e5;
else
    fprintf('Problem with architecture gravity assist definition')
    return
end

% Set boolean for low thrust or coast
if strcmp(architecture.transferstrat, 'Low Thrust')
    lowthrust = true;
else
    lowthrust = false;
end


% If using a gravity assist, calculate inclination gain and time over
% initial transfer
if gravityassist
    time = time + timeToTarget;
    
    [inclination,deltaVAdd] = gravityAssist(target,vInfMax,inclination);
    deltaVReq = deltaVReq + deltaVAdd;
    
        % Calculate Inclination gain by LTT over initial Transfer arc
    if strcmp(architecture.transferstrat, 'Low Thrust')
        inclination = inclination + transferStrat(target,architecture.propulsion)/2;
    end
    
    % Gain inclination and time for the two spacecraft orbits until another gravity
    % assist is possible
    for index = 1:2
        if inclination < 75
            time = time + pi*sqrt(target.SMA^3/SunGM);
            if lowthrust
                inclination = inclination + transferStrat(target,architecture.propulsion);
            end
        end
    end
end




% Calculate added time, deltav by repeated gravity assists
while(inclination < 75)    
    if gravityassist
        [inclination, deltaVAdd]= gravityAssist(target,false,inclination);
            for index = 1:2
                if inclination < 75
                    time = time + pi*sqrt(target.SMA^3/SunGM);
                    if strcmp(architecture.transferstrat, 'Low Thrust')
                        inclination = inclination + transferStrat(target,architecture.propulsion);
                    end
                end
            end
    else
        time = time + 2*pi*sqrt(target.SMA^3/SunGM);
        inclination = inclination + transferStrat(target,architecture.propulsion);
    end
    
    deltaVReq = deltaVReq + deltaVAdd;
end