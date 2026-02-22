clear; clc; close all;

cam = acquireImage("init");

disp("Place BLANK board (no colored tiles). Press any key...");
pause;
bg = acquireImage(cam);

disp("Place COLORED board. Press any key...");
pause;
img = acquireImage(cam);

calib = calibrateBoard(img, false);

det = detectTileCentroids(bg, img, 24);

% Optional debug 
%figure; imshow(det.diffMag, []); title("diffMag");
%figure; imshow(det.mask); title("bg-sub mask");
%figure; imshow(img); hold on; plot(det.centroidsPx(:,1), det.centroidsPx(:,2), 'gx'); hold off;

[det.colorId, det.conf] = detectColorsAtCentroids(img, det.centroidsPx);

gameState = processBoardImage(img, calib, det);

while true
    if ~queryAndDisplay(gameState), break; end
end