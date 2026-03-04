clear; clc; close all;

cam = acquireImage("init");

disp("Place BLANK board (no colored tiles). Press any key...");
pause;
bg = acquireImage();

% Optional picture for debugging
% bg = imread("Project 2\Boards\Blank.jpg");

disp("Place COLORED board. Press any key...");
pause;
img = acquireImage();

% Optional picture for debugging
%img = imread("Project 2\Boards\Standard_Colored.jpg");

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

while true
    % queryAndDisplay should return hits
    [keepGoing, hits] = queryAndDisplay(gameState);
    if ~keepGoing, break; end

    if numel(hits) < 2
        disp("Need at lesat 2 matches to alternate between two tiles.");
    end

    [t1, t2] = chooseTwoTiles(hits);

    fprintf("Pointing to tile %d (%.1f deg)\n", t1.id, t1.thetaDeg);
    setThetaCmdDeg(simCtl, t1.thetaDeg);
    pause(2);

    fprintf("Pointing to tile %d (%.1f deg)\n", t2.id, t2.thetaDeg);
    setThetaCmdDeg(simCtl, t2.thetaDeg);
    pause(2);
end

stopMotorExternal(simCtl);