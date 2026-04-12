function s = sectionIdToString(sectionId)
    switch double(sectionId)
        case 1
            s = "sophomore";
        case 2
            s = "junior";
        case 3
            s = "senior";
        otherwise
            error("Invalid sectionId.");
    end
end