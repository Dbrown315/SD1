function hits = getMatchingTiles(gameState, colorId, sectionId)
% Filter tiles by color + section
    tiles = gameState.tiles;
    mask = arrayfun(@(t) t.colorId==colorId && t.sectionId==sectionId, tiles);
    hits = tiles(mask);
end