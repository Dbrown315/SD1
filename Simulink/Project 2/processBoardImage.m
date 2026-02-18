% Build the gameState struct and compute tile angles, sections, and IDs
function gameState = processBoardImage(img, calib, det)
    % Keys 
    key.color = struct('Unknown',0,'Red',1,'Blue',2,'Purple',3,'Green',4);
    key.section = struct('Sophomore',1,'Junior',2,'Senior',3);

    % Init gameState 
    gameState = struct();
    gameState.N = det.N;
    gameState.key = key;

    gameState.img.current = img;

    gameState.board.centerPx = calib.centerPx;
    gameState.board.sectionBoundariesDeg = calib.sectionBoundariesDeg;
    gameState.board.thetaZeroDeg = calib.thetaZeroDeg;
    gameState.board.thetaDir = calib.thetaDir;

    % Tile array 
    emptyTile = struct('id',uint8(0),'centroidPx',[NaN NaN], ...
        'thetaDeg',NaN,'sectionId',uint8(0),'colorId',uint8(0),'conf',NaN);

    gameState.tiles = repmat(emptyTile, 1, det.N);

    % Fill from det
    for k = 1:det.N
        c = det.centroidsPx(k,:);
        th = calcThetaDeg(c, gameState.board.centerPx, ...
                          gameState.board.thetaZeroDeg, gameState.board.thetaDir);
        w = assignSection(th, gameState.board.sectionBoundariesDeg); % wedge index 1..3

        gameState.tiles(k).centroidPx = c;
        gameState.tiles(k).thetaDeg   = th;
        gameState.tiles(k).sectionId = uint8(calib.wedgeToSectionId(w)); % Soph/Jun/Sen correctly

        % color placeholder (use det.colorId later)
        if isfield(det,'colorId')
            gameState.tiles(k).colorId = uint8(det.colorId(k));
        else
            gameState.tiles(k).colorId = uint8(key.color.Unknown);
        end

        if isfield(det,'conf')
            gameState.tiles(k).conf = det.conf(k);
        end
    end

    % Optional: stable numbering by theta order
    [~,idx] = sort([gameState.tiles.thetaDeg]);
    gameState.tiles = gameState.tiles(idx);
    for k = 1:numel(gameState.tiles)
        gameState.tiles(k).id = uint8(k);
    end
end
