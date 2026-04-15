function [currentTileIdx, currentAngle] = movePieceToTile(simCtl, gameState, ...
    currentTileIdx, targetTileIdx, currentAngle, zeroOffsetDeg)

% Purpose: Move DC motor pointer to a target tile.
% Input:   simCtl, board state, current tile, target tile,
%          current commanded angle, zero offset
% Output:  updated tile index and updated angle

    targetTile = gameState.tiles(targetTileIdx);
    targetAngle = targetTile.thetaDeg + zeroOffsetDeg;

    cmdAngle = nearestEquivAngle(targetAngle, currentAngle);
    setThetaCmdDeg(simCtl, cmdAngle, "dc");
    pause(2);

    currentTileIdx = targetTileIdx;
    currentAngle = cmdAngle;
end