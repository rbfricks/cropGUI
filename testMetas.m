pause on
warning off
t =  readtable('HF_index.csv', 'Delimiter', ',');
c2 = readtable('Answers_Rafael.csv', 'Delimiter', ',');
warning on
n_max = size(t,1);

db_path = pwd; %uigetdir(pwd,'Select the COVID-19 folder');

isWeird = zeros(1,n_max);
minrs = zeros(1,n_max);
maxrs = zeros(1,n_max);

for ind = 1:n_max
    path = interpretPath(db_path, t.ImagePath(ind));
    
    warning off
    info = dicominfo(path);
    img = dicomread(path);
    orig_im_size = size(img);
    warning on
    
    minrs(ind) = min(img(:));
    maxrs(ind) = max(img(:));
    
    %     if(strcmpi(type,'INVERSE'))
    %         isWeird(ind) = 1;
    %         disp(ind, type)
    %     else
    %         isWeird(ind) = 0;
    %     end
    
    try
        PIR = info.PixelIntensityRelationship;
        %         disp([num2str(ind) ' ' info.PixelIntensityRelationship])
    catch ME
        PIR = 'No intensity relationship.';
        %         disp([num2str(ind) ' no intensity relationship'])
    end
    
    try
        PLS = info.PresentationLUTShape;
    catch ME2
        PLS = 'No Presentation LUT Shape';
    end
    
    try
        wc = info.WindowCenter(1);
        ww = info.WindowWidth(1);
        wmin = wc - ww/2;
        wmax = wc + ww/2;
        WindowGiven = 'Yes';
    catch ME3
        WindowGiven = 'No';
        disp([num2str(min(img(:))) ' '  num2str(max(img(:)))])
        
        disp([num2str(ind) ': No window given'])
    end
    
    %     if(strcmpi(PLS, 'Inverse'))
    %         disp([num2str(ind) ': ' PIR ' ' PLS])
    %     end
    
    %     try
    %         k = info.PresentationLUTShape;
    %         if(strcmpi(k, 'INVERSE'))
    %             isWeird(ind) = 1;
    %             disp(ind)
    %             disp(k)
    %         else
    %             isWeird(ind) = 0;
    %         end
    %         %         disp(info.PixelIntensityRelationship)
    %     catch ME
    %
    %         isWeird(ind) = 0;
    %
    %     end
    
end









function pathOut = interpretPath(startPath, path)

parts = strsplit(path{:},'/');
pathOut = startPath;
for i = 1:length(parts)
    pathOut = fullfile(pathOut, parts{i});
end

end