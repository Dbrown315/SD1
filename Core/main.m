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
    "Manual tile 1 calibration: use j/k to rotate, s to save current position as starting tile.", ...
    "Roll: -", ...
    "In the Command Window: j = small CCW step, k = small CW step, J = large CCW step, K = large CW step, s = save current position.");
drawnow;

[currentAngle, tile1StartCmdDeg] = manualTile1Calibration(simCtl, ui);

%% Start game at tile 1
currentTileIdx = 1;

tileStepDeg = 15;
targetAngle = tile1StartCmdDeg + (currentTileIdx - 1) * tileStepDeg;
cmdAngle = nearestEquivAngle(targetAngle, currentAngle);

updateGameStatus(ui, sprintf("Moving to tile %d (%.1f deg)...", ...
    gameState.tiles(currentTileIdx).id, gameState.tiles(currentTileIdx).thetaDeg), ...
    "Roll: -", "Scenario will appear here.");
drawnow;
setThetaCmdDeg(simCtl, cmdAngle, "dc");
currentAngle = cmdAngle;
pause(1);

%% Display scenario for tile 1
yearStr = sectionIdToString(gameState.tiles(currentTileIdx).sectionId);
colorStr = colorIdToString(gameState.tiles(currentTileIdx).colorId);
scenario_string = get_scenario(yearStr, colorStr);

updateGameStatus(ui, sprintf("Tile %d: %s %s", ...
    gameState.tiles(currentTileIdx).id, yearStr, colorStr), ...
    "Roll: -", scenario_string);
drawnow;

%% Main game loop
prevDir = 0;
while currentTileIdx < Ntiles && isvalid(ui.Fig)

    updateGameStatus(ui, ...
        "Press the Rolle Die button to take the next turn.", ...
        ui.RollLabel.Text, ...
        ui.ScenarioArea.Value, ...
        sprintf("Current Tile: %d / %d", currentTileIdx, Ntiles), ...
        "");

    waitForRollButton(ui);

    if ~isvalid(ui.Fig)
        break;
    end
   
    %% Roll the die with servo
    updateGameStatus(ui, ...
        "Rolling die...", ...
        "Roll: ...", ...
        "Rolling in progress.", ...
        sprintf("Current Tile: %d / %d", currentTileIdx, Ntiles), ...
        "");
    
    setThetaCmdDeg(simCtl, 15,"servo");
    pause(2)
    setThetaCmdDeg(simCtl, 0, "servo");
    pause(1)

    %% Read the die
    diceImg = acquireImage(cam);
    outDice = detectDiceTotal_singleImage(diceImg, "ShowDebug", false);
    roll = outDice.total;

    if isempty(roll) || ~isscalar(roll) || ~isfinite(roll) || roll < 1
        updateGameStatus(ui, ...
            "Dice read failed", ...
            "Roll: invalid", ...
            "Press Roll Die to try again.", ...
            sprintf("Current Tile: %d / %d", currentTileIdx, Ntiles), ...
            "");
        continue;
    end

    %% Move based on die roll
    rolledTileIdx = clampTileIndex(currentTileIdx + roll, Ntiles);
    
    updateGameStatus(ui, ...
        sprintf("Moving to tile %d", rolledTileIdx), ...
        sprintf("Roll: %d", roll), ...
        "Applying die result.", ...
        sprintf("Current Tile: %d / %d", rolledTileIdx, Ntiles), ...
        "");

    [currentTileIdx, currentAngle, prevDir] = movePieceToTile(simCtl, ...
        rolledTileIdx, currentAngle, tile1StartCmdDeg, prevDir);

    %% Read Landed Tile
    landedTile = gameState.tiles(currentTileIdx);
    yearStr = sectionIdToString(landedTile.sectionId);
    colorStr = colorIdToString(landedTile.colorId);

    %% Scenario movement
    [scenarioMove, ruleText] = getScenarioAction(colorStr);
    
    %% Scenario flavor text
    flavorText = get_scenario(yearStr, colorStr);

    scenarioMsg = sprintf("%s\n%s", ruleText, flavorText);

    updateGameStatus(ui, ...
        sprintf("Landed on tile %d: %s %s", currentTileIdx, yearStr, colorStr), ...
        sprintf("Roll: %d", roll), ...
        scenarioMsg, ...
        sprintf("Current Tile: %d / %d", currentTileIdx, Ntiles), ...
        "");

    pause(2);

    %% Apply scenario movement unless at finish
    if currentTileIdx < Ntiles
        scenarioTileIdx = clampTileIndex(currentTileIdx + scenarioMove, Ntiles);

        if scenarioTileIdx ~= currentTileIdx
            updateGameStatus(ui, ...
                sprintf("Applying scenario. Moving to tile %d...", scenarioTileIdx), ...
                sprintf("Roll: %d", roll), ...
                scenarioMsg, ...
                sprintf("Current Tile: %d / %d", scenarioTileIdx, Ntiles), ...
                "");

            [currentTileIdx, currentAngle, prevDir] = movePieceToTile(simCtl, ...
                scenarioTileIdx, currentAngle, tile1StartCmdDeg, prevDir);
        end
    end
end

%% Game finish message
ui.CompleteLamp.Color = [0 1 0]; % green

updateGameStatus(ui, ...
    "Game complete.", ...
    ui.RollLabel.Text, ...
    "The game is finished.", ...
    sprintf("Current Tile: %d / %d", currentTileIdx, Ntiles), ...
    "Congratulations! You've graduated!");
pause(5);

%% Return to calibrated tile 1 start before exit
try
    cmdAngle = nearestEquivAngle(tile1StartCmdDeg, currentAngle);
    setThetaCmdDeg(simCtl, cmdAngle, "dc");
    pause(2);
    stopMotorExternal(simCtl);
catch 
    disp('Error while trying to return motor to tile 1')
end

close(ui.Fig);











