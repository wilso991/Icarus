function [initial_inclination_deg] = initial_inclination(launch_system, kick_stage)
%{
Author: Griffin Carter
Last Updated: 2/16/2022
Last Updated By: Griffin Carter

Description: Function that outputs the initial orbit inclination based on
the selected launch system and second stage options

inputs:
- launch_system: selected launch system architecture
- kick_stage: selected second stage architecture

outputs:
- initial_inclination: initial inclination of orbit [deg]

- initial_dV: A vector containing 3 values. The first value is the expected
dV from the first stage, the second value is the expected dV from the
second stage, and the third value is the expected dV from the additional
stage (equal to zero if no additional stage is selected)

ALL MASSES ARE IN KILOGRAMS UNLESS OTHERWISE NOTED
%}
clear;

%% Define Constants
r_earth = 6378.1370E3; % Radius of earth, [m]
mu_earth = 3.986E14; % Graviational parameter of Earth, [m^3/s^2]
g = 9.81; % [m/s^2]
m_sys = 500; % Assumption made that the upper portion of the system weighs about 500kg, after separation from launch system and our team's additional stage
dV_loss_factor = 0.8; % Factor that accounts for gravity losses, drag losses, steering losses, etc.

%% Second Stage Constant Parameters
m_orbus6 = 2954.14; % [kg], inert mass of Orbus 6 engine
m_AJ10 = 4015.19; % [kg], inert mass of AJ10-118K engine
m_prop_factor_additional_stage = 1.75; % Scaling factor to change amount of fuel, for preliminary optimization

%%%%%%%%%%%%%%%%%%%%%
% Testing variables %
%%%%%%%%%%%%%%%%%%%%%
% kick_stage = 'Chemical';
% kick_stage = 'Solid Rocket';
% kick_stage = 'No Additional';
% launch_system = 'Delta IV Heavy';
% launch_system = 'Ariane 5';
% launch_system = 'Falcon Heavy';
% launch_system = 'SLS';
% launch_system = 'Starship';
% launch_system = 'Proton M';
% launch_system = 'Vulcan Centaur';
%%%%%%%%%%%%%%%%%%%%%

%% Staging
%% Orbus 6 Engine (SRM Kick Stage)
if isequal(kick_stage, 'Solid Rocket')
    % Orbus 6 Engine Performance Parameters
    Itot_additional_stage = 7731009.141; % Total impusle for Orbus 6 engine, [N*s]
    Isp_additional_stage = 290; % [s]

    % Propellant Mass
    m_prop_additional_stage = m_prop_factor_additional_stage * (Itot_additional_stage / (Isp_additional_stage * g)); % Total propellant mass, [kg]
    
    % Mass Ratio
    m0_additional_stage = m_prop_additional_stage + m_sys + m_orbus6; % Initial mass of additional stage, [kg]
    mf_additional_stage = m0_additional_stage - m_prop_additional_stage; % Final mass of additional stage, [kg]
    MR_additional_stage = m0_additional_stage / mf_additional_stage; % Mass ratio, assuming 500kg mass above this stage
    
    no_additional_stage_flag = false;

%% AJ10-118K Engine (Chemical Upper Stage)
elseif isequal(kick_stage, 'Chemical')
    % First calculate the weight of the propellant used for Orbus 6
    % (baseline weight for propellants at the moment)
    Itot_O6 = 7731009.141; % Total impusle for Orbus 6 engine, [N*s]
    Isp_O6 = 290; % [s]
    m_prop_O6 = (Itot_O6 / (Isp_O6 * g)); % Total propellant mass for Orbus 6 engine

    % AJ10-118K Engine Performance Parameters
    Isp_additional_stage = 320.5; % [s]

    % Propellant Mass
    m_prop_additional_stage = m_prop_O6 * m_prop_factor_additional_stage; % Propellant mass of additional stage
    
    % Mass Ratio
    m0_additional_stage = m_prop_additional_stage + m_sys + m_AJ10; % Initial mass of additional stage, [kg]
    mf_additional_stage = m0_additional_stage - m_prop_additional_stage; % Final mass of additional stage, [kg]
    MR_additional_stage = m0_additional_stage / mf_additional_stage; % Mass ratio, assuming 500kg mass above this stage
    
    no_additional_stage_flag = false;

