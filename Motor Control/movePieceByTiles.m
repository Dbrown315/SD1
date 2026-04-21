function [currentTileIdx, currentAngle, prevDir] = movePieceByTiles(simCtl, ...
    currentTileIdx, targetTileIdx, currentAngle, tile1StartCmdDeg, prevDir)
% Purpose: Move piece tile-by-tile to reduce fast large motions.
% Input:   simCtl, current tile, target tile, current angle,
%          tile 1 command angle, previous move direction
% Output:  updated tile index, angle, and previous direction

    stepPause = 0.1;

    while currentTileIdx ~= targetTileIdx
        if targetTileIdx > currentTileIdx
            nextTileIdx = currentTileIdx + 1;
        else
            nextTileIdx = currentTileIdx - 1;
        end

        [currentTileIdx, currentAngle, prevDir] = movePieceToTile(simCtl, ...
            nextTileIdx, currentAngle, tile1StartCmdDeg, prevDir);

        pause(stepPause);
    end
end