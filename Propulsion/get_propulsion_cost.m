function [propulsion_cost_noncer,propulsion_cost_cer,propulsion_cost_est] = get_propulsion_cost(propulsion)
% Author: Alec Schmidt and Elliot Davidson
% Date: 02-19-2022
% Function: [propulsion_cost_noncer,propulsion_cost_cer,propulsion_cost_est] = get_propulsion_cost(propulsion)
% Purpose: Calculate costs of listed propulsion systems. 
%% Chemical

%Monopropellant
if isequal(propulsion, 'Chemical')
    m = 1.5; %kg

    propulsion_cost_noncer = 1500000*m;
    propulsion_cost_cer = 33000*m;
    propulsion_cost_est = 441000*m;
end

%Bipropellant
if isequal(propulsion, 'Hybrid')
    m = 79.1; %kg

    propulsion_cost_noncer = 1500000*m;
    propulsion_cost_cer = 33000*m;
    propulsion_cost_est = 441000*m;    
end

%% Solar Sail

if isequal(propulsion, 'Solar Sail')
    m = 22; %kg

    propulsion_cost_noncer = 1500000*m;
    propulsion_cost_cer = 33000*m;
    propulsion_cost_est = 441000*m;    
end

%% Electric Propulsion

if isequal(propulsion, 'Ion Propulsion')
    m = 8.1; %kg

    propulsion_cost_noncer = 1500000*m;
    propulsion_cost_cer = 33000*m;
    propulsion_cost_est = 441000*m;    
end

%% Nuclear Thermal Propulsion

if isequal(propulsion, 'NTR')
    m = 1.5; %kg
    
    propulsion_cost_noncer = 1500000*m;
    propulsion_cost_cer = 33000*m;
    propulsion_cost_est = 441000*m;    
end