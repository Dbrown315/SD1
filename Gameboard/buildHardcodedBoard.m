function gameState = buildHardcodedBoard()
    key.color = struct('Unknown',0,'Red',1,'Blue',2,'Purple',3,'Green',4);
    key.section = struct('Sophomore',1,'Junior',2,'Senior',3);

    gameState = struct();
    gameState.N = 24;
    gameState.key = key;

    emptyTile = struct( ...
        'id', uint8(0), ...
        'thetaDeg', NaN, ...
        'sectionId', uint8(0), ...
        'colorId', uint8(0));

    gameState.tiles = repmat(emptyTile, 1, 24);

    % Angle centers, moving clockwise from the divider at 0 deg
    thetaList = mod(352.5 - 15*(0:23), 360);

    % Section IDs: 1=Sophomore, 2=Junior, 3=Senior
    sectionList = [ ...
        repmat(key.section.Sophomore, 1, 8), ...
        repmat(key.section.Junior,    1, 8), ...
        repmat(key.section.Senior,    1, 8) ];

    % Color IDs
    % Red=1, Blue=2, Purple=3, Green=4
    colorList = [ ...
        1 2 4 3 1 2 4 3, ... % Sophomore: r,b,g,p,r,b,g,p
        2 4 3 1 3 4 2 1, ... % Junior:    b,g,p,r,p,g,b,r
        2 1 2 1 3 4 3 4  ... % Senior:    b,r,b,r,p,g,p,g
    ];

    for k = 1:24
        gameState.tiles(k).id        = uint8(k);
        gameState.tiles(k).thetaDeg  = thetaList(k);
        gameState.tiles(k).sectionId = uint8(sectionList(k));
        gameState.tiles(k).colorId   = uint8(colorList(k));
    end
end