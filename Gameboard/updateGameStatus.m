function updateGameStatus(ui, statusText, rollText, scenarioText)
% Purpose: Update all text shown in the status GUI.
% Input:   ui struct, status text, roll text, and scenario text.
% Output:  none.

    ui.StatusLabel.Text = string(statusText);
    ui.RollLabel.Text = string(rollText);

    if isstring(scenarioText) || ischar(scenarioText)
        ui.ScenarioArea.Value = cellstr(string(scenarioText));
    else
        ui.ScenarioArea.Value = scenarioText;
    end

    drawnow;
end