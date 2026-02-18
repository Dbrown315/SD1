function calib = calibrateBoard(img)
    f = figure('Name','Calibration','NumberTitle','off');
    imshow(img);
    title(["Click CENTER", ...
           "Then click ANY boundary line", ...
           "Then click INSIDE the Sophomore wedge"], ...
           'FontWeight','bold');

    % ---- 3 clicks ----
    [x,y] = ginput(3);

    center     = [x(1) y(1)];
    boundaryPt = [x(2) y(2)];
    sophPt     = [x(3) y(3)];

    % ---- Angle convention ----
    thetaZeroDeg = 0;
    thetaDir = "CCW";

    % Define boundaries in WEDGE ORDER (CCW):
    % Wedge1: [b1,b2), Wedge2: [b2,b3), Wedge3: [b3,b1) wrap
    b1 = calcThetaDeg(boundaryPt, center, thetaZeroDeg, thetaDir);
    b2 = mod(b1 + 120, 360);
    b3 = mod(b1 + 240, 360);
    boundaries = [b1 b2 b3];

    % Soph click angle
    thSoph = calcThetaDeg(sophPt, center, thetaZeroDeg, thetaDir);

    % Which wedge contains Soph click?
    if inRangeWrap(thSoph, b1, b2)
        sophWedge = 1;
    elseif inRangeWrap(thSoph, b2, b3)
        sophWedge = 2;
    else
        sophWedge = 3;
    end

    % ---- Labeling rule you wanted ----
    % "Going CW from Sophomore, it hits Senior first."
    %
    % Since wedge indices increase CCW (1->2->3->1),
    % the CW neighbor is the PREVIOUS wedge index.
    cwNext = @(w) mod(w - 2, 3) + 1;   % 1->3->2->1
    
    juniorWedge = cwNext(sophWedge);   % next CW from Soph
    seniorWedge = cwNext(juniorWedge); % next CW after Junior
    
    wedgeToSectionId = zeros(1,3,'uint8');
    wedgeToSectionId(sophWedge)   = uint8(1); % Sophomore
    wedgeToSectionId(juniorWedge) = uint8(2); % Junior
    wedgeToSectionId(seniorWedge) = uint8(3); % Senior

    % ---- Overlay (keep figure open) ----
    hold on;

    % mark center
    plot(center(1), center(2), 'yx', 'MarkerSize', 12, 'LineWidth', 2);

    % boundary rays
    L = 1000;
    for ang = boundaries
        dx = cosd(ang);
        dy = -sind(ang); % image y-down
        plot([center(1) center(1)+L*dx], [center(2) center(2)+L*dy], 'y-', 'LineWidth', 2);
    end

    % label wedge centers with Soph/Jun/Sen
    wedgeCenters = mod(boundaries + 60, 360); % midpoint of each wedge
    labels = strings(1,3);
    labels(wedgeToSectionId==1) = "Soph";
    labels(wedgeToSectionId==2) = "Junior";
    labels(wedgeToSectionId==3) = "Senior";

    for i = 1:3
        ang = wedgeCenters(i);
        dx = cosd(ang); dy = -sind(ang);
        text(center(1)+220*dx, center(2)+220*dy, labels(i), ...
            'Color','y','FontSize',14,'FontWeight','bold');
    end

    hold off;
    title("Calibration overlay (close this window when satisfied)");

    fprintf("Calibration: boundaries=[%.1f %.1f %.1f], wedgeToSectionId=[%d %d %d]\n", ...
        boundaries(1), boundaries(2), boundaries(3), ...
        wedgeToSectionId(1), wedgeToSectionId(2), wedgeToSectionId(3));

    disp("Press any key to continue...");
    pause;


    % ---- Pack outputs ----
    calib = struct();
    calib.centerPx = center;
    calib.thetaZeroDeg = thetaZeroDeg;
    calib.thetaDir = thetaDir;
    calib.sectionBoundariesDeg = boundaries;     % [b1 b2 b3] wedge order
    calib.wedgeToSectionId = wedgeToSectionId;   % wedgeIdx -> sectionId
    calib.sectionNames = ["Sophomore","Junior","Senior"];
end

function tf = inRangeWrap(theta, a, b)
    theta = mod(theta,360); a = mod(a,360); b = mod(b,360);
    if a <= b
        tf = (theta >= a) && (theta < b);
    else
        tf = (theta >= a) || (theta < b);
    end
end
