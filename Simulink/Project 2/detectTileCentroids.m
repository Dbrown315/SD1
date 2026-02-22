function det = detectTileCentroids(imgRGB, expectedN)
% Returns det.N and det.centroidsPx from a single image.
% Uses a "colorfulness via grayscale subtraction" mask.
% expectedN = 24 typically.

    if nargin < 2, expectedN = 24; end

    % --- colorfulness mask via grayscale subtraction ---
    G = rgb2gray(imgRGB);                 % uint8
    grayRGB = repmat(G, [1 1 3]);         % uint8  HxWx3
    D = imabsdiff(imgRGB, grayRGB);       % uint8  HxWx3

    % scalar magnitude (0..~3). Use double for stable thresholding
    mag = sum(im2double(D), 3);

    % Reject dark pixels (shadows) using grayscale brightness
    Gd = im2double(G);

    % --- threshold (TUNE THESE) ---
    tMag = 0.24;    % higher = stricter, fewer pixels (try 0.15..0.30)
    tGray = 0.15;   % ignore very dark areas (try 0.15..0.30)

    mask = (mag > tMag) & (Gd > tGray);

    % --- cleanup ---
    %mask = imopen(mask, strel('disk', 1));
    
    %mask = imfill(mask, 'holes');
    mask = imerode(mask, strel('disk',1));
    

    % Optional: remove tiny junk
    mask = bwareaopen(mask, 400);

    % --- blobs -> centroids ---
    CC = bwconncomp(mask);
    stats = regionprops(CC, 'Centroid', 'Area');

    if isempty(stats)
        det.N = 0;
        det.centroidsPx = zeros(0,2);
        det.mask = mask;
        det.mag = mag;         % optional debug
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
    det.mask = mask;   % keep for debugging
    det.mag = mag;     % keep for debugging
end