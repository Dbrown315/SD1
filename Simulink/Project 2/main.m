clear; clc; close all;

%cam = acquireImage("init");

disp("Place BLANK board (no colored tiles). Press any key...");
pause;
%bg = acquireImage(cam);

% Optional picture for debugging
bg = imread("Project 2\Boards\Blank.jpg");

disp("Place COLORED board. Press any key...");
pause;
%img = acquireImage(cam);

% Optional picture for debugging
img = imread("Project 2\Boards\Standard_Colored.jpg");

calib = calibrateBoard(img, false);

det = detectTileCentroids(bg, img, 24);

% Optional debug 
%figure; imshow(det.diffMag, []); title("diffMag");
%figure; imshow(det.mask); title("bg-sub mask");
%figure; imshow(img); hold on; plot(det.centroidsPx(:,1), det.centroidsPx(:,2), 'gx'); hold off;

[det.colorId, det.conf] = detectColorsAtCentroids(img, det.centroidsPx);

gameState = processBoardImage(img, calib, det);

model = "SpringMotorModel";
simCtl = startMotorExternal(model);

%% Dice

cam = acquireImage("init");

disp("Ensure dice encloser is empty. Press any key...");
pause;
bgW = acquireImage(cam);

disp("Place die in enclosure. Press any key...");
pause;

diceImg = acquireImage(cam);

outDice =detectDiceTotal(diceImg, bgW, "ShowDebug", true);

fprintf("TOTAL = %d\n", outDice.total);


setThetaCmdDeg(simCtl, 20);   % or 30
pause(2);
setThetaCmdDeg(simCtl, 0);
pause(2);


while true
    % queryAndDisplay should return hits
    [keepGoing, hits] = queryAndDisplay(gameState);
    if ~keepGoing, break; end

    if numel(hits) < 2
        disp("Need at least 2 matches to alternate between two tiles.");
        continue;
    end

    [t1, t2] = chooseTwoTiles(hits);


    currentAngle = evalin("base","theta_cmd_deg");

    fprintf("Pointing to tile %d (%.1f deg)\n", t1.id, t1.thetaDeg);
    theta1 = nearestEquivAngle(t1.thetaDeg,currentAngle);
    setThetaCmdDeg(simCtl, theta1);
    pause(2);

    fprintf("Pointing to tile %d (%.1f deg)\n", t2.id, t2.thetaDeg);
    theta2 = nearestEquivAngle(t2.thetaDeg,theta1);    
    setThetaCmdDeg(simCtl, theta2);
    pause(2);
end

stopMotorExternal(simCtl);