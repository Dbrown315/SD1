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
setThetaCmdDeg(simCtl, cmdAngle, "dc");
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

    % Servo Control
    setThetaCmdDeg(simCtl, 15,"servo");
    pause(2)
    setThetaCmdDeg(simCtl, 0, "servo");
    pause(1)

    diceImg = acquireImage(cam);
    outDice = detectDiceTotal_singleImage(diceImg, "ShowDebug", true);
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
    setThetaCmdDeg(simCtl, cmdAngle, "dc");
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

    pause(1.5);
end

%% Game finish message
updateGameStatus(ui, "Congratulations! You've graduated!", ui.RollLabel.Text, ...
    "The game is finished.");
drawnow;
pause(5);

%% Return to calibrated zero before exit
try
    cmdAngle = nearestEquivAngle(zeroOffsetDeg, currentAngle);
    setThetaCmdDeg(simCtl, cmdAngle, "dc");
    pause(2);
    stopMotorExternal(simCtl);
catch 
    disp('Error while trying to return motor to 0 degree point')
end

close(ui.Fig);











