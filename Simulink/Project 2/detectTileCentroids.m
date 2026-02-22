function det = detectTileCentroids(imgRGB, expectedN)
% Detect tile blobs and return centroids using hard HSV thresholds
% derived from measured tile HSV samples.
%
% Output:
%   det.N
%   det.centroidsPx (Nx2) [x y]
%   det.mask (debug)

    if nargin < 2, expectedN = 24; end

    hsvImg = rgb2hsv(imgRGB);
    Hdeg = hsvImg(:,:,1) * 360;   % hue in degrees [0..360)
    S = hsvImg(:,:,2);            % [0..1]
    V = hsvImg(:,:,3);            % [0..1]

    % ---- hard gates to reject black divider blends ----
    minS = 0.12;   % keep green (measured S as low as ~0.21)
    minV = 0.46;   % reject dark blends (you saw V ~ 0.35 on blacks)
    goodSV = (S >= minS) & (V >= minV);

    % ---- hue bands (add padding for lighting drift) ----
    pad = 12;  % degrees of slack on each side

    purple = inHueRange(Hdeg, 287-pad, 307+pad);
    blue   = inHueRange(Hdeg, 228-pad, 237+pad);
    green  = inHueRange(Hdeg, 103-pad, 132+pad);

    % red wraps: ~339–350. Give it slack and wrap around 0.
    red    = inHueRange(Hdeg, 339-pad, 360) | inHueRange(Hdeg, 0, 20);

    tileMask = goodSV & (red | blue | green | purple);

    % ---- cleanup: heal small gaps then remove tiny noise ----

    %tileMask = imerode(tileMask, strel('disk',1));
    %tileMask = imclose(tileMask, strel('disk', 1));
    %tileMask = imopen(tileMask, strel('disk', 1));
    %tileMask = imfill(tileMask, 'holes');
    tileMask = bwareaopen(tileMask, 400);

    % If you still get a merged pair, this breaks thin bridges:

    %tileMask = imopen(tileMask, strel('disk', 1));


    % ---- blobs -> centroids ----
    CC = bwconncomp(tileMask);
    stats = regionprops(CC, 'Centroid', 'Area');

    if isempty(stats)
        det.N = 0;
        det.centroidsPx = zeros(0,2);
        det.mask = tileMask;
        return;
    end

    areas = [stats.Area];
    [~, idx] = sort(areas, 'descend');

    N = min(expectedN, numel(idx));
    centroids = zeros(N,2);
    for k = 1:N
        centroids(k,:) = stats(idx(k)).Centroid;  % [x y]
    end

    det.N = N;
    det.centroidsPx = centroids;
    det.mask = tileMask;
end

function tf = inHueRange(Hdeg, a, b)
% Hdeg in [0..360). Returns true if Hdeg is within [a,b] inclusive.
% Assumes a<=b and no wrap; wrap handled outside.
    tf = (Hdeg >= a) & (Hdeg <= b);
end