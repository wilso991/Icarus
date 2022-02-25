function [SV, SVTime, SVPayload, SVSMA, deltaVReq, valid] = scienceValue(architecture, reference)
% Author: Carson Ohland
% Date: 02-14-2022
% Function: function [SV] = scienceValue(architecture)
% Purpose: Calculate science value for a given architecture

deltaVReq = 0;

initialDV = get_initial_dV_V2(architecture.launchsystem,architecture.staging);
[initialVInfMax, timeToTarget] = calc_v_inf_target(initialDV/1000,architecture.gravityassist);
[time, deltaVAdd, valid] = TimeAndDeltaVToFinalOrbit(initialVInfMax, architecture, timeToTarget);
deltaVReq = deltaVReq + deltaVAdd;
[SMA, deltaVAdd] = finalOrbit(architecture);
deltaVReq = deltaVReq + deltaVAdd;
payloadScore = payloadFOA_V4(architecture.payload);

SV = calcSV(time, payloadScore, SMA, [0.2, 0.44, 0.36], reference);
SVTime = calcSV(time, payloadScore, SMA, [0.3, 0.39, 0.31], reference);
SVPayload = calcSV(time, payloadScore, SMA, [0.15, 0.54, 0.31], reference);
SVSMA = calcSV(time, payloadScore, SMA, [0.15, 0.39, 0.41], reference);

end