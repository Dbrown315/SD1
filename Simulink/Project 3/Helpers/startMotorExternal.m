function simCtl = startMotorExternal(model)
% Connect/Start Simulink Model for motor control
% Model must use a constant "theta_cmd_deg"

    theta_cmd_deg = 0;
    assignin("base","theta_cmd_deg", theta_cmd_deg);

    load_system(model);

    % External mode
    set_param(model, "StopTime", "inf");
    set_param(model, "SimulationMode", "external");
    set_param(model, "SimulationCommand", "connect");
    set_param(model, "SimulationCommand", "start");

    simCtl = struct();
    simCtl.model = model;
end