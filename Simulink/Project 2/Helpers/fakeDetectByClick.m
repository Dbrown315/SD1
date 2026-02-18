function det = fakeDetectByClick(img, N)
    figure('Name','Fake Detection'); imshow(img);
    title(sprintf("Click %d tile centroids (outer ring)", N));
    [x,y] = ginput(N);
    close;

    det.N = N;
    det.centroidsPx = [x y];

    % placeholder color IDs (all unknown)
    det.colorId = zeros(N,1,'uint8');
end
