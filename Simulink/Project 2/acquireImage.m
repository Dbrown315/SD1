% Camera only code. Initializes the webcam or returns a single snapshot
function out = acquireImage(arg)
    if isstring(arg) && arg == "init"
        cams = webcamlist;
        cam = webcam(cams{2}); % for a device with an integrated cam thee webcam is #2. change if needed
        
        pause(.2) %Maybe needed if camera needs time to initialize to take
        % a good picture
        
        cam.Resolution = '640x480';
        cam.Saturation = 125; % makes the colors pop more and hopefully makes detection a little easier, default 100
        cam.Brightness = 128; % default 128
        cam.Contrast = 100;
        cam.Sharpness = 100;
        cam.ExposureMode = 'manual';
        cam.Exposure = -6;
        out = cam;
        return;
    end

    cam = arg;
    out = snapshot(cam);
end