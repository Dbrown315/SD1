function waitForRollButton(ui)
% Purpose: Wait until the GUI Roll Die button is pressed.
% Input:   ui struct
% Output:  none

    ui.RollRequested = false;

    while isvalid(ui.Fig) && ~ui.RollRequested
        pause(0.05);
        drawnow;
    end

    ui.RollRequested = false;
end