function phase = CheckPhase(testPoint, fusionCurve, vaporCurve, subCurve, criticalTemp, triplePointTemp)
% Purpose: Determines the phase of a given test point. Then plots the test point in the phase
% diagram.
%
% Inputs:
%   testPoint = a (temperature, pressure) test point formatted as a 1x2 vector
% 	fusionCurve = function handle of the phase diagram's fusion curve
%   vaporCurve = function handle of the phase diagram's vaporization curve
%   subCurve = function handle of the phase diagram's sublimation curve
% 	criticalTemp = the critical temperature of the phase diagram
%   triplePointTemp = the temperature of the phase diagram's triple point
% Outputs:
%   phase = the phase of the given test point as a string
%
% Remember that the above function header is only a template and the names of any input and/or
% output variables can be changed, if desired.

    temperature = testPoint(1);
    pressure = testPoint(2);
    plot(temperature,pressure,'r*')
    
    if temperature >= criticalTemp
        phase = "gas";
        return
    end
    
    if temperature < triplePointTemp
        if subCurve(temperature) > pressure
            phase = "gas";
            return
        else
            phase = "solid";
            return
        end
    else
        if pressure > fusionCurve(temperature)
            phase = "solid";
            return
        elseif pressure > vaporCurve(temperature)
            phase = "liquid";
        else
            phase = "gas";
            return
        end
    end

    
end