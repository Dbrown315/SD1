function out = detectDiceTotal_singleImage(diceRGB, varargin)
% detectDiceTotal_singleImage
% Detect pips from a single image of one die on a fixed white die station
%
% Input:
%   diceRGB - image from camera
%
% Output struct:
%   out.dieCount
%   out.total
%   out.pipCentroids
%   out.debug

p = inputParser;
addParameter(p, "ShowDebug", true, @(x)islogical(x) || isnumeric(x));

% Dark pip settings
addParameter(p, "DarkPixelThresh", 0.45, @(x)isnumeric(x) && isscalar(x)); %0.36 %og = 0.32
addParameter(p, "MinPipArea", 20, @(x)isnumeric(x) && isscalar(x)); 
addParameter(p, "MaxPipArea", 500, @(x)isnumeric(x) && isscalar(x));

% Shape filtering
addParameter(p, "MaxEccentricity", 0.92, @(x)isnumeric(x) && isscalar(x));
addParameter(p, "MinSolidity", 0.75, @(x)isnumeric(x) && isscalar(x));

parse(p, varargin{:});

SHOW   = logical(p.Results.ShowDebug);
darkThr = p.Results.DarkPixelThresh;
minA    = p.Results.MinPipArea;
maxA    = p.Results.MaxPipArea;
maxEcc  = p.Results.MaxEccentricity;
minSol  = p.Results.MinSolidity;

% Converts to grayscale 
g = im2double(rgb2gray(diceRGB));
g = adapthisteq(g);
%smoothing
gSm = imgaussfilt(g, 1);

% Detect dark pixels
pipMask = gSm < darkThr;

% Clean up
pipMask = bwareaopen(pipMask, minA);
pipMask = imopen(pipMask, strel('disk',1));
pipMask = imclose(pipMask, strel('disk',1));
pipMask = bwareaopen(pipMask, minA);

% Region filtering
cc = bwconncomp(pipMask);
stats = regionprops(cc, 'Area','Centroid','Eccentricity','Solidity','Perimeter');

keep = false(cc.NumObjects,1);
centroids = zeros(cc.NumObjects,2);

for k = 1:cc.NumObjects
    A   = stats(k).Area;
    ecc = stats(k).Eccentricity;
    sol = stats(k).Solidity;
    P   = stats(k).Perimeter;

    if P == 0
        continue;
    end

    circularity = 4*pi*A/(P^2);

    if A >= minA && A <= maxA && ...
       ecc <= maxEcc && ...
       sol >= minSol && ...
       circularity > 0.45
        keep(k) = true;
        centroids(k,:) = stats(k).Centroid;
    end
end

centroids = centroids(keep,:);

dieCount = size(centroids,1);

out = struct();
out.dieCount = dieCount;
out.total = dieCount;
out.pipCentroids = centroids;
out.debug = struct( ...
    "gray", g, ...
    "graySmooth", gSm, ...
    "pipMask", pipMask);

if SHOW
    figure; imshow(diceRGB); hold on;
    if ~isempty(centroids)
        plot(centroids(:,1), centroids(:,2), 'go', 'LineWidth', 2, 'MarkerSize', 10);
    end
    title(sprintf("Dice image (detected pips = %d)", dieCount));
    hold off;

    figure; imshow(gSm, []); title("Smoothed grayscale image");
    figure; imshow(pipMask); title("Detected pip mask");
end
end