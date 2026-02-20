function det = detectTiles(imgRGB)
    det = detectTileCentroids(imgRGB, 24);

    % classify color at each centroid
    [det.colorId, det.conf] = detectColorsAtCentroids(imgRGB, det.centroidsPx);
end