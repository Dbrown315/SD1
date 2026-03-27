function s = colorIdToString(colorId)
    switch double(colorId)
        case 1
            s = "red";
        case 2
            s = "blue";
        case 3
            s = "purple";
        case 4
            s = "green";
        otherwise
            error("Invalid colorId.");
    end
end