% CLI prompt and prompt results
function keepGoing = queryAndDisplay(gameState)
    keepGoing = true;

    % --- prompt ---
    c = lower(strtrim(string(input("Color (red/blue/purple/green) or q: ","s"))));
    if c == "q"
        keepGoing = false; return;
    end
    s = lower(strtrim(string(input("Section (sophomore/junior/senior): ","s"))));

    colorId = parseColor(gameState, c);
    sectionId = parseSection(gameState, s);

    if colorId == 0 || sectionId == 0
        disp("Invalid color or section."); return;
    end

    % --- filter ---
    tiles = gameState.tiles;
    mask = arrayfun(@(t) t.colorId==colorId && t.sectionId==sectionId, tiles);
    hits = tiles(mask);

    % --- display ---
    persistent hFig
    
    if isempty(hFig) || ~isvalid(hFig)
        hFig = figure('Name','Query Result');
    else
        figure(hFig);
        clf(hFig);   % clear old content instead of opening new window
    end
    
    imshow(gameState.img.current); 
    hold on;
    
    title(sprintf("Color=%s, Section=%s", c, s));


    if ~isempty(hits)
        xy = vertcat(hits.centroidPx);
        plot(xy(:,1), xy(:,2), 'gx', 'MarkerSize', 12, 'LineWidth', 2);

        for i = 1:numel(hits)
            text(hits(i).centroidPx(1)+6, hits(i).centroidPx(2), ...
                sprintf("%.1f°", hits(i).thetaDeg), 'Color','y','FontSize',10);
        end
    else
        disp("No matches found.");
    end
    hold off;
end

function id = parseColor(gs, c)
    id = 0;
    switch c
        case "red",    id = gs.key.color.Red;
        case "blue",   id = gs.key.color.Blue;
        case "purple", id = gs.key.color.Purple;
        case "green",  id = gs.key.color.Green;
        otherwise, id = 0;
    end
end

function id = parseSection(gs, s)
    id = 0;
    switch s
        case {"soph","sophomore"}, id = gs.key.section.Sophomore;
        case {"jun","junior"},     id = gs.key.section.Junior;
        case {"sen","senior"},     id = gs.key.section.Senior;
        otherwise, id = 0;
    end
end
