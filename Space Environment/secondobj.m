%% README
% Author: Nhat Dang (02-23-2022)
% Function: generate secondary objective for selected architecture
% Inputs: architceture - selected architecture
%         Format: string structure

function [sobj] = secondobj(architecture)

rng(450); % selected seed value for consistency

% Initialized options for secondary objective
option = ["Jupiter Flyby", "Radiation Shielding", "Venus Flyby", "Technology Demonstration", "Circum-solar Dust Disk", "Polar Space Weather", "Cubesat Rideshare", "Educational Payload"];
score = zeros(1,numel(option));
score([2 5 6]) = 5 + randi([0 4],1);

% Establish option limitations for selection
if architecture.gravityassist ~= "Jupiter"
    score(1) = -1;
    if architecture.gravityassist ~= "Venus"
        score(3) = -1;
    else
        score(3) = 10;
    end
else
    score(1) = 10;
end

if architecture.propulsion == "Electric Sail"
    score(4) = 100;
    fprintf('Note: cannot choose other secondary objective\n');
end

if architecture.payload == "Remote Sensing" | architecture.payload == "In-situ"
    score([7 8]) = 5 + randi([0 4],1);
elseif architecture.payload == "All Payload"
    score([7 8]) = -1;
end

% Print and select final result
select = option(score == max(score));
fprintf('The available options are: ');
for i = 1:numel(select)
    fprintf('%s',select(i));
    if i ~= numel(select)
        fprintf(', ');
    end
end

if numel(select) > 1
    sobj = select(randi([1, numel(select) - 1],1) + 1);
else
    sobj = select;
end

fprintf('\nThe selected secondary objective is: %s \n', sobj);

end