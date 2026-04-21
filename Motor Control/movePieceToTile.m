function [newTileIdx, currentAngle, prevDir] = movePieceToTile(simCtl, ...
    targetTileIdx, currentAngle, tile1StartCmdDeg, prevDir)
% Purpose: Move the piece using tile 1 as the calibrated starting point
%          and a fixed 15 deg step per tile, with backlash compensation
%          on directoin change
% Input:   simCtl handle, target tile index, current commanded angle, and
%          calibrated tile 1 command angle, and previous move direction
% Output:  new tile index, updated current command angle, updated prevDir

    tileStepDeg = 15;
    backlashCompDeg = 7.5;

    % Ideal commanded angle for this tile
    targetAngle = tile1StartCmdDeg - (targetTileIdx - 1) * tileStepDeg;

    % Pick the closest equivalent angle to where the motor is now
    cmdAngle = nearestEquivAngle(targetAngle, currentAngle);

    delta = cmdAngle - currentAngle;

    if abs(delta) < 0.01
        newTileIdx = targetTileIdx;
        return;
    end

    newDir = sign(delta);


    % Apply compensation only when direction changes
    if prevDir ~= 0 && newDir ~= prevDir
        cmdAngle = cmdAngle + newDir * backlashCompDeg;
    end

    setThetaCmdDeg(simCtl, cmdAngle, "dc");
    pause(.75);

    newTileIdx = targetTileIdx;
    currentAngle = cmdAngle;
    prevDir = newDir;
end
