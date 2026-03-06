function out = detectDiceTotal(diceRGB, blankRGB, varargin)
% detectDiceTotal (ONE die)
% Inputs:
%   diceRGB  - image with die present (RGB)
%   blankRGB - image with no die (RGB)
% Output struct out:
%   out.dieCount     - pip count on the die
%   out.total        - same as dieCount
%   out.pipCentroids - Nx2 pip centroids (x,y)
%   out.debug        - debug masks/images

% optional args
p = inputParser;
addParameter(p, "ShowDebug", true, @(x)islogical(x) || isnumeric(x));
addParameter(p, "MinPipArea", 5, @(x)isnumeric(x) && isscalar(x)); 
addParameter(p, "MaxPipArea", 800, @(x)isnumeric(x) && isscalar(x)); 

% Shadow / darkness controls
addParameter(p, "DarkPixelThresh", 0.35, @(x)isnumeric(x) && isscalar(x));  % lower=stricter
addParameter(p, "ShadowOpenRadius", 35, @(x)isnumeric(x) && isscalar(x));   % bigger=removes more smooth shadow
parse(p, varargin{:});

SHOW   = logical(p.Results.ShowDebug);
minA   = p.Results.MinPipArea;
maxA   = p.Results.MaxPipArea;
darkThr = p.Results.DarkPixelThresh;
openRad = p.Results.ShadowOpenRadius;

% convert to grayscale double [0..1]
gDice  = im2double(rgb2gray(diceRGB));
gBlank = im2double(rgb2gray(blankRGB));


% Difference that highlights dark pips
% If a pixel got darker (pip), gBlank - gDice will be positive.
diffDark = gBlank - gDice;
diffDark(diffDark < 0) = 0;

%%
% (1) Normalize to reduce global lighting changes / shadows
diffN = diffDark ./ (gBlank + 1e-6);

% (2) Remove smooth shadow gradients (low-frequency) using morphological opening
bgEst  = imopen(diffN, strel('disk', openRad));
diffHP = diffN - bgEst;
diffHP(diffHP < 0) = 0;

% (3) Slight smoothing
diffSm = imgaussfilt(diffHP, 0.35); %0.8 0.5

% (4) Require pixels to be truly dark in the dice image
darkPix = gDice < darkThr;

% (5) Adaptive threshold on nonzero values
nz = diffSm(diffSm > 0.005);
if isempty(nz)
    out = struct("dieCount",0,"total",0,"pipCentroids",zeros(0,2), ...
                 "debug",struct());
    if SHOW
        figure; imshow(diceRGB); title("Dice image (no nonzero diff)");
        figure; imshow(diffSm, []); title("diffSm (high-pass normalized)");
    end
    return;
end

t = graythresh(nz);
t = max(0.01, 0.65*t);  % tune depending on lighting DON'T change the lighnting
pipMask = (diffSm > t) & darkPix;
 

%%

% Clean up blobs

pipMask = bwareaopen(pipMask, minA);          % remove tiny specks
pipMask = imopen(pipMask, strel('disk', 1));  % remove tiny bridges
pipMask = bwareaopen(pipMask, minA);          % re-remove tiny specks


% Restore size slightly
pipMask = imdilate(pipMask, strel('disk',1));
pipMask = bwareaopen(pipMask, minA);

% Keep only "pip-like" blobs

cc = bwconncomp(pipMask);
stats = regionprops(cc, 'Area','Centroid','Eccentricity','Solidity');

keep = false(cc.NumObjects,1);
centroids = zeros(cc.NumObjects,2);

for k = 1:cc.NumObjects
    A   = stats(k).Area;
    ecc = stats(k).Eccentricity;
    sol = stats(k).Solidity;

    if A >= minA && A <= maxA && ecc < 0.96 && sol > 0.10  
        keep(k) = true;
        centroids(k,:) = stats(k).Centroid;
    end
end

centroids = centroids(keep,:);

if isempty(centroids)
    out = struct("dieCount",0,"total",0,"pipCentroids",zeros(0,2), ...
                 "debug",struct("diffDark",diffDark,"diffSm",diffSm,"pipMask",pipMask));
    if SHOW
        figure; imshow(diceRGB); title("Dice image (no pips detected)");
        figure; imshow(diffSm, []); title("diffSm (high-pass normalized)");
        figure; imshow(pipMask); title("pipMask (after filtering)");
    end
    return;
end


% ONE die: count pips 

dieCount = size(centroids,1);
total = dieCount;

out = struct();
out.dieCount = dieCount;
out.total = total;
out.pipCentroids = centroids;
out.debug = struct( ...
    "diffDark", diffDark, ...
    "diffN", diffN, ...
    "diffSm", diffSm, ...
    "darkPix", darkPix, ...
    "pipMask", pipMask);


% Display overlay

if SHOW
    figure; imshow(diceRGB); hold on;
    plot(centroids(:,1), centroids(:,2), 'go', 'LineWidth', 2, 'MarkerSize', 8);
    title(sprintf("Die=%d, Total=%d", dieCount, total));
    hold off;

    figure; imshow(pipMask); title("Detected pip mask");
end
end

