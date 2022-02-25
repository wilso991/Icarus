function [SMA, deltaVReq] = finalOrbit(architecture)
% Author: Carson Ohland
% Date: 02-13-2022
% Function: function [FinalInclination, DeltaVReq] = finalOrbit(inclination,targetBody)
% Purpose: Calculate final semimajor axis and required deltaV to enter
% final orbit from elliptical transfer orbit.

% Set initial periapsis and apoapsis based on gravity assist
AU = 149600000; % 1 AU in km
sunGM = 1.327e11; % Sun gravitational parameter
beta = 0.0027; % Solar Sail brightness coefficient
gravityassist = true;

% Define planetary constants based on target planet. SMA = semi major axis 
% (km), Radius = planetary equatorial radius (km), GM = Gravitational
% parameter (km^3/s^2)
if strcmp(architecture.gravityassist,'Direct Transfer Orbit')
    gravityassist = false;
elseif strcmp(architecture.gravityassist,'Jupiter')
    target.SMA = 778479000;
    target.Radius = 71492;
    target.GM = 1.266865e8;
elseif strcmp(architecture.gravityassist,'Earth')
    target.SMA = 149597888;
    target.Radius = 6378;
    target.GM = 3.986004e5;
elseif strcmp(architecture.gravityassist,'Venus')
    target.SMA = 108210000;
    target.Radius = 6051;
    target.GM = 3.24859e5;
else
    fprintf('Problem with architecture gravity assist definition')
    return
end

if gravityassist
    initialPeriapsis = target.SMA*(2-4^(1/3)/4^(1/3));
    initialApoapsis = target.SMA;
else
    initialPeriapsis = AU; % Assume Earth values if no gravity assist target
    initialApoapsis = AU;
end

% Decide final periapsis based on final orbit type and gravity assist
% target
if strcmp(architecture.finalorbit,'Non-Keplerian')
    initialSMA = (initialPeriapsis + initialApoapsis)/2; % Initial Semimajor axis
    initialEcc = initialApoapsis/initialSMA-1; % Initial orbit eccentricity
    initialSLR = initialSMA*(1-initialEcc^2); % Initial semilatus rectum
    periapsis = initialSLR/(1+initialEcc*cosd(116.29)); % Find the orbital radius when above 60 latitude
elseif strcmp(architecture.finalorbit,'High Elliptical')
    if initialPeriapsis > 0.7*AU
        periapsis = min([AU, initialPeriapsis]);
    else
        periapsis = 0.75*AU;
    end
elseif strcmp(architecture.finalorbit,'Low Elliptical')
    periapsis = min([0.7*AU, initialPeriapsis]);
else
    periapsis = min([AU, initialPeriapsis]);
end

% Calculate final apoapsis based on final orbit type and gravity assist
% target
if contains(architecture.finalorbit,'Elliptical')
    apoapsis = initialApoapsis;
else
    apoapsis = periapsis;
end

SMA = (apoapsis + periapsis)/2;

% Calculate injection delta V based on initial and final periapsis /
% apoapsis
if initialApoapsis == apoapsis && initialPeriapsis == periapsis
    deltaVReq = 0;
elseif strcmp(architecture.finalorbit, 'Non-Keplerian')
    initialV = sqrt(sunGM*(2/periapsis-1/initialSMA)); % Velocity before injection burn
    initialH = sqrt(sunGM*initialSLR); % Specific angular velocity before injection burn
    initialFPA = acosd(periapsis*initialV/initialH); % Flight path angle before injection burn
    finalV = sqrt(sunGM/periapsis^3)/(1-beta)*periapsis*cosd(116.29); % Velocity after injection burn
    deltaVReq = sqrt((finalV - initialV*cosd(initialFPA))^2 + (initialV*sind(initialFPA)^2));
elseif contains(architecture.finalorbit, 'Elliptical')
    initialSMA = (initialPeriapsis + initialApoapsis)/2; % Initial Semimajor axis
    initialEcc = initialApoapsis/initialSMA-1; % Initial orbit eccentricity
    initialV = sqrt(sunGM*(1+initialEcc)/initialSMA/(1-initialEcc)); % Initial Velocity
    SMA = (periapsis + apoapsis)/2;
    Ecc = apoapsis/SMA-1;
    finalV = sqrt(sunGM*(1+Ecc)/SMA/(1-Ecc));
    deltaVReq = abs(initialV-finalV);
else
    initialSMA = (initialPeriapsis + initialApoapsis)/2; % Initial Semimajor axis
    initialV = sqrt(sunGM*(2/periapsis - 1/initialSMA));
    initialEcc = initialApoapsis/initialSMA-1; % Initial orbit eccentricity
    initialSLR = initialSMA*(1-initialEcc^2); % Initial semilatus rectum
    initialH = sqrt(sunGM*initialSLR); % Specific angular velocity before injection burn
    initialFPA = acosd(periapsis*initialV/initialH); % Flight path angle before injection burn
    finalV = sqrt(sunGM/periapsis);
    deltaVReq = abs((initialV*cosd(initialFPA) - finalV)^2 + (initialV*sind(initialFPA))^2);
end