%% No Additional Stage
elseif isequal(kick_stage, 'No Additional')
    no_additional_stage_flag = true;
end

%% Launch Vehicle

%% Delta IV Heavy %%
if isequal(launch_system, 'Delta IV Heavy')
    % Stage 2 - Performance Parameters
    IspS2 = 462; % Isp of second stage, [s]
    t_burnS2 = 1125; % Burn time, [s]
    
    % Stage 2 - Mass Values & Mass Ratio
    m_propS2 = 27220; % Propellant mass of second stage
    m_inertS2 = 3840; % Inert mass of second stage

    if no_additional_stage_flag % Initial mass of second stage
        m0_S2 = m_propS2 + m_inertS2 + m_sys;
    else
        m0_S2 = m_propS2 + m_inertS2 + m0_additional_stage; 
    end

    mf_S2 = m0_S2 - m_propS2; % Final mass of second stage
    MR_S2 = m0_S2 / mf_S2; % Mass ratio of second stage
    
    % Stage 1 - Performance Parameters
    IspS1 = 386; % Isp of first stage, [s]
    t_burnS1 = 328; % Burn time, [s]

    % Stage 1 - Mass Values & Mass Ratio
    m_propS1 = 2 * 200400; % Propellant mass of first stage
    m_inertS1 = 2 * 26000; % Inert mass of first stage
    m0_S1 = m0_S2 + m_propS1 + m_inertS1; % Initial mass of first stage
    mf_S1 = m0_S1 - m_propS1; % Final mass of second stage 
    MR_S1 = m0_S1 / mf_S1; % Mass ratio of first stage

    % Payload masses
    m_payS1 = m0_S2; % Payload mass for first stage

    if no_additional_stage_flag % Payload mass for second stage
        m_payS2 = m_sys;
    else
        m_payS2 = m0_additional_stage;
    end
    
    % Calculate dV attainable from each stage, each value in [m/s]
    if no_additional_stage_flag
        dV_additional_stage = 0;
    else
        dV_additional_stage = g * Isp_additional_stage * log(MR_additional_stage);
    end

    dV_S2 = g * IspS2 * log(MR_S2);
    dV_S1 = g * IspS1 * log(MR_S1);
    
    % Total dV attainable multiplied by a loss factor, to account for 
    % drag losses, gravity losses, steering losses, etc.
    dV_tot = dV_additional_stage + (dV_S2 + dV_S1) * dV_loss_factor;
    dV_initial = [dV_S1 * dV_loss_factor; dV_S2 * dV_loss_factor; dV_additional_stage];

%% Ariane 5 %%

elseif isequal(launch_system, 'Ariane 5')
    % Stage 2 - Performance Parameters
    IspS2 = 446; % Isp of second stage, [s]
    
    % Stage 2 - Mass Values & Mass Ratio
    m_propS2 = 14900; % Propellant mass of second stage
    m_inertS2 = 4540; % Inert mass of second stage

    if no_additional_stage_flag % Initial mass of second stage
        m0_S2 = m_propS2 + m_inertS2 + m_sys;
    else
        m0_S2 = m_propS2 + m_inertS2 + m0_additional_stage; 
    end

    mf_S2 = m0_S2 - m_propS2; % Final mass of second stage
    MR_S2 = m0_S2 / mf_S2; % Mass ratio of second stage
    
    % Stage 1 - Performance Parameters
    IspS1 = 432; % Isp of first stage, [s], vacuum value taken to mimic increased performance w/ SRBs

    % Stage 1 - Mass Values & Mass Ratio
    m_propS1 = 2 * 187787; % Propellant mass of first stage
    m_inertS1 = 2 * 29937; % Inert mass of first stage
    m0_S1 = m0_S2 + m_propS1 + m_inertS1; % Initial mass of first stage
    mf_S1 = m0_S1 - m_propS1; % Final mass of second stage 
    MR_S1 = m0_S1 / mf_S1; % Mass ratio of first stage

    % Payload masses
    m_payS1 = m0_S2; % Payload mass for first stage

    if no_additional_stage_flag % Payload mass for second stage
        m_payS2 = m_sys;
    else
        m_payS2 = m0_additional_stage;
    end
    
    % Calculate dV attainable from each stage, each value in [m/s]
    if no_additional_stage_flag
        dV_additional_stage = 0;
    else
        dV_additional_stage = g * Isp_additional_stage * log(MR_additional_stage);
    end
    
    dV_S2 = g * IspS2 * log(MR_S2);
    dV_S1 = g * IspS1 * log(MR_S1);

    % Total dV attainable multiplied by a loss factor, to account for 
    % drag losses, gravity losses, steering losses, etc.
    dV_tot = dV_additional_stage + (dV_S2 + dV_S1) * dV_loss_factor;
    dV_initial = [dV_S1 * dV_loss_factor; dV_S2 * dV_loss_factor; dV_additional_stage];

%% Falcon Heavy %%

elseif isequal(launch_system, 'Falcon Heavy')
    % Stage 2 - Performance Parameters
    IspS2 = 348; % Isp of second stage, [s]
    
    % Stage 2 - Mass Values & Mass Ratio
    m_propS2 = 3 * 90519; % Propellant mass of second stage
    m_inertS2 = 3 * 3629; % Inert mass of second stage

    if no_additional_stage_flag % Initial mass of second stage
        m0_S2 = m_propS2 + m_inertS2 + m_sys;
    else
        m0_S2 = m_propS2 + m_inertS2 + m0_additional_stage; 
    end

    mf_S2 = m0_S2 - m_propS2; % Final mass of second stage
    MR_S2 = m0_S2 / mf_S2; % Mass ratio of second stage
    
    % Stage 1 - Performance Parameters
    IspS1 = 296.5; % Isp of first stage, [s], average of vaccuum and SL

    % Stage 1 - Mass Values & Mass Ratio
    m_propS1 = 3 * 362874; % Propellant mass of first stage
    m_inertS1 = 3 * 19958; % Inert mass of first stage
    m0_S1 = m0_S2 + m_propS1 + m_inertS1; % Initial mass of first stage
    mf_S1 = m0_S1 - m_propS1; % Final mass of second stage 
    MR_S1 = m0_S1 / mf_S1; % Mass ratio of first stage

    % Payload masses
    m_payS1 = m0_S2; % Payload mass for first stage

    if no_additional_stage_flag % Payload mass for second stage
        m_payS2 = m_sys;
    else
        m_payS2 = m0_additional_stage;
    end
    
    % Calculate dV attainable from each stage, each value in [m/s]
    if no_additional_stage_flag
        dV_additional_stage = 0;
    else
        dV_additional_stage = g * Isp_additional_stage * log(MR_additional_stage);
    end

    dV_S2 = g * IspS2 * log(MR_S2);
    dV_S1 = g * IspS1 * log(MR_S1);
    
    % Total dV attainable multiplied by a loss factor, to account for 
    % drag losses, gravity losses, steering losses, etc.
    dV_tot = dV_additional_stage + (dV_S2 + dV_S1) * dV_loss_factor;
    dV_initial = [dV_S1 * dV_loss_factor; dV_S2 * dV_loss_factor; dV_additional_stage];

 %% SLS

elseif isequal(launch_system, 'SLS')
    dV_tot = 1.25E4; % Need to find more data on this launch vehicle

