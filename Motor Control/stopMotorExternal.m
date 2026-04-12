function stopMotorExternal(simCtl)
% Stop and disconnect External Mode
    try
        set_param(simCtl.model, "SimulationCommand", "stop");
    catch
    end
    try
        set_param(simCtl.model, "SimulationCommand", "disconnect");
    catch
    end
end