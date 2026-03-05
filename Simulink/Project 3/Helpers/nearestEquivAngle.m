function thetaAdj = nearestEquivAngle(targetDeg, currentDeg)
%Adjust target so motor takes the shortest path

    candidates = [targetDeg-360, targetDeg, targetDeg+360];
    [~,idx] = min(abs(candidates - currentDeg));
    thetaAdj = candidates(idx);
end