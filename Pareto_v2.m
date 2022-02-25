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
reference.commscore = 1;

%% Determine science values
for index = 1:length(architectures)
    [architectures(index).science, architectures(index).scienceTime, architectures(index).sciencePayload, architectures(index).scienceSMA, architectures(index).deltav, architectures(index).valid] = scienceValue(architectures(index),reference);
end

for index = 1:length(architectures)
    [architectures(index).cost, flag] = Quickcost_Estimation(architectures(index), reference);
end

%% Plot Pareto Eval
plotted = zeros(1,11);
rgb = [0 0 0];
figure()
hold on
for architecture = architectures
    if architecture.valid
        if architecture.cost < 3.5e8
            
            added = [architecture.cost, architecture.science, architecture.launchsystem, architecture.gravityassist, architecture.transferstrat, ...
                     architecture.finalorbit, architecture.propulsion, architecture.staging, architecture.payload, architecture.commarchitect, architecture.powersource];
            addedrgb = [1 0 0];
            if strcmp(architecture.transferstrat,'Coast')
                addedrgb = [0 0 1];
            end
            temp = plotted;
            plotted = vertcat(temp, added);
            temprgb = rgb;
            rgb = vertcat(temprgb, addedrgb);
        end
    end
end

x = double(plotted(:,1));
y = double(plotted(:,2));
s = scatter(x, y, 20, rgb);
xline(3e8);
xlabel('Architecture Cost ($)')
ylabel('Architecture Science Value')

dtt = s.DataTipTemplate;

dtt.DataTipRows(1).Label = 'Cost ($): '; 
dtt.DataTipRows(2).Label = 'Science Value: '; 
dtt.DataTipRows(end+1) = dataTipTextRow('Launch System: ', plotted(:,3));
dtt.DataTipRows(end+1) = dataTipTextRow('Gravity Assist: ', plotted(:,4));
dtt.DataTipRows(end+1) = dataTipTextRow('Transfer Strategy: ', plotted(:,5));
dtt.DataTipRows(end+1) = dataTipTextRow('Final Orbit: ', plotted(:,6));
dtt.DataTipRows(end+1) = dataTipTextRow('Propulsion: ', plotted(:,7));
dtt.DataTipRows(end+1) = dataTipTextRow('Staging: ', plotted(:,8));
dtt.DataTipRows(end+1) = dataTipTextRow('Payload: ', plotted(:,9));
dtt.DataTipRows(end+1) = dataTipTextRow('Communication Architecture: ', plotted(:,10));
dtt.DataTipRows(end+1) = dataTipTextRow('Power Source: ', plotted(:,11));