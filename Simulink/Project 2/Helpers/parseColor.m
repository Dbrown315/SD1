function id = parseColor(gs, c)
    id = 0;
    switch c
        case "red",    id = gs.key.color.Red;
        case "blue",   id = gs.key.color.Blue;
        case "purple", id = gs.key.color.Purple;
        case "green",  id = gs.key.color.Green;
    end
end
