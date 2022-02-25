function [FinalCost, valid] = Quickcost_Estimation(architecture, reference)
%Input: "arhcitecture" must contain the 10 different options for each
%archiecture and "reference" is the "reference" variable as its called in
%the Pareto.m file, its needed so we can have the reference.deltav value

%Output: "FinalCost" the finalcost of the architecture in millions of
%dollars of 2022 and "Flag" is set 1 when the archiecture does NOT meet the
%margin and percentile conditions set by the professor and 0 when it does

%% The QuickCost Model (Table 11-12) for a Preliminary Cost Estimate

valid = true;

%if statements block to determine the mass and power for each payload
%option
if(architecture.payload == 'Remote Sensing')
    INST_weight = 67;
    INST_power = 100;
elseif(architecture.payload == 'In-situ')
    INST_weight = 30.5;
    INST_power = 41.5;   
elseif(architecture.payload == 'All Payload')
    INST_weight = 97.5;
    INST_power = 141.5;
elseif(architecture.payload == 'Single Objective')
    INST_weight = [10.7, 13.4, 9.25, 75.5/7, 14.25, 11.3125];
    INST_power = [20.125, 20, 75.5/6, 105.5/7, 21.25, 15.9375];
elseif(architecture.payload == 'Single+2nd Objective')
    INST_weight = 1.05*[10.7, 13.4, 9.25, 75.5/7, 14.25, 11.3125]; %assuming the payload
    %for the secondary objective will add 5% to the total payload mass
    INST_power = 1.05*[20.125, 20, 75.5/6, 105.5/7, 21.25, 15.9375]; %assuming the payload
    %for the secondary objective will add 5% to the total payload power
elseif(architecture.payload == 'EUVI only')
    INST_weight = 10;
    INST_power = 12;
end

SC_dry_weight = INST_weight./0.15; %Appendix A, Table A-1 states
%that the payload is about 15% of the total mass of the spacecraft for 
%similar missions

SC_total_power = INST_power./0.22; %Total power of the spacecraft estimated using
%Appendix A, Table A-2. 141.5 is the summation of all the powers of the
%instruments from lecture in Watt

SC_Data = 0.5; %Data Rate Percentile is set to 0.5 since its the median
%data rate for missions according to the book

SC_Life = (6*12) + 90/30.417; %Total spacecraft lifetime in months since
%launch. Note that this the DSI lifetime according to the
%requirements given by the professor (>38 days, recommended: 90 days)

SC_New = 0.1; %Percent New as I understand it, is defined as the ratio
%between the number of new technologies over the number of total
%technologies on the spacecraft. I estimated it as 0.1

Planetry = 1; %Set to 0 when the spacecraft is orbiting Earth and 1 when
%its anything else

ATP_year = 2023; %This is the year that the project proposal is officially
%sent to NASA. I assumed its 2023

InstrComp = 0.5; %Instrument complexity fraction which is set to 0.5 as
%its the median complexity

Team = 2; %Set to 1 when the team is unexperienced, 2 when the team is
%mixed, 3 when the team is normal, and 4 when the team is extensively
%familiar with the project and have similar experiences. We can't pick 4 or
%3 because this number is dependent on experience and not knowledge, and
%since were college students, we don't ALL have the experience (internships, jobs, etc)
%As a result, 2 is the most accurate.



Cost = 2.828.*(SC_dry_weight.^0.457).*(SC_total_power.^0.157)*(2.718.^(0.171...
    .*SC_Data)).*(2.718.^(0.00209.*SC_Life)).*(2.718.^(1.52.*SC_New)).*(2.718.^...
    (0.258.*Planetry)).*(1./(2.718.^(0.0145.*(ATP_year-1960)))).*(2.718.^(0.467...
    .*InstrComp)).*(1./(2.718.^(0.237.*Team))); %Cost Model Equation

Cost = 278.802/218.056 .* Cost; %Converted to 2022 Money from 2010

Cost = 1.02 .* Cost; %Accounting for costs from Phase A

Cost = 1.09 .* Cost; %Accounting for the ground station cost estimate

