clear; clc; close all;

gameState = buildHardcodedBoard();

model = "SpringMotorModel";
simCtl = startMotorExternal(model);

%% Dice section
cam = acquireImage("init");

disp("Ensure dice encloser is empty. Press any key...");
pause;
bgW = acquireImage(cam);

disp("Place die in enclosure. Press any key...");
pause;
diceImg = acquireImage(cam);

outDice = detectDiceTotal(diceImg, bgW, "ShowDebug", true);
fprintf("TOTAL = %d\n", outDice.total);

setThetaCmdDeg(simCtl, 20);
pause(2);
setThetaCmdDeg(simCtl, 0);
pause(2);

%% Query loop
while true
    [keepGoing, hits] = queryAndDisplayHardcoded(gameState);
    if ~keepGoing, break; end

    if numel(hits) < 2
        disp("Need at least 2 matches to alternate between two tiles.");
        continue;
    end

    [t1, t2] = chooseTwoTiles(hits);

    currentAngle = evalin("base","theta_cmd_deg");

    fprintf("Pointing to tile %d (%.1f deg)\n", t1.id, t1.thetaDeg);
    theta1 = nearestEquivAngle(t1.thetaDeg, currentAngle);
    setThetaCmdDeg(simCtl, theta1);
    pause(2);

    fprintf("Pointing to tile %d (%.1f deg)\n", t2.id, t2.thetaDeg);
    theta2 = nearestEquivAngle(t2.thetaDeg, theta1);
    setThetaCmdDeg(simCtl, theta2);
    pause(2);
end

stopMotorExternal(simCtl);