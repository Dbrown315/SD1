function det = detectTileCentroids(imgRGB, expectedN)
% Returns det.N and det.centroidsPx from a single image.
% expectedN = 24 typically.

    if nargin < 2, expectedN = 24; end

    hsv = rgb2hsv(imgRGB);
    S = hsv(:,:,2);
    V = hsv(:,:,3);

    % --- mask likely tile pixels ---
    % Tune these two numbers for your lighting
    minS = 0.50;   % rejects white/gray paper
    minV = 0.65;   % rejects dark shadow/background
    mask = (S > minS) & (V > minV);

    % --- cleanup ---
    mask = imopen(mask, strel('disk', 3));
    mask = imclose(mask, strel('disk', 6));
    mask = imfill(mask, 'holes');

    % Optional: remove tiny junk
    mask = bwareaopen(mask, 200);

    % --- blobs -> centroids ---
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
        centroids(k,:) = stats(idx(k)).Centroid;  % [x y]
    end

    det.N = N;
    det.centroidsPx = centroids;
    det.mask = mask;   % keep for debugging (optional)
end