%% Starship

elseif isequal(launch_system, 'Starship')
    % Stage 2 - Performance Parameters
    IspS2 = 380; % Isp of second stage, [s]
    
    % Stage 2 - Mass Values & Mass Ratio
    m_propS2 = 1088622; % Propellant mass of second stage
    m_inertS2 = 6883; % Inert mass of second stage

    if no_additional_stage_flag % Initial mass of second stage
        m0_S2 = m_propS2 + m_inertS2 + m_sys;
    else
        m0_S2 = m_propS2 + m_inertS2 + m0_additional_stage; 
    end

    mf_S2 = m0_S2 - m_propS2; % Final mass of second stage
    MR_S2 = m0_S2 / mf_S2; % Mass ratio of second stage
    
    % Stage 1 - Performance Parameters
    IspS1 = 350; % Isp of first stage, [s], average of vaccuum and SL

    % Stage 1 - Mass Values & Mass Ratio
    m_propS1 = 3084428; % Propellant mass of first stage
    m_inertS1 = 37857; % Inert mass of first stage

    m0_S1 = m0_S2 + m_propS1 + m_inertS1; % Initial mass of first stage
    mf_S1 = m0_S1 - m_propS1; % Final mass of second stage 
    MR_S1 = m0_S1 / mf_S1; % Mass ratio of first stage

    % Payload masses
    m_payS1 = m0_S2; % Payload mass for first stage

    if no_additional_stage_flag % Payload mass for second stage
        m_payS2 = m_sys;
    else
        m_payS2 = m0_additional_stage;
    end
    
    % Calculate dV attainable from each stage, each value in [m/s]
    if no_additional_stage_flag
        dV_additional_stage = 0;
    else
        dV_additional_stage = g * Isp_additional_stage * log(MR_additional_stage);
    end

    dV_S2 = g * IspS2 * log(MR_S2);
    dV_S1 = g * IspS1 * log(MR_S1);
    
    % Total dV attainable multiplied by a loss factor, to account for 
    % drag losses, gravity losses, steering losses, etc.
    dV_tot = dV_additional_stage + (dV_S2 + dV_S1) * dV_loss_factor;
    dV_initial = [dV_S1 * dV_loss_factor; dV_S2 * dV_loss_factor; dV_additional_stage];

%% Proton M

elseif isequal(launch_system, 'Proton M')
    % Stage 2 - Performance Parameters
    IspS2 = 327; % Isp of second stage, [s]
    
    % Stage 2 - Mass Values & Mass Ratio
    m_propS2 = 157300; % Propellant mass of second stage
    m_inertS2 = 11000; % Inert mass of second stage

    if no_additional_stage_flag % Initial mass of second stage
        m0_S2 = m_propS2 + m_inertS2 + m_sys;
    else
        m0_S2 = m_propS2 + m_inertS2 + m0_additional_stage; 
    end

    mf_S2 = m0_S2 - m_propS2; % Final mass of second stage
    MR_S2 = m0_S2 / mf_S2; % Mass ratio of second stage
    
    % Stage 1 - Performance Parameters
    IspS1 = 285; % Isp of first stage, [s], average of vaccuum and SL

    % Stage 1 - Mass Values & Mass Ratio
    m_propS1 = 428300; % Propellant mass of first stage
    m_inertS1 = 30600; % Inert mass of first stage

    m0_S1 = m0_S2 + m_propS1 + m_inertS1; % Initial mass of first stage
    mf_S1 = m0_S1 - m_propS1; % Final mass of second stage 
    MR_S1 = m0_S1 / mf_S1; % Mass ratio of first stage

    % Payload masses
    m_payS1 = m0_S2; % Payload mass for first stage

    if no_additional_stage_flag % Payload mass for second stage
        m_payS2 = m_sys;
    else
        m_payS2 = m0_additional_stage;
    end
    
    % Calculate dV attainable from each stage, each value in [m/s]
    if no_additional_stage_flag
        dV_additional_stage = 0;
    else
        dV_additional_stage = g * Isp_additional_stage * log(MR_additional_stage);
    end

    dV_S2 = g * IspS2 * log(MR_S2);
    dV_S1 = g * IspS1 * log(MR_S1);
    
    % Total dV attainable multiplied by a loss factor,  to account for 
    % drag losses, gravity losses, steering losses, etc.
    dV_tot = dV_additional_stage + (dV_S2 + dV_S1) * dV_loss_factor;
    dV_initial = [dV_S1 * dV_loss_factor; dV_S2 * dV_loss_factor; dV_additional_stage];

