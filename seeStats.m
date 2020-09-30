pause on
warning off
t =  readtable('HF_index.csv', 'Delimiter', ',');
warning on
n_max = size(t,1);
im_size = [500 500];
db_path = pwd; %uigetdir(pwd,'Select the COVID-19 folder');


im_min = zeros(n_max,1);
im_max = zeros(n_max,1);
bitDepths = zeros(n_max,1);
imgs = zeros(im_size(1),im_size(2),n_max);
parfor i = 1:n_max
% i = 485;
    % Read the file path for this example %
    path = interpretPath(db_path, t.ImagePath(i));
    
    warning off
    info = dicominfo(path);
    img = dicomread(path);
    orig_im_size = size(img);
    img = imresize(img, im_size);
    imgs(:,:,i) = img;
    warning on
    
    im_min(i) = min(img(:));
    im_max(i) = max(img(:));
    bitDepths(i) = info.BitDepth;
    
end

max_inds = find(im_max>16000);
for j =1:length(max_inds)
    imshow(imgs(:,:,max_inds(j)), [])
    disp(max_inds(j))
    pause
end

function pathOut = interpretPath(startPath, path)

parts = strsplit(path{:},'/');
pathOut = startPath;
for i = 1:length(parts)
    pathOut = fullfile(pathOut, parts{i});
end

end