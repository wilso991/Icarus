% Function to calculate time and delta v required to crank the orbit
% per one leg of a Hohmann transfer between two points
function inclGain = transferStrat(target, propType)
    inclGain = 0;

     %%% ASSUME SPACECRAFT MASS
    mass = 500; %kg

    %% CALCULATE INCLINATION GAIN
    
    % Solar Sail
    if strcmp(propType, 'Solar Sail')
        % parameters
        alpha = atan(1 / sqrt(2));
        sigma = mass*1000/(178.9^2);    %Polaris values for sail size
        beta = 8.17/sigma/5.93; %Lightness number (Assumes 90 percent efficiency)
        % equation for inclination gain per orbit
        inclGain = 180/pi * (4 * beta *  (cos(alpha))^2 * sin(alpha));
    end

    % Electric Sail
    if strcmp(propType, 'Electric Sail')
        % parameters
        alpha = atan(1 / sqrt(2));
        acc = .0005*149.6e6/target.SMA;    % m/s^2   value from slides
        u = 1.327e11;
        g = u/(target.SMA^2)*1e3;
        beta = acc/g; %Equivalent ightness number (Assumes 90 percent efficiency, dependent on r)
        % equation for inclination gain per orbit
        inclGain = 180/pi * (4 * beta *  (cos(alpha))^2 * sin(alpha));
    end

    %% Ion Propulsion
    if strcmp(propType, 'Ion Propulsion') %See lecture 7, slide 15
        % parameters
        %compute spacecraft sma assuming half the period of the transfer
        %planet
        period_ratio = .5;
        sma = target.SMA * period_ratio^(2/3);
        ecc = target.SMA/sma - 1;                    %orbital eccentricity
        u = 1.327e11;               %km^3/s^2 gravitational parameter
        ion_mass = mass+13.5+50;                 %kg spacecraft+thruster + fuel
        thrust = .236;              %Newtons. Assuming NASA NEXT thruster 
        F = thrust/ion_mass/1000;        %km/s^2
        p = sma*(1-ecc^2);
        
        w = 0;
        df = .0001;
        i = 0.001;
        for f = 0:df:2*pi
            di_df = (F/u/p) .* cos(f+w) .* ((p./(1 + ecc.*cos(f))).^3) .*cos((pi/2)*(1-sign(cos(f+w))));
            dw_df = -1*(F/u/p) ./tan(i) .* cos(f+w) .* ((p./(1 + ecc.*cos(f))).^3) .*cos((pi/2)*(1-sign(cos(f+w))));
            i = i + df*di_df;
            w = w + df*dw_df;
        end
        inclGain = 180*i/pi;
    end
end