Cost = ((0.05 .* (SC_Life/12 .* Cost)) + Cost).*10^6; %Accounting for the almost six 
%years of data analysis and operations

%% Varying the Cost Based on the Other Architectural Options (Laucnh System, Gravity Assist, Transfer Strategy, Final Orbit)
if(architecture.deltav == reference.deltav)
    Cost = Cost;
elseif(architecture.deltav ~= reference.deltav)
    Cost = Cost.*(architecture.deltav/reference.deltav);
end

%% Varying the Cost Based on the Other Architectural Options (Propulsion, Staging)
if( strcmp(architecture.propulsion, 'Chemical') && strcmp(architecture.staging, 'No Additional'))
    Cost = Cost;
elseif(strcmp(architecture.propulsion, 'Chemical') && strcmp(architecture.staging, 'Chemical'))
    Cost = Cost + get_staging_cost('Chemical');
elseif(strcmp(architecture.propulsion, 'Hybrid') && strcmp(architecture.staging, 'No Additional'))
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, hyb] = get_propulsion_cost('Hybrid');
    Cost = Cost - chem + hyb;
elseif(strcmp(architecture.propulsion, 'Hybrid') && strcmp(architecture.staging, 'Chemical'))
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, hyb] = get_propulsion_cost('Hybrid');
    Cost = Cost - chem + hyb + get_staging_cost('Chemical');
elseif(strcmp(architecture.propulsion, 'Solar Sail') && strcmp(architecture.staging, 'No Additional'))   
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, ss] = get_propulsion_cost('Solar Sail');
    Cost = Cost - chem + ss;
elseif(strcmp(architecture.propulsion, 'Solar Sail') && strcmp(architecture.staging, 'Chemical'))   
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, ss] = get_propulsion_cost('Solar Sail');
    Cost = Cost - chem + ss + get_staging_cost('Chemical');
elseif(strcmp(architecture.propulsion, 'Ion Propulsion') && strcmp(architecture.staging, 'No Additional'))   
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, ip] = get_propulsion_cost('Ion Propulsion');
    Cost = Cost - chem + ip; 
elseif(strcmp(architecture.propulsion, 'Ion Propulsion') && strcmp(architecture.staging, 'Chemical'))   
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, ip] = get_propulsion_cost('Ion Propulsion');
    Cost = Cost - chem + ip + get_staging_cost('Chemical'); 
elseif(strcmp(architecture.propulsion, 'NTR') && strcmp(architecture.staging, 'No Additional'))   
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, ntr] = get_propulsion_cost('NTR');
    Cost = Cost - chem + ntr; 
elseif(strcmp(architecture.propulsion, 'NTR') && strcmp(architecture.staging, 'Chemical'))   
    [x, y, chem] = get_propulsion_cost('Chemical');
    [x, y, ntr] = get_propulsion_cost('NTR');
    Cost = Cost - chem + ntr + get_staging_cost('Chemical'); 
end

%% Varying the Cost Based on the Other Architectural Options (Power Source)
[PowerSourceCost] = powerSourceFOA_V3(architecture.payload);

if(architecture.powersource == 'Solar Panels')
    Cost = Cost;
elseif(architecture.powersource == 'RTG')
    Cost = Cost - PowerSourceCost(1) + PowerSourceCost(2);
end


%% If we have more than we cost for each single objective we will take the average
[r, c] = size(Cost);
if((r > 1) || (c > 1))
    FinalCost = mean(Cost);
else
    FinalCost = Cost;
end

%% Does the Design meet the 30% Margin constraint?
MPV = 300; %300 Million of Dollars in 2022 is the project's budget (MPV)
MEV = FinalCost;
Margin = (MPV-MEV)/MEV;

if(Margin < 0.30)
    valid = false; %If not valid, then the design is unfeasible
end


%% Does the Design meet the 70th Percentile constraint? (Assuming a Normal Distribution)
SEE = 41; %The Standard Error of Estimate in Percentage
sigma = FinalCost*(SEE/100);
Z = 0.524; %The Z-value for the 70th percentile from a normal distribution table
Percentile = FinalCost + Z*sigma;


if(Percentile > MPV)
    valid = false; %If not valid, then the design is unfeasible
end


end