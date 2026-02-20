function [colorId, conf] = detectColorsAtCentroids(imgRGB, centroidsPx)
% Returns:
%   colorId(k): 0 Unknown, 1 Red, 2 Blue, 3 Purple, 4 Green
%   conf(k):    confidence score (bigger = more confident)

    keyUnknown = uint8(0);
    keyRed     = uint8(1);
    keyBlue    = uint8(2);
    keyPurple  = uint8(3);
    keyGreen   = uint8(4);

    imgHSV = rgb2hsv(imgRGB);

    N = size(centroidsPx,1);
    colorId = zeros(N,1,'uint8');
    conf    = zeros(N,1);

    r = 6;

    H = imgHSV(:,:,1);
    S = imgHSV(:,:,2);
    V = imgHSV(:,:,3);

    [hgt, wdt, ~] = size(imgRGB);

    for k = 1:N
        x = round(centroidsPx(k,1));
        y = round(centroidsPx(k,2));

        x1 = max(1, x-r); x2 = min(wdt, x+r);
        y1 = max(1, y-r); y2 = min(hgt, y+r);

        hp = H(y1:y2, x1:x2);
        sp = S(y1:y2, x1:x2);
        vp = V(y1:y2, x1:x2);

        %sp > 0.25 for no white and value > 0.25 for no dark shadow
        mask = sp > 0.25 & vp > 0.25;

        %Determine the noncolor patches
        if nnz(mask) < 10
            colorId(k) = keyUnknown;
            conf(k) = 0;
            continue;
        end

        hMed = median(hp(mask));
        sMed = median(sp(mask));

        % Hue thresholds (0..1)
        % Red wraps around 0 (ex: 0.98..1.0 OR 0..0.04)
      
        isRed    = (hMed < 0.05) || (hMed > 0.95);
        isGreen  = (hMed > 0.18) && (hMed < 0.42);
        isBlue   = (hMed > 0.50) && (hMed < 0.72);
        isPurple = (hMed > 0.72) && (hMed < 0.90);

        % Decide winner with a "distance to band center" score
        % (helps when lighting shifts hue a bit)
        scores = -inf(1,4);

        % centers chosen inside each band
        if isRed
            % pick closest to 0 (wrap)
            d = min(abs(hMed-0.00), abs(hMed-1.00));
            scores(1) = -d;
        end
        if isBlue
            scores(2) = -abs(hMed-0.62);
        end
        if isPurple
            scores(3) = -abs(hMed-0.82);
        end
        if isGreen
            scores(4) = -abs(hMed-0.33);
        end

        [bestScore, idx] = max(scores);

        if ~isfinite(bestScore)
            colorId(k) = keyUnknown;
            conf(k) = 0;
        else
            switch idx
                case 1, colorId(k) = keyRed;
                case 2, colorId(k) = keyBlue;
                case 3, colorId(k) = keyPurple;
                case 4, colorId(k) = keyGreen;
            end

            % confidence: mostly saturation + how close hue is to center
            conf(k) = double(sMed) + (1 - abs(bestScore)); % simple, works fine for demo
        end
    end
end