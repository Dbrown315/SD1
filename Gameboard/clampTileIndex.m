function idx = clampTileIndex(idx, Ntiles)
% Purpose: Limit tile index to board range.
    idx = max(1, min(idx, Ntiles));
end