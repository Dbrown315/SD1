function [keepGoing, hits] = queryAndDisplayHardcoded(gameState)
    keepGoing = true;
    hits = [];

    c = lower(strtrim(string(input("Color (red/blue/purple/green) or q: ","s"))));
    if c == "q"
        keepGoing = false;
        return;
    end

    s = lower(strtrim(string(input("Section (sophomore/junior/senior): ","s"))));

    colorId = parseColor(gameState, c);
    sectionId = parseSection(gameState, s);

    if colorId == 0 || sectionId == 0
        disp("Invalid color or section.");
        return;
    end

    tiles = gameState.tiles;
    mask = arrayfun(@(t) t.colorId == colorId && t.sectionId == sectionId, tiles);
    hits = tiles(mask);

    if isempty(hits)
        disp("No matches found.");
    else
        fprintf("\nMatches for color=%s, section=%s:\n", c, s);
        for i = 1:numel(hits)
            fprintf("  Tile %d at %.1f deg\n", hits(i).id, hits(i).thetaDeg);
        end
        fprintf("\n");
    end
end