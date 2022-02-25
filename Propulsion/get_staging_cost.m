function [staging_cost] = get_staging_cost(staging)
%{
Author: Griffin Carter
Last Updated: 2/22/2022
Last Updated By: Griffin Carter

Description: Gets the cost of the selected staging option.

inputs:
- staging: Selected staging option

outputs:
- staging_cost: Estimated cost of stage in USD (Value in Feb. 2022)

Note: Base cost equations for the motors for both staging options
calculated using correlations from a paper cited in an old AAE450 report
from 2008. The spcecifics of the correlation can be found in the propulsion
team folder in the team's Google Drive. Message Griffin Carter if you have
any questions or concerns about them.

ALL MASSES ARE IN KILOGRAMS UNLESS OTHERWISE NOTED
%}

%% Define Engine Parameters & Constants
m_orbus6 = 2954.14; % [kg], inert mass of Orbus 6 engine
m_AJ10 = 1578; % [kg], inert mass of AJ10-118K engine
m_prop_orbus6 = 4755.6; % [kg], propellant mass of solid upper stage
m_prop_AJ10 = 24547; % [kg], propellant mass of chemical upper stage

cost_solid_prop = 6.53; % [$/kg], cost per kilogram of Ap/HTPB/Al solid propellant
cost_liquid_prop = 9.67; % [$/kg], cost per kilogram of LH2/LO2 propellant combination

%% Calculate Cost
if isequal(staging, 'No Additional')
    staging_cost = 0;
elseif isequal(staging, 'Chemical')
    cost_engine = 16.49E6; % Cost of engine
    cost_prop = cost_liquid_prop * m_prop_AJ10; % Total cost of propellant

    staging_cost = cost_prop + cost_engine;
elseif isequal(staging, 'Solid Rocket')
    cost_engine = 1.54E6; % Cost of engine
    cost_prop = cost_solid_prop * m_prop_orbus6; % Total cost of propellant

    staging_cost = cost_prop + cost_engine;
else
    staging_cost = 0;
    print('ERROR: No matching database strings found for staging. Check database_gen file.')
end