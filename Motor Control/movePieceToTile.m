function [newTileIdx, currentAngle] = movePieceToTile(simCtl, ...
    targetTileIdx, currentAngle, tile1StartCmdDeg)
% Purpose: Move the piece using tile 1 as the calibrated starting point
%          and a fixed 15 deg step per tile.
% Input:   simCtl handle, target tile index, current commanded angle, and
%          calibrated tile 1 command angle.
% Output:  new tile index and updated current command angle.

    tileStepDeg = 15;

    targetAngle = tile1StartCmdDeg - (targetTileIdx - 1) * tileStepDeg;

    cmdAngle = nearestEquivAngle(targetAngle, currentAngle);
    setThetaCmdDeg(simCtl, cmdAngle, "dc");
    pause(2);

    newTileIdx = targetTileIdx;
    currentAngle = cmdAngle;
end
