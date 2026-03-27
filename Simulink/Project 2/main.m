clear; clc; close all;

%% Build board
gameState = buildHardcodedBoard();
Ntiles = gameState.N;

%% Start motor and force safe shutdown
model = "SpringMotorModel";
simCtl = startMotorExternal(model);

%% Initialize camera for dice
cam = acquireImage("init");

%% Capture empty dice enclosure once before game starts
disp("Ensure dice enclosure is empty. Press any key...");
pause;
bgW = acquireImage(cam);

%% Initialize motor to zero
disp("Initializing motor to 0 deg...");
setThetaCmdDeg(simCtl, 0);
assignin("base","theta_cmd_deg",0);
pause(2);

disp("Calibrate pointer so that 0 deg is aligned correctly.");
resp = input('Press Enter when ready to move to tile 1, or type q to quit: ', 's');
if strcmpi(strtrim(resp), 'q')
    stopMotorExternal(simCtl);
    return;
end

%% Start game at tile 1
currentTileIdx = 1;
currentAngle = 0;

tile1Angle = gameState.tiles(currentTileIdx).thetaDeg;
cmdAngle = nearestEquivAngle(tile1Angle, currentAngle);

fprintf("Moving to tile %d (%.1f deg)\n", ...
    gameState.tiles(currentTileIdx).id, gameState.tiles(currentTileIdx).thetaDeg);
setThetaCmdDeg(simCtl, cmdAngle);
currentAngle = cmdAngle;
pause(2);

%% Main roll loop
while true
    resp = input('Press Enter to roll, or type q to quit: ', 's');
    if strcmpi(strtrim(resp), 'q')
        break;
    end
    diceImg = acquireImage(cam);

    outDice = detectDiceTotal(diceImg, bgW, "ShowDebug", true);
    roll = outDice.total;

    fprintf("Rolled: %d\n", roll);

    if isempty(roll) || ~isscalar(roll) || ~isfinite(roll) || roll < 1
        disp("Dice read failed. Try again.");
        continue;
    end

    currentTileIdx = mod((currentTileIdx - 1) + roll, Ntiles) + 1;

    targetTile = gameState.tiles(currentTileIdx);
    targetAngle = targetTile.thetaDeg;

    fprintf("Moving to tile %d (%.1f deg)\n", targetTile.id, targetAngle);

    cmdAngle = nearestEquivAngle(targetAngle, currentAngle);
    setThetaCmdDeg(simCtl, cmdAngle);
    currentAngle = cmdAngle;

    pause(2);
end

%% Return to zero before exit
disp("Returning motor to 0 deg...");
cmdAngle = nearestEquivAngle(0, currentAngle);
setThetaCmdDeg(simCtl, cmdAngle);
pause(2);

stopMotorExternal(simCtl);

disp("Done.");
