%% Function to compare the dV's each combination of staging/launch system architectures will give us

staging = ["No Additional", "Solid Rocket", "Chemical"];
launchsystem = ["Delta IV Heavy","Ariane 5","Falcon Heavy","SLS","Starship","Proton M","Vulcan Centaur"];

options = [];

for j = 1:3
    for i = 1:7
        [options(i, j), ~] = get_initial_dV_V2(launchsystem(i), staging(j));
    end
end

writematrix(options, 'dV_data.csv')

% Rows of options matrix = Launch System Choice
% Columns of options matrix = Staging Choice

% Compiled results into a spreadsheet in the Google Drive, look in the
% propulsion sub-team folder

%% dV Comparisons using Published Payload Capabilities
% Note: This is just doing some rough estimations using published payload
% capabilities for each launch system and seeing how much the calculated
% dVs differ from our original FOA
%
% All masses in kg unless otherwise noted
% All distances in m unless otherwise noted

% Constant Parameters
r_earth = 6378E3; % Radius of earth
z_GEO = 35786E3; % Altitude of GTO orbit
mu_earth = 3.986004418E14; % Gravitational parameter of Earth, m^3/s^2

% Masses of Additional Stage Options
m_orbus6 = 2954.14; % [kg], inert mass of Orbus 6 engine
m_AJ10 = 4015.19; % [kg], inert mass of AJ10-118K engine

m_add_prop = 2717.498; % Mass of propellant for additional stage

m_add_solid = m_orbus6 + m_add_prop; % Mass of solid additional stage
m_add_chem = m_AJ10 + m_add_prop; % Mass of chemical additional stage

% Each launch system has a matrix corresponding to it in the form:
% [alt, m_payload, tot_dV, inclination]
% With one row for each altitude/orbit that has available data

% The ideal dV's are multiplied by 1.2 to account for other losses that the
% launch systems are dealing with that are not considered in this simple
% analysis

%% Delta IV Heavy X
% 200E3 alt, 28.8deg inc
v_circ_leo1_DH4 = sqrt(mu_earth / (r_earth + 200E3));
dV_inc_leo1_DH4 = 2 * v_circ_leo1_DH4 * sind(28.8/4);

% 407E3 alt, 51.6deg inc
v_circ_leo2_DH4 = sqrt(mu_earth / (r_earth + 407E3));
dV_inc_leo2_DH4 = 2 * v_circ_leo2_DH4 * sind(51.6/4);

% GEO, no inc
v_circ_geo_DH4 = sqrt(mu_earth / (r_earth + z_GEO));

D4H = [200E3, 28790, (1.2*v_circ_leo1_DH4 + dV_inc_leo1_DH4), 28.8; 407E3, 25980, (1.2*v_circ_leo2_DH4 + dV_inc_leo2_DH4), 51.6];

%% Ariane 5 X
% 260E3 alt, 51.6deg inc
v_circ_leo_A5 = sqrt(mu_earth / (r_earth + 260E3));
dV_inc_leo_A5 = 2 * v_circ_leo_A5 * sind(51.6/4);

% GEO, no inc
v_circ_geo_A5 = sqrt(mu_earth / (r_earth + z_GEO));

A5 = [260E3, 21500, (1.2*v_circ_leo_A5 + dV_inc_leo_A5), 51.6];

%% Falcon Heavy X
% 250E3 alt, 28.5deg inc
v_circ_leo_FH = sqrt(mu_earth / (r_earth + 250E3)); % Guessing at the LEO alt here, not provided by spaceX
dV_inc_leo_FH = 2 * v_circ_leo_FH * sind(28.5/4);

% GEO, 27deg inc
v_circ_geo_FH = sqrt(mu_earth / (r_earth + z_GEO));
dV_inc_geo_FH = 2 * v_circ_geo_FH * sind(27/4);

FH = [250E3, 57878, (1.25*v_circ_leo_FH + dV_inc_leo_FH), 28.5];

%% SLS X (Guessing the initial inclinations and LEO alt, cannot find online)
% 250E3 alt, 0 inc (Both are guesses based on what the other launch vehicles can do)
v_circ_leo_SLS = sqrt(mu_earth / (r_earth + 250E3)); % Guessing at the LEO alt here, not provided by NASA

SLS = [250E3, 86183, 1.25*v_circ_leo_SLS, 0];

%% Starship
% 250E3 alt, 28.5 inc (Assuming inclination of 28.5, common for a lot of launch systems)
v_circ_leo_SS = sqrt(mu_earth / (r_earth + 250E3)); % Guessing at the LEO alt here, not provided by spaceX
dV_inc_leo_SS = 2 * v_circ_leo_SS * sind(28.5/4);

SS = [250E3, 90719, (1.2*v_circ_leo_SS + dV_inc_leo_SS), 0];

%% Proton M
% 180E3 alt, 51.5deg inc
v_circ_leo_PM = sqrt(mu_earth / (r_earth + 180E3));
dV_inc_leo_PM = 2 * v_circ_leo_PM * sind(51.5/4);

PM = [180E3, 23000, (1.2*v_circ_leo_PM + dV_inc_leo_PM), 51.5];

%% Vulcan Centaur
% 200E3 alt, 28.7deg inc
v_circ_leo_VC = sqrt(mu_earth / (r_earth + 200E3));
dV_inc_leo_VC = 2 * v_circ_leo_VC * sind(28.7/4);

VC = [200E3, 27200, (1.2*v_circ_leo_VC + dV_inc_leo_VC), 28.7];
