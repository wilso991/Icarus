function [v_inf, time2pl] = calc_v_inf_target(dv_total, target_pl)
% Author: Matt Wilson
% Date: 02-19-2022
% Last Updated By: Matt Wilson (02-20-2022)
% Function: v_inf = calc_v_inf_target(dv_total, target_pl)
% Description: 
% Inputs: dv_total - (double) the estimated total delta-v (km/s)
%         target_pl - (string) target planet
% Outputs: v_inf - (double) hyperbolic excess velocity wrt target planet
%                  (km/s)
% Note: Output is set to NaN if the calculation is impossible due to 
% geometric constraints
% Assumptions: Planets are all in the same plane, Velocity leaving Earth
% is either same direction (outer planets) or opposite direction (inner
% planets) as the velocity of Earth wrt the sun.

% Constants
radius_earth = 6378; % Earth Radius (km)
mu_earth = 398600.4415; % GM Value for Earth (km^3/s^2)

mu_sun = 132712440017.99; % GM Value for Sun (km^3/s^2)
earth_orbit_radius = 149597898; % Radius of Earth Orbit around Sun (km)

% Determine which planet is the target for the gravity assist
if strcmp(target_pl, 'Jupiter')
    target_orbit_radius = 778279959;
    inner_pl = false;
elseif strcmp (target_pl, 'Venus')
    target_orbit_radius = 108207284;
    inner_pl = true;
else
    target_orbit_radius = 1.496e8;
    inner_pl = true;
end

h_parking = 200; % 200 km parking orbit height

% Calculate circular velocity of parking orbit
v_cir_earth = sqrt(mu_earth/(radius_earth + h_parking));

% Calculate escape velocity of parking orbit
v_esc_earth = sqrt(2)*v_cir_earth;

% If the target_pl is a direct transfer, output v_inf as the delta v left
% after escaping Earth's gravity field
if (strcmp(target_pl, 'Direct Transfer Orbit') || strcmp(target_pl, 'Earth'))
    v_inf = dv_total - v_esc_earth;
    if v_inf < 0
        v_inf = NaN;
        time2pl = NaN;
    else
        time2pl = 0;
    end
else

    % Calculate the excess hyperbolic velocity squared / C3 value
    v_inf_e_2 = dv_total^2 - v_esc_earth^2;
    
    if (v_inf_e_2 < 0)
        v_inf = NaN;
        time2pl = NaN;
    else
        v_inf_e = sqrt(v_inf_e_2);
        
        % Calculate the velocity of the earth around the sun
        v_earth = sqrt(mu_sun/earth_orbit_radius);
        
        % Change the departure angle of the excess hyperbolic velocity
        % depending on if the targer is an inner planet or an outer planet
        if inner_pl
            depAng = 0;
        else
            depAng = 180;
        end
        
        % Calculate the velocity with respect to the sun when s/c is leaving Earth
        v_wrt_sun = sqrt(v_earth^2 + v_inf_e^2 - 2*v_earth*v_inf_e*cosd(depAng));
        
        % Calculate the specific orbital energy
        energy_sun = v_wrt_sun^2/2-mu_sun/(earth_orbit_radius);
    
        % Calculate semimajor axis in sun frame
        a_sun = -mu_sun/(2*energy_sun); 
        
        % Calculate velocity in sun frame at target planet
        v2_wrt_sun = sqrt(mu_sun*(2/target_orbit_radius-1/a_sun));
        
        % Check if semimajor axis is too small to reach target planet
        if ~isreal(v2_wrt_sun)
            v_inf = NaN;
            time2pl = NaN;
        else
            
            % Slightly different formula for eccentricity depending on if the
            % target is inside or outside Earth's orbit
            if inner_pl
                e_sun = earth_orbit_radius/a_sun - 1;
            else
                e_sun = 1 - earth_orbit_radius/a_sun;
            end
            
            % Calculate the arrival flight path angle
            p_sun = a_sun*(1-e_sun^2);
            h_sun = sqrt(mu_sun*p_sun);
            arrFPA = acosd(h_sun/(target_orbit_radius*v2_wrt_sun));
            
            % Calculate velocity of target planet
            v_target = sqrt(mu_sun/target_orbit_radius);
            
            % Calculate hyperbolic excess velocity wrt target planet
            v_inf = sqrt(v2_wrt_sun^2 + v_target^2 - 2*v2_wrt_sun*v_target*cosd(arrFPA));
            
            TA = acosd(1/e_sun*(p_sun/target_orbit_radius-1));
                if inner_pl
            TA = -TA;
                end
            if energy_sun < 0
                EA = 2*atand(sqrt((1-e_sun)/(1+e_sun))*tand(TA/2));
                M = deg2rad(EA) - e_sun*sind(EA);
                if inner_pl
                    M = pi + M;
                end
            elseif energy_sun > 0
                HA = 2*atanh(sqrt((e_sun-1)/(e_sun+1))*tand(TA/2));
                M = e_sun*sinh(HA) - HA;
            else
                error('This is a rare special case where Barkers Equation is needed');
            end
            n = sqrt(mu_sun/abs(a_sun)^3);
            time2pl = M / n;     
        end   
    end
    
end
end
