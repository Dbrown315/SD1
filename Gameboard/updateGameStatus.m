function updateGameStatus(ui, statusText, rollText, scenarioText, tileText, doneText)
% Purpose: Update all text shown in the status GUI.
% Input:   ui struct, status text, roll text, and scenario text,
%          optional tile text, and optional completion text
% Output:  none.

    ui.StatusLabel.Text = string(statusText);
    ui.RollLabel.Text = string(rollText);

    if nargin >= 5 && isfield(ui, 'TileLabel') && ~isempty(tileText)
        ui.TileLabel.Text = string(tileText);
    end

    if nargin >= 6 && isfield(ui, 'DoneLabel') && ~isempty(doneText)
        ui.DoneLabel.Text = string(doneText);
    end

    if isstring(scenarioText) || ischar(scenarioText)
        ui.ScenarioArea.Value = cellstr(string(scenarioText));
    else
        ui.ScenarioArea.Value = scenarioText;
    end
    
    drawnow;
end