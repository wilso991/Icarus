function [finalInclination, deltaVReq] = gravityAssist(target,vInfIn,inclination)
% Author: Carson Ohland
% Date: 02-13-2022
% Function: function [FinalInclination, DeltaVReq] = GravityAssist(inclination,targetBody)
% Purpose: Calculate final inclination for a given initial inclination and
% gravity assist body
% Input: target (struct with .SMA (km), GM (km^3 s^-2), and .Radius (km)),
% vInf the relative velocity at the target planet, initialEncounter, a
% boolean representing whether this is the initial encounter with the
% planet.


sunGM = 1.327124400e11; % Sun gravitational parameter
vP = sqrt(sunGM/target.SMA); % Planet Velocity

if vInfIn
    vInf = vInfIn;
else
    vInf = vP*sqrt(3 - 3^(1/4) - 2*sqrt(2-4^(1/3))*cosd(inclination));
end

% If this is the initial assist, calculate the maximum inclination from the
% first assist based on the maximum achievable vInf. Otherwise, calculate
% the maximum inclination for a half-period orbit encounter or a
% synchronous orbit encounter.
if vInfIn
    vInfRange = linspace(0,vInf,1000); % Possible relative velocities
    finalInclinations = asind(vInfRange/vP.*sind(2*asind(target.GM./(target.GM+target.Radius*vInfRange.^2)))); % Possible final inclinations
    finalInclination = max(finalInclinations); % The chosen maximum final inclination
    if finalInclination > 75
        finalInclination = min(finalInclinations(finalInclinations > 75));
    end
    vInf = vInfRange(finalInclinations == finalInclination); % The corresponding input relative velocity
else % This triggers if this is a subsequent encounter (half-period or synchronous)
    finalInclination = asind(vInf/vP);
end

% If the inclination has imaginary components, set inclination to 90
% degrees.
if imag(finalInclination)
    finalInclination = 90;
end

% Calculate the final velocity of the spacecraft (away from target planet)
vF = abs((2*vP*cosd(finalInclination) - sqrt(2)*sqrt(vP^2*cosd(2*finalInclination) - vP^2 + 2*vInf^2))/2);

% Calculate the required deltaV to remain in the orbit or to head to 
%if finalInclination > 75 || finalInclination <= 53

deltaVReq = abs(vF - sqrt(2-4^(1/3))*vP);


%else
%     deltaVReq = abs(vP - vF);
%     vInf = vP*sqrt(2-2*cosd(finalInclination));
% end

end