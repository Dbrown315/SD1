%% Test file for mess with functions and ideas before implementing them in the main procesisng file/simulink
close all
clc
clear
clear('cam')
%% Check Camera List (may have to install MATLAB package)
cam_list = webcamlist
%% Assign webcam to be used
% Pick an index from the camera list above
cam_name = cam_list{2}
%% Check webcam properties
cam = webcam(cam_name)
cam.Saturation = 150;
%% Preview cam
preview(cam)
%% Close Preview
closePreview(cam)
%% Snapshot 1
img = snapshot(cam);
figure();
imshow(img)
title('Snapshot 1')
%% Snapshot 2
img2 = snapshot(cam);
figure();
imshow(img2)
title('Snapshot 2')