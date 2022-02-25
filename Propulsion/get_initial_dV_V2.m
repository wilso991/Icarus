function [initial_dV, staged_dV] = get_initial_dV_V2(launch_system, kick_stage)
%{
Author: Griffin Carter
Last Updated: 2/22/2022
Last Updated By: Griffin Carter

Description: Function that outputs the dV the system can attain from the
selected launch system and additional stage architectures. This is the
second version of this function and is 'stripped down' compared to the first
version. For each architecture, a predetermined dV is already known and
applied. The underlying calculations that arrived at these results are in
the Google Drive (in the propulsion team's folder) and in the first script.
The dV's here are from the 'Maximum Payload to LEO' analysis.

inputs:
- launch_system: selected launch system architecture
- kick_stage: selected second stage architecture

outputs:
- initial_dV: Velocity change (deltaV) attainable from launch system (first
& second stage) and additional stage combination

- staged_dV: Optional output that contains the dV values for the launch
system and additional stage separately, in the form [launch_sys, additional_stage]

%}

%%%%%%%%%%%%%%%%%
%%%% Staging %%%%
%%%%%%%%%%%%%%%%%

%% Orbus 6 Engine (SRM Kick Stage)
if isequal(kick_stage, 'Solid Rocket')
    dV_additional_stage = 2463.17;

%% AJ10-118K Engine (Chemical Upper Stage)
elseif isequal(kick_stage, 'Chemical')
    % Assumes: Isp = 400s, t_burn = 100s, m_dot = 245.47 kg/s
    dV_additional_stage = 10007.95;

%% No Additional Stage
elseif isequal(kick_stage, 'No Additional')
    dV_additional_stage = 0;

else
    dV_additional_stage = -1;
    print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Launch Vehicle %%%%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Delta IV Heavy %%
if isequal(launch_system, 'Delta IV Heavy')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 11960.70;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 13169.53;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 13834.07;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end

%% Ariane 5 %%

elseif isequal(launch_system, 'Ariane 5')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 12489.29201;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 13432.31494;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 13916.44597;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end    

%% Falcon Heavy %%

elseif isequal(launch_system, 'Falcon Heavy')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 12871.07594;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 13815.83603;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 14302.49873;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end      

 %% SLS %%

elseif isequal(launch_system, 'SLS')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 10977.45082;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 11469.31739;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 11707.00799;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end         

%% Starship %%

elseif isequal(launch_system, 'Starship')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 11809.3314;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 11993.08046;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 12077.61955;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end           

%% Proton M %%

elseif isequal(launch_system, 'Proton M')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 12553.0336;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 13938.55021;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 14719.39477;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end        

%% Vulcan Centaur %%

elseif isequal(launch_system, 'Vulcan Centaur')
    if isequal(kick_stage, 'Chemical')
        dV_LS = 11290.73302;
    elseif isequal(kick_stage, 'Solid Rocket')
        dV_LS = 12642.08721;
    elseif isequal(kick_stage, 'No Additional')
        dV_LS  = 13405.78118;
    else
        print('ERROR: No matching database strings for staging found. The output initial velocity is likely NOT accurate. Check database_gen file.')
    end       
else
    dV_LS = -1;
    print('ERROR: No matching database strings for propulsion system found. Check database_gen file.')
end

initial_dV = dV_LS + dV_additional_stage;
staged_dV = [dV_LS, dV_additional_stage];
