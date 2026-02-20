clear; clc; close all;

% Cam init + snapshot
cam = acquireImage("init");
img = acquireImage(cam);

% Calibration
% T/F for overlay
calib = calibrateBoard(img, false);

% Detection
det = detectTiles(img);
figure('Name','Centroid Debug'); imshow(img); hold on;
plot(det.centroidsPx(:,1), det.centroidsPx(:,2), 'gx', 'MarkerSize', 12, 'LineWidth', 2);
title(sprintf("Detected centroids: %d", det.N));
hold off;

figure('Name','Tile Mask'); imshow(det.mask);
title("Mask used for blob detection");

% Build gameState (angles + sections + results)
gameState = processBoardImage(img, calib, det);

% Query loop (CLI) 
while true
    keepGoing = queryAndDisplay(gameState);
    if ~keepGoing, break; end
end