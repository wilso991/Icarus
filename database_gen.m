function [architectures] = database_gen()
% Author: Nhat Dang & Carson Ohland
% Date: 02-10-2022
% Function: [architectures] = database_gen()
% Purpose: Generate all possible non-contradictory architectures and output
% them as a 1xN struct with fields for each of the categories

%% Database
launchsystem = ["Delta IV Heavy","Ariane 5","Falcon Heavy","SLS","Starship","Proton M","Vulcan Centaur"];
gravityassist = ["Jupiter","Venus","Earth","Direct Transfer Orbit"];
transferstrat = ["Coast","Low Thrust"];
finalorbit = ["High Elliptical","Non-Keplerian","Circular","Low Elliptical"];
propulsion = ["Chemical","Solar Sail","Ion Propulsion","Hybrid","NTR","Electric Sail"];
staging = ["No Additional", "Solid Rocket", "Chemical"];
payload = ["Remote Sensing","In-situ","All Payload","Single Objective","Single+2nd Objective", "DSI only", "DSI+UVS", "MAG+COR+EPP"];
commarchitect = ["Fixed","Deployed","Gimbaled"];
powersource = ["Solar Panels","RTG"];

%% Concept Generation

% Pre-allocate struct length to the maximum number of architectures for runtime
maxArchitectures = length(launchsystem)*length(gravityassist)*length(transferstrat)*length(finalorbit)*length(propulsion)*length(staging)*length(payload)*length(commarchitect)*length(powersource);
concepts(maxArchitectures) = struct('powersource',"",'commarchitect',"",'payload',"",'staging',"",'propulsion',"",'finalorbit',"",'transferstrat',"",'gravityassist',"",'launchsystem',"",'science',0,'scienceTime',0,'sciencePayload',0,'scienceSMA',0,'cost',0,'deltav',0,'valid',true);
concept.science = 0;
concept.scienceTime = 0;
concept.sciencePayload = 0;
concept.scienceSMA = 0;
concept.cost = 0;
concept.deltav = 0;
concept.valid = true;

% Enumerate possible architectures, checking where relevant for
% contridictions between options
index = 1;
for PS = powersource
    concept.powersource = PS;
    
    for CA = commarchitect
        concept.commarchitect = CA;
            
        for PL = payload
            concept.payload = PL;

            for STAG = staging
                concept.staging = STAG;

                for PROP = propulsion
                    concept.propulsion = PROP;

                    for FO = finalorbit
                        if strcmp(FO, "Non-Keplerian") && ~(contains(concept.propulsion, "Sail") || strcmp(concept.propulsion, "Ion Propulsion"))
                            continue
                        end
                        concept.finalorbit = FO;

                        for TS = transferstrat
                            if strcmp(TS,"Low Thrust") && (strcmp(concept.propulsion,"NTR") || strcmp(concept.propulsion, "Chemical") || strcmp(concept.propulsion, "Hybrid"))
                                continue
                            end
                            concept.transferstrat = TS;

                            for GA = gravityassist
                                if strcmp(concept.powersource, "Solar Panels") && strcmp(GA, "Jupiter")
                                    continue
                                elseif strcmp(concept.transferstrat, "Coast") && strcmp(GA, "Direct Transfer Orbit")
                                    continue
                                elseif strcmp(concept.payload, "Single+2nd Objective") && strcmp(GA, "Direct Transfer Orbit")
                                    continue
                                elseif strcmp(concept.finalorbit, "Circular") && strcmp(GA, "Jupiter")
                                    continue
                                end
                                concept.gravityassist = GA;

                                for LS = launchsystem
                                    concept.launchsystem = LS;
                                    concepts(index) = concept;
                                    index = index + 1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

architectures = concepts(1:index-1);