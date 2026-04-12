clear; clc; close all;

cam = acquireImage("init");

disp("Place die in rolling station and press any key");
pause;

diceImg = acquireImage(cam);

outDice = detectDiceTotal_singleImage(diceImg, "ShowDebug", true);

fprintf("TOTAL = %d\n", outDice.total);