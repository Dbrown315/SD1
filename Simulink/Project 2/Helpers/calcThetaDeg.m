function thetaDeg = calcThetaDeg(pt, center, thetaZeroDeg, thetaDir)
% Angle of pt about center, degrees in [0,360).
% Uses CCW positive, handles image y-down by flipping y.

    dx = pt(1) - center(1);
    dy = pt(2) - center(2);

    dy = -dy; % flip for image coordinates

    thetaDeg = atan2d(dy, dx);   % [-180,180]
    thetaDeg = mod(thetaDeg, 360);

    thetaDeg = mod(thetaDeg - thetaZeroDeg, 360);

    if thetaDir == "CW"
        thetaDeg = mod(360 - thetaDeg, 360);
    end
end
