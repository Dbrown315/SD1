function waitForRollButton(ui)
% Purpose: Wait until the GUI Roll Die button is pressed.
% Input:   ui struct
% Output:  none

    data = ui.Fig.UserData;
    data.RollRequested = false;
    ui.Fig.UserData = data;

    while isvalid(ui.Fig)
        drawnow;
        pause(0.05);

        data = ui.Fig.UserData;
        if isfield(data, 'RollRequested') && data.RollRequested
            break;
        end
    end

    if isvalid(ui.Fig)
        data = ui.Fig.UserData;
        data.RollRequested = false;
        ui.Fig.UserData = data;
    end
end