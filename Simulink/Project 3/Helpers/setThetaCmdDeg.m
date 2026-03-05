function setThetaCmdDeg(simCtl, thetaCmdDeg)
% Update tunable setpoint parameter in External mode
% Updates the constant block in the simulink model
    assignin("base","theta_cmd_deg", double(thetaCmdDeg));

    % Push update
    set_param(simCtl.model, "SimulationCommand", "update");
end
