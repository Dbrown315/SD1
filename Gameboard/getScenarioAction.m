function [moveSpaces, ruleText] = getScenarioAction(colorstr)
% Purpose: Convert tile color into required board movement.
% Input:   colorStr
% Output:  moveSpaces and display text

    switch lower(string(colorstr))
        case "red"
            moveSpaces = -2;
            ruleText = "Very bad: move back 2 spaces.";
        case "purple"
            moveSpaces = -1;
            ruleText = "Bad: move back 1 space.";
        case "blue"
            moveSpaces = 1;
            ruleText = "Good: move forward 1 space.";
        case "green"
            moveSpaces = 2;
            ruleText = "Very good: move forward 2 spaces.";
        otherwise 
            error("Invalid color string.");
    end
end