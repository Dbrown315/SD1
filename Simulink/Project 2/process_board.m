%{
Specifically for project 2, the processing engine must be able to automatically identify the number, 
positions (pixel coords), shapes, and colors of spots on the game board.

Specifically for the demo we are required to have a game state structure
and various outputs.
The struct should contain:
Color and location of each identified colored sticker (space)
Location (pixel coords) of the centroid of each identified space
Images used for analysis:
- Original (background) Image
- Current image
- Differential Image
- Difference after noise removal and enhancement of foreground objects
- Additional outputs from processing
%}

%% Initialize gameState struct
clear; clc; close all;
% Constants
gameState.N = 24;

% Camera Config
gameState.camera.resolution = [640 480]; % [width height]
gameState.camera.format = 'MJPG_640x480';

% FOV Setup // Needs to be measured in lab (need to figure out where camera
% will be situated to have a consistent FOV
gameState.camera.FOV = [11 8]; % [w x h] in inches
gameState.camera.pxPerIn = ...
    gameState.camera.resolution(1) / gameState.camera.FOV(1);

gameState.camera.inPerPx = ...
    gameState.camera.FOV(1) / gameState.camera.resolution(1);

% Color key
gameState.colorkey = table(...
    uint8([0, 1, 2, 3, 4])', ...
    ["Unknown","Red","Blue","Purple","Green"]', ...
    'VariableNames', {'id','name'});

% Section key
gameState.sectionkey = table(...
    uint8([1, 2, 3])', ...
    ["Sophomore","Junior","Senior"]', ...
    'VariableNames', {'id','name'});

% Board Geometry
% Angles for each space 
gameState.spaceAngleDeg = (0:gameState.N-1) * (360/gameState.N); % 0,15,30,...345

% Pixel locations
% size: 24x2, columns = [x y], will be centroid
gameState.spaceCenterPx = nan(gameState.N, 2);

% board center?? Not sure if this will be useful
gameState.boardCenterPx = [nan nan];
gameState.boardRadiusPx = nan;






