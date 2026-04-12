clear; clc; close all;

%% Create status window
ui = createGameStatusGUI();
updateGameStatus(ui, "Initializing board...", "Roll: -", "Scenario will appear here.");

%% Build board
gameState = buildHardcodedBoard();
Ntiles = gameState.N;

%% Start motor and force safe shutdown
model = "SpringMotorModel";
updateGameStatus(ui, "Starting motor controller...", "Roll: -", "Scenario will appear here.");
drawnow;
simCtl = startMotorExternal(model);

%% Initialize camera for dice
updateGameStatus(ui, "Initializing camera...", "Roll: -", "Scenario will appear here.");
drawnow;
cam = acquireImage("init");

%% Capture empty dice enclosure once before game starts
updateGameStatus(ui, "Ensure dice enclosure is empty, then press any key in the Command Window.", "Roll: -", "Scenario will appear here.");
drawnow;
disp("Ensure dice enclosure is empty. Press any key...");
pause;
bgW = acquireImage(cam);

%% Manual zero calibration
updateGameStatus(ui, ...
    "Manual 0 deg calibration: use j/k to rotate, s to save current position as 0 deg.", ...
    "Roll: -", ...
    "In the Command Window: j = small CCW step, k = small CW step, J = large CCW step, K = large CW step, s = save current position.");
drawnow;

[currentAngle, zeroOffsetDeg] = manualZeroCalibration(simCtl, ui);

%% Start game at tile 1
currentTileIdx = 1;

tile1Angle = gameState.tiles(currentTileIdx).thetaDeg + zeroOffsetDeg;
cmdAngle = nearestEquivAngle(tile1Angle, currentAngle);

updateGameStatus(ui, sprintf("Moving to tile %d (%.1f deg)...", ...
    gameState.tiles(currentTileIdx).id, gameState.tiles(currentTileIdx).thetaDeg), ...
    "Roll: -", "Scenario will appear here.");
drawnow;
setThetaCmdDeg(simCtl, cmdAngle);
currentAngle = cmdAngle;
pause(2);

%% Display scenario for tile 1
yearStr = sectionIdToString(gameState.tiles(currentTileIdx).sectionId);
colorStr = colorIdToString(gameState.tiles(currentTileIdx).colorId);
scenario_string = get_scenario(yearStr, colorStr);

updateGameStatus(ui, sprintf("Tile %d: %s %s", ...
    gameState.tiles(currentTileIdx).id, yearStr, colorStr), ...
    "Roll: -", scenario_string);
drawnow;
pause(5);

%% Main automatic roll loop
while currentTileIdx < Ntiles
    updateGameStatus(ui, "Rolling dice...", ui.RollLabel.Text, ui.ScenarioArea.Value);
    drawnow;
    pause(1);

    diceImg = acquireImage(cam);
    outDice = detectDiceTotal(diceImg, bgW, "ShowDebug", false);
    roll = outDice.total;

    if isempty(roll) || ~isscalar(roll) || ~isfinite(roll) || roll < 1
        updateGameStatus(ui, "Dice read failed. Trying again...", "Roll: invalid", ...
            "The last dice read failed. The system will try again automatically.");
        drawnow;
        pause(2);
        continue;
    end

    nextTileIdx = currentTileIdx + roll;
    if nextTileIdx >= Ntiles
        currentTileIdx = Ntiles;
    else
        currentTileIdx = nextTileIdx;
    end

    targetTile = gameState.tiles(currentTileIdx);
    targetAngle = targetTile.thetaDeg + zeroOffsetDeg;

    updateGameStatus(ui, sprintf("Moving to tile %d (%.1f deg)...", targetTile.id, targetTile.thetaDeg), ...
        sprintf("Roll: %d", roll), ui.ScenarioArea.Value);
    drawnow;

    cmdAngle = nearestEquivAngle(targetAngle, currentAngle);
    setThetaCmdDeg(simCtl, cmdAngle);
    currentAngle = cmdAngle;
    pause(2);

    yearStr = sectionIdToString(targetTile.sectionId);
    colorStr = colorIdToString(targetTile.colorId);
    scenario_string = get_scenario(yearStr, colorStr);

    updateGameStatus(ui, sprintf("Tile %d: %s %s", targetTile.id, yearStr, colorStr), ...
        sprintf("Roll: %d", roll), scenario_string);
    drawnow;

    if currentTileIdx == Ntiles
        break;
    end

    pause(5);
end

%% Game finish message
updateGameStatus(ui, "Congratulations! You've graduated!", ui.RollLabel.Text, ...
    "The game is finished.");
drawnow;
pause(5);

%% Return to calibrated zero before exit
updateGameStatus(ui, "Returning motor to calibrated 0 deg...", ui.RollLabel.Text, ui.ScenarioArea.Value);
drawnow;
cmdAngle = nearestEquivAngle(zeroOffsetDeg, currentAngle);
setThetaCmdDeg(simCtl, cmdAngle);
pause(2);

stopMotorExternal(simCtl);
updateGameStatus(ui, "Done.", ui.RollLabel.Text, ui.ScenarioArea.Value);
drawnow;


function ui = createGameStatusGUI()
% Purpose: Create a simple hands-off status window for the board game.
% Input:   none.
% Output:  ui struct containing the GUI handles.

    ui.Fig = uifigure('Name', 'Board Game Status', ...
        'Position', [100 100 700 420]);

    ui.StatusLabel = uilabel(ui.Fig, ...
        'Position', [20 375 650 30], ...
        'FontSize', 16, ...
        'Text', 'Starting...');

    ui.RollLabel = uilabel(ui.Fig, ...
        'Position', [20 335 650 25], ...
        'FontSize', 15, ...
        'Text', 'Roll: -');

    ui.ScenarioTitle = uilabel(ui.Fig, ...
        'Position', [20 300 200 25], ...
        'FontSize', 15, ...
        'Text', 'Scenario');

    ui.ScenarioArea = uitextarea(ui.Fig, ...
        'Position', [20 20 650 275], ...
        'Editable', 'off', ...
        'FontSize', 14, ...
        'Value', {'Scenario will appear here.'});
end


function updateGameStatus(ui, statusText, rollText, scenarioText)
% Purpose: Update all text shown in the status GUI.
% Input:   ui struct, status text, roll text, and scenario text.
% Output:  none.

    ui.StatusLabel.Text = string(statusText);
    ui.RollLabel.Text = string(rollText);

    if isstring(scenarioText) || ischar(scenarioText)
        ui.ScenarioArea.Value = cellstr(string(scenarioText));
    else
        ui.ScenarioArea.Value = scenarioText;
    end

    drawnow;
end


function [currentAngle, zeroOffsetDeg] = manualZeroCalibration(simCtl, ui)
% Purpose: Let the user jog the motor until the pointer is physically at 0 deg.
% Input:   simCtl handle and GUI handle struct.
% Output:  current commanded angle and zero offset in degrees.

    smallStep = 5;
    largeStep = 15;
    currentAngle = 0;

    % Move to the current reset position first.
    setThetaCmdDeg(simCtl, currentAngle);
    assignin("base", "theta_cmd_deg", currentAngle);
    pause(1.5);

    disp("Manual 0 deg calibration controls:");
    disp("  j = small CCW step");
    disp("  k = small CW step");
    disp("  J = large CCW step");
    disp("  K = large CW step");
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

        setThetaCmdDeg(simCtl, currentAngle);
        assignin("base", "theta_cmd_deg", currentAngle);
        pause(0.8);
    end
end
