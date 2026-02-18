clear; clc; close all;

img = imread("board.png");

calib = calibrateBoard(img, true);      % 3 clicks
det   = fakeDetectByClick(img,24);% click 24 tile centers
det.colorId = randi([1 4], det.N, 1, 'uint8'); % fake colors for filtering

gameState = processBoardImage(img, calib, det);

while true
    
    if ~queryAndDisplay(gameState), break; end
end

