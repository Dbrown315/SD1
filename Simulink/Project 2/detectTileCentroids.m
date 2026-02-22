function det = detectTileCentroids(imgRGB, expectedN)
% Detect tile blobs/centroids using RGB class centers + distance threshold.

    if nargin < 2, expectedN = 24; end

    I = im2double(imgRGB);
    R = I(:,:,1) * 255;
    G = I(:,:,2) * 255;
    B = I(:,:,3) * 255;

    % ---- reject black divider lines / shadows ----
    intensity = (R + G + B) / 3;
    notBlack = intensity > 60;     % tune: 60..90

    % ---- RGB class centers (from your samples; tune if needed) ----
    cRed    = [195,  91, 109];
    cGreen  = [136, 164, 129];
    cBlue   = [ 95,  96, 167];
    cPurple = [146,  97, 150];

    % ---- distance to nearest center ----
    dRed    = rgbDist(R,G,B, cRed);
    dGreen  = rgbDist(R,G,B, cGreen);
    dBlue   = rgbDist(R,G,B, cBlue);
    dPurple = rgbDist(R,G,B, cPurple);

    dMin = min( min(dRed,dGreen), min(dBlue,dPurple) );

    % ---- threshold (key knob) ----
    dThresh = 55;   % tune: 40..70 depending on lighting

    mask = notBlack & (dMin < dThresh);

    % ---- cleanup (heal, fill, then separate) ----
    %mask = imclose(mask, strel('disk', 6));
    %mask = imfill(mask, 'holes');
    %mask = imopen(mask, strel('disk', 2));
    %mask = bwareaopen(mask, 350);

    % ---- blobs -> centroids ----
    CC = bwconncomp(mask);
    stats = regionprops(CC, 'Centroid', 'Area');

    if isempty(stats)
        det.N = 0;
        det.centroidsPx = zeros(0,2);
        det.mask = mask;
        return;
    end

    areas = [stats.Area];
    [~, idx] = sort(areas, 'descend');

    N = min(expectedN, numel(idx));
    centroids = zeros(N,2);
    for k = 1:N
        centroids(k,:) = stats(idx(k)).Centroid;
    end

    det.N = N;
    det.centroidsPx = centroids;
    det.mask = mask;
end

function d = rgbDist(R,G,B, c)
    d = sqrt((R-c(1)).^2 + (G-c(2)).^2 + (B-c(3)).^2);
end