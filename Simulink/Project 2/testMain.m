clear; clc; close all;

% Camera test
% cam = acquireImage("init");
% img = acquireImage(cam);

% image test
img = imread('board.png');

calib = calibrateBoard(img, true);      % 3 clicks
det   = fakeDetectByClick(img,24);% click 24 tile centers
det.colorId = randi([1 4], det.N, 1, 'uint8'); % fake colors for filtering

gameState = processBoardImage(img, calib, det);
% --- DEBUG COUNTS ---
secIds = [gameState.tiles.sectionId];
colIds = [gameState.tiles.colorId];

fprintf("Section counts: Soph=%d, Junior=%d, Senior=%d\n", ...
    sum(secIds==1), sum(secIds==2), sum(secIds==3));

fprintf("Color counts: Red=%d, Blue=%d, Purple=%d, Green=%d\n", ...
    sum(colIds==1), sum(colIds==2), sum(colIds==3), sum(colIds==4));

% table of counts per (section,color)
for s = 1:3
    for c = 1:4
        fprintf("sec %d, color %d: %d\n", s, c, sum(secIds==s & colIds==c));
    end
end
while true
    
    if ~queryAndDisplay(gameState), break; end
end

