function setThetaCmdDeg(simCtl, cmdDeg, targetName)
% Purpose: Update either the DC motor command or servo command in External mode.
% Input:   simCtl     = controller struct with model name.
%          cmdDeg     = command value in degrees.
%          targetName = "dc" or "servo".
% Output:  none.

    if nargin < 3
        targetName = "dc";
    end

    targetName = string(targetName);

    switch lower(targetName)
        case "dc"
            assignin("base", "theta_cmd_deg", double(cmdDeg));

        case "servo"
            assignin("base", "servo_cmd_deg", double(cmdDeg));

        otherwise
            error("targetName must be 'dc' or 'servo'.");
    end

    set_param(simCtl.model, "SimulationCommand", "update");
end