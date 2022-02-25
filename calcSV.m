function scienceValue = calcSV(time, payloadScore, R, weights, ref)
% Author: Matt Wilson
% Date: 02-14-2022
% Function: scienceValue = calcSV(time, payloadScore, gss, R, weights, ref)
% Description: Calculates science value based on time to final orbit,
%              payload score, ground system speed, and final radius.
% Inputs: time - time to final orbit
%         payloadScore - payload score
%         gss - ground system speed
%         R - final orbit radius
%         weights - list of weights respective to first 4 inputs
%         ref - list of reference values respective to first 4 inputs
% Outputs: scienceValue - science value

% Allows you to input a reference value or just hard code them here
t_ref = ref.time; 
R_ref = ref.SMA;

% Allow you to input weights or just hard code them here
W_time = weights(1);
W_payload = weights(2);
W_dist = weights(3);

% Science value equation from meeting on 02-10-2022
% (Matrix multiplication for weights times the scores)

W = [W_time, W_payload, W_dist];
scores = [(time/t_ref)^-1, payloadScore, (R/R_ref)^-1].';

scienceValue = W * scores;