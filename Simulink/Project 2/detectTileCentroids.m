function det = detectTileCentroids(bgRGB, imgRGB, expectedN)
% Background subtraction for tile centroid detection.
% bgRGB: blank-board image (same camera pose/lighting)
% imgRGB: colored-board image
% Returns det.N, det.centroidsPx, det.mask, det.diffMag

    if nargin < 3, expectedN = 24; end

    A = im2double(bgRGB);
    B = im2double(imgRGB);

    % absolute RGB difference magnitude
    D = abs(B - A);
    diffMag = sum(D, 3);   % roughly 0..3

    % Threshold (main knob)
    tDiff = 0.70;
    mask = diffMag > tDiff;


    % Morphology: heal and solidify tiles
    %mask = imclose(mask, strel('disk', 6));
    %mask = imfill(mask, 'holes');
    %mask = bwareaopen(mask, 250);

    % OPTIONAL: if you ever see border junk
    % mask = imclearborder(mask);

    % Connected components -> stats
    CC = bwconncomp(mask);
    stats = regionprops(CC, 'Centroid', 'Area');

    if isempty(stats)
        det.N = 0;
        det.centroidsPx = zeros(0,2);
        det.mask = mask;
        det.diffMag = diffMag;
        return;
    end

    % Keep biggest blobs
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
    det.diffMag = diffMag;
end