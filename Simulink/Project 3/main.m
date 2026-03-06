clear; clc; close all;

cam = acquireImage("init");
%RGB = imread('Blank.jpg');
%RGBs = imread('Standard_Colored.jpg');

disp("Place BLANK board (no colored tiles). Press any key...");
pause;
bg = acquireImage(cam); 


%disp("Place COLORED board. Press any key...");
%pause;
%img = acquireImage(cam);


%calib = calibrateBoard(img, false);

%det = detectTileCentroids(bg, img, 24);

% debug 
%figure; imshow(det.diffMag, []); title("diffMag");
%figure; imshow(det.mask); title("bg-sub mask");
%figure; imshow(img); hold on; plot(det.centroidsPx(:,1), det.centroidsPx(:,2), 'gx'); hold off;

%[det.colorId, det.conf] = detectColorsAtCentroids(img, det.centroidsPx);


%%
% Milestone 3: Dice pip detection
disp("PART 2: Place backside of BLANK board, then place die on it. Press any key...");
pause;

diceImg = acquireImage(cam);

outDice =detectDiceTotal(diceImg, bg, "ShowDebug", true);

fprintf("TOTAL = %d\n", outDice.total);



%[totalPips, diePips, dbg] = detectDicePips_total(diceImg, "ShowDebug", true);

%fprintf("TOTAL = %d\n", totalPips);


%%

%gameState = processBoardImage(img, calib, det);

%while true
%    if ~queryAndDisplay(gameState), break; end
%end
