function [currentAngle, zeroOffsetDeg] = manualZeroCalibration(simCtl, ui)
% Purpose: Let the user jog the motor until the pointer is physically at 0 deg.
% Input:   simCtl handle and GUI handle struct.
% Output:  current commanded angle and zero offset in degrees.

    smallStep = 5;
    largeStep = 15;
    currentAngle = 0;

    % Move to the current reset position first.
    setThetaCmdDeg(simCtl, currentAngle, "dc");
    assignin("base", "theta_cmd_deg", currentAngle);
    pause(1.5);

    disp("Manual 0 deg calibration controls:");
    disp("  k = small CCW step");
    disp("  j = small CW step");
    disp("  K = large CCW step");
    disp("  J = large CW step");
    disp("  s = save current position as physical 0 deg");

    while true
        prompt = sprintf('Current command %.1f deg. Enter j/k/J/K/s: ', currentAngle);
        resp = input(prompt, 's');
        resp = strtrim(resp);

        if isempty(resp)
            continue;
        end

        switch resp
            case 'j'
                currentAngle = currentAngle - smallStep;
            case 'k'
                currentAngle = currentAngle + smallStep;
            case 'J'
                currentAngle = currentAngle - largeStep;
            case 'K'
                currentAngle = currentAngle + largeStep;
            case {'s', 'S'}
                zeroOffsetDeg = currentAngle;
                updateGameStatus(ui, ...
                    sprintf("Calibrated physical 0 deg at command %.1f deg.", zeroOffsetDeg), ...
                    "Roll: -", ...
                    "Calibration saved. The game will now use this as the board's 0 deg reference.");
                drawnow;
                pause(1);
                return;
            otherwise
                disp("Invalid input. Use j, k, J, K, or s.");
                continue;
        end

        updateGameStatus(ui, ...
            sprintf("Manual 0 deg calibration: current command %.1f deg", currentAngle), ...
            "Roll: -", ...
            "Use j/k for small steps, J/K for large steps, s to save the current position as 0 deg.");
        drawnow;

        setThetaCmdDeg(simCtl, currentAngle, "dc");
        assignin("base", "theta_cmd_deg", currentAngle);
        pause(0.8);
    end
end