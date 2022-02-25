%% Pareto Evaluator
% Author: Carson Ohland
% Date: 02-14-2022
% Purpose: Evaluate architectures based on science value and cost

%% Load Propulsion Functions
addpath('./Propulsion')
addpath('./Space Environment')

%% Generate Arcitectures
architectures = database_gen();

%% Reference Architecture
referenceArchitecture.launchsystem = 'Delta IV Heavy';
referenceArchitecture.gravityassist = 'Jupiter';
referenceArchitecture.transferstrat = 'Coast';
referenceArchitecture.finalorbit = 'High Elliptical';
referenceArchitecture.propulsion = 'Chemical';
referenceArchitecture.staging = 'Chemical';
referenceArchitecture.payload = 'Remote Sensing';
referenceArchitecture.commarchitect = 'Fixed';
referenceArchitecture.powersource = 'Solar Panels';

%% Determine science & cost values for reference architectures

[initialDV, ~] = get_initial_dV_V2(referenceArchitecture.launchsystem,referenceArchitecture.staging);
[initialVInfMax, timeToTarget] = calc_v_inf_target(initialDV/1000,referenceArchitecture.gravityassist);
[reference.time, reference.deltav, valid] = TimeAndDeltaVToFinalOrbit(initialVInfMax, referenceArchitecture, timeToTarget);
reference.SMA = finalOrbit(referenceArchitecture);
reference.payloadscore = payloadFOA_V4(referenceArchitecture.payload);

%% Determine science values
for index = 1:length(architectures)
    [architectures(index).science, architectures(index).scienceTime, architectures(index).sciencePayload, architectures(index).scienceSMA, architectures(index).deltav, architectures(index).valid] = scienceValue(architectures(index),reference);
end

for index = 1:length(architectures)
    [architectures(index).cost, flag] = Quickcost_Estimation(architectures(index), reference);
end

%% Plot Pareto Eval
figure()
hold on
for architecture = architectures
    if architecture.valid
        if strcmp(architecture.transferstrat,'Coast')
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.science,'*b')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.science,'^b')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.science,'ob')
            else
                plot(architecture.cost,architecture.science,'.b')
            end
        else
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.science,'*r')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.science,'^r')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.science,'or')
            else
                plot(architecture.cost,architecture.science,'.r')
            end
        end
    end
end
xline(3e8);
xlabel('Architecture Cost ($)')
ylabel('Architecture Science Value')
title('Pareto')

figure()
hold on
for architecture = architectures
    if architecture.valid
        if strcmp(architecture.transferstrat,'Coast')
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.scienceTime,'*b')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.scienceTime,'^b')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.scienceTime,'ob')
            else
                plot(architecture.cost,architecture.scienceTime,'.b')
            end
        else
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.scienceTime,'*r')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.scienceTime,'^r')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.scienceTime,'or')
            else
                plot(architecture.cost,architecture.scienceTime,'.r')
            end
        end
    end
end
xline(3e8);
xlabel('Architecture Cost ($)')
ylabel('Architecture Science Value')
title('Pareto (Time Focused)')


figure()
hold on
for architecture = architectures
    if architecture.valid
        if strcmp(architecture.transferstrat,'Coast')
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.sciencePayload,'*b')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.sciencePayload,'^b')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.sciencePayload,'ob')
            else
                plot(architecture.cost,architecture.sciencePayload,'.b')
            end
        else
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.sciencePayload,'*r')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.sciencePayload,'^r')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.sciencePayload,'or')
            else
                plot(architecture.cost,architecture.sciencePayload,'.r')
            end
        end
    end
end
xline(3e8);
xlabel('Architecture Cost ($)')
ylabel('Architecture Science Value')
title('Pareto (Payload Focused)')

figure()
hold on
for architecture = architectures
    if architecture.valid
        if strcmp(architecture.transferstrat,'Coast')
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.scienceSMA,'*b')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.scienceSMA,'^b')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.scienceSMA,'ob')
            else
                plot(architecture.cost,architecture.scienceSMA,'.b')
            end
        else
            if strcmp(architecture.gravityassist,'Jupiter')
                plot(architecture.cost,architecture.scienceSMA,'*r')
            elseif strcmp(architecture.gravityassist, 'Venus')
                plot(architecture.cost,architecture.scienceSMA,'^r')
            elseif strcmp(architecture.gravityassist, 'Earth')
                plot(architecture.cost,architecture.scienceSMA,'or')
            else
                plot(architecture.cost,architecture.scienceSMA,'.r')
            end
        end
    end
end
xline(3e8);
xlabel('Architecture Cost ($)')
ylabel('Architecture Science Value')
title('Pareto (SMA Focused)')

xlabel('Architecture Cost ($)')
ylabel('Architecture Science Value')
%legend("Red: Low Thrust Transfer","Blue: Coast", "*: Jupiter Gravity Assist", "\Delta: Venus Gravity Assist", "o: Earth Gravity Assist", "\cdot: Direct Transfer Orbit");