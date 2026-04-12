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

%% Initialize motor to zero
updateGameStatus(ui, "Initializing motor to 0 deg...", "Roll: -", "Scenario will appear here.");
drawnow;
setThetaCmdDeg(simCtl, 0);
assignin("base", "theta_cmd_deg", 0);
pause(2);

%% Calibration step before automatic play
updateGameStatus(ui, "Calibrate pointer so that 0 deg is aligned correctly. Press Enter in the Command Window when ready.", "Roll: -", "Scenario will appear here.");
drawnow;
disp("Calibrate pointer so that 0 deg is aligned correctly.");
input('Press Enter when ready to start the game: ', 's');

%% Start game at tile 1
currentTileIdx = 1;
currentAngle = 0;

tile1Angle = gameState.tiles(currentTileIdx).thetaDeg;
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
    targetAngle = targetTile.thetaDeg;

    updateGameStatus(ui, sprintf("Moving to tile %d (%.1f deg)...", targetTile.id, targetAngle), ...
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

%% Return to zero before exit
updateGameStatus(ui, "Returning motor to 0 deg...", ui.RollLabel.Text, ui.ScenarioArea.Value);
drawnow;
cmdAngle = nearestEquivAngle(0, currentAngle);
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