%% Vulcan Centaur

elseif isequal(launch_system, 'Vulcan Centaur')
    % Stage 2 - Performance Parameters
    IspS2 = 454; % Isp of second stage, [s]
    
    % Stage 2 - Mass Values & Mass Ratio
    m_propS2 = 33558; % Propellant mass of second stage
    m_inertS2 = 603 * 1.5; % Inert mass of second stage

    if no_additional_stage_flag % Initial mass of second stage
        m0_S2 = m_propS2 + m_inertS2 + m_sys;
    else
        m0_S2 = m_propS2 + m_inertS2 + m0_additional_stage; 
    end

    mf_S2 = m0_S2 - m_propS2; % Final mass of second stage
    MR_S2 = m0_S2 / mf_S2; % Mass ratio of second stage
    
    % Stage 1 - Performance Parameters
    IspS1 = 320; % Isp of first stage, [s], average of vaccuum and SL, high end estimate

    % Stage 1 - Mass Values & Mass Ratio
    m_propS1 = 48000; % Propellant mass of first stage
    m_inertS1 = 5400; % Inert mass of first stage

    m0_S1 = m0_S2 + m_propS1 + m_inertS1; % Initial mass of first stage
    mf_S1 = m0_S1 - m_propS1; % Final mass of second stage 
    MR_S1 = m0_S1 / mf_S1; % Mass ratio of first stage

    % Payload masses
    m_payS1 = m0_S2; % Payload mass for first stage

    if no_additional_stage_flag % Payload mass for second stage
        m_payS2 = m_sys;
    else
        m_payS2 = m0_additional_stage;
    end
    
    % Calculate dV attainable from each stage, each value in [m/s]
    if no_additional_stage_flag
        dV_additional_stage = 0;
    else
        dV_additional_stage = g * Isp_additional_stage * log(MR_additional_stage);
    end

    dV_S2 = g * IspS2 * log(MR_S2);
    dV_S1 = g * IspS1 * log(MR_S1);
    
    % Total dV attainable multiplied by a loss factor, to account for due to
    % drag losses, gravity losses, steering losses, etc.
    dV_tot = dV_additional_stage + (dV_S2 + dV_S1) * dV_loss_factor;
    dV_initial = [dV_S1 * dV_loss_factor; dV_S2 * dV_loss_factor; dV_additional_stage]; 
else
    dV_tot = 0;
    print('ERROR: No matching database strings found. Check database_gen file.')
end

%% Calculate possible initial inclination
% NOTE: Currently assuming just enough dV is expended to put use in LEO, at
% an altitude of 500km above Earth. Additional dV is then applied to change
% the orbits inclination.

z = 500E3; % Distance above the Earth's surface
dV_circ_earth = sqrt(mu_earth / (r_earth + z)); % Circular velocity at altitude, m/s
dV_inclination_change = dV_tot - dV_circ_earth; % Velocity left to change incliation

alpha_i = (2 * asin(dV_inclination_change / (2 * dV_circ_earth))) * (180 / pi); % Initial inclination change attainable by 2nd stage

initial_inclination_deg = alpha_i; % [IN DEGREES], Initial inclination attainable from launch vehicle