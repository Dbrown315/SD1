% Map thetaDeg to sectionID based on 3 boundary angles
function wedgeIdx = assignSection(thetaDeg, boundariesDeg)
    % boundariesDeg must be [b1 b2 b3] in wedge order from calibrateBoard
    b1 = mod(boundariesDeg(1),360);
    b2 = mod(boundariesDeg(2),360);
    b3 = mod(boundariesDeg(3),360);
    th = mod(thetaDeg,360);

    if inRangeWrap(th, b1, b2)
        wedgeIdx = 1;
    elseif inRangeWrap(th, b2, b3)
        wedgeIdx = 2;
    else
        wedgeIdx = 3;
    end
end

function tf = inRangeWrap(theta, a, b)
    if a <= b
        tf = (theta >= a) && (theta < b);
    else
        tf = (theta >= a) || (theta < b);
    end
end
