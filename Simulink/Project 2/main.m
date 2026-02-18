clear; clc; close all;

% Cam init + snapshot
cam = acquireImage("init");
img = acquireImage(cam);

% Calibration
calib = calibrateBoard(img);

% Detection
% Will pull from Endia's detection code
% For now fake it
det = fakeDetect(img, 24);

% Build gameState (angles + sections + results)
gameState = processBoardImage(img, calib, det);

% Query loop (CLI) 
while true
    keepGoing = queryAndDisplay(gameState);
    if ~keepGoing, break; end
end