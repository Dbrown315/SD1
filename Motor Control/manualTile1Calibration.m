function [currentAngle, tile1StartCmdDeg] = manualTile1Calibration(simCtl, ui)
% Purpose: Let the user jog the motor until the pointer is physically at tile 1.
% Input:   simCtl handle and GUI handle struct.
% Output:  current commanded angle and zero offset in degrees.

    smallStep = 5;
    largeStep = 15;
    currentAngle = 0;

    % Move to the current reset position first.
    setThetaCmdDeg(simCtl, currentAngle, "dc");
    pause(1.5);

    disp("Manual tile 1 calibration controls:");
    disp("  k = small CCW step");
    disp("  j = small CW step");
    disp("  K = large CCW step");
    disp("  J = large CW step");
    disp("  s = save current position as physical tile 1 position");

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
                tile1StartCmdDeg = currentAngle;
                updateGameStatus(ui, ...
                    sprintf("Calibrated tile 1 at command %.1f deg.", tile1StartCmdDeg), ...
                    "Roll: -", ...
                    "Calibration saved. The game will now use this as the tile 1 starting reference.");
                drawnow;
                pause(1);
                return;
            otherwise
                disp("Invalid input. Use j, k, J, K, or s.");
                continue;
        end

        updateGameStatus(ui, ...
            sprintf("Manual tile 1 calibration: current command %.1f deg", currentAngle), ...
            "Roll: -", ...
            "Use j/k for small steps, J/K for large steps, s to save the current position as tile 1 position.");
        drawnow;

        setThetaCmdDeg(simCtl, currentAngle, "dc");
        pause(0.8);
    end
end