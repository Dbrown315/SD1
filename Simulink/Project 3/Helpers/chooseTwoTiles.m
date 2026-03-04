function [t1, t2] = chooseTwoTiles(hits)
% Pick two tiles (rnadom). Can swap if needed
    if numel(hits) < 2
        error("Need at least 2 matching tiles.");
    end
    r = randperm(numel(hits), 2);
    t1 = hits(r(1));
    t2 = hits(r(2));
end