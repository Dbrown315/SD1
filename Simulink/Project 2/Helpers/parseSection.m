function id = parseSection(gs, s)
    id = 0;
    switch s
        case {"soph","sophomore"}, id = gs.key.section.Sophomore;
        case {"jun","junior"},     id = gs.key.section.Junior;
        case {"sen","senior"},     id = gs.key.section.Senior;
    end
end