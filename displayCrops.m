%%% Read in the table with all file locations and info %%%
pause on
warning off
t =  readtable('CV19_index.csv', 'Delimiter', ',');
c2 = readtable('ImCrop.csv', 'Delimiter', ',');
warning on
n_max = size(t,1);
im_size = [1000 1000];
im_position = [0, 0, 1000, 1000];

db_path = pwd; %uigetdir(pwd,'Select the COVID-19 folder');


ind = 2;
while(ind<n_max+1)
    % Read the file path for this example %
    path = interpretPath(db_path, t.ImagePath(ind));
    
    warning off
    info = dicominfo(path);
    img = dicomread(path);
    orig_im_size = size(img);
    img = imresize(img, im_size);
    warning on
    
    disp(info)
    namer = [t.Center{ind} '-' t.Patient{ind}];
    disp(['CURRENTLY: Showing information for ' namer ' (' num2str(ind) ' out of ' num2str(n_max) ').']);
    disp(' ')
    disp(' ')
    
    f = figure(1);
    
    if(strcmpi(t.Center{ind},'Busto'))
        img = (double(img) - 8000)/(22000 - 8000);
        img = abs(img - 1);
        wmin = 0;
        wmax = 1;
    else
        wmin = 0;
        wmax = 4095;
    end
    imshow(img, [wmin wmax],'InitialMagnification','fit')
    title(namer)
    % axes(f, 'tight')
    axis tight
    set(f, 'Position',  im_position)
    ax = gca;
    ax.Toolbar.Visible = 'off';

    % Is this a chest image?
    
    if(c2.Var1(ind)==1)
        % Show ROI %
        ROI_POS = 10.*[c2.Var2(ind), c2.Var3(ind), c2.Var4(ind), c2.Var5(ind)];
        roi = images.roi.Rectangle(gca,'Position',ROI_POS,'StripeColor','r');        
      
        % Find out if this is a frontal or lateral image %
        if(c2.Var6(ind)==1)
            disp('Image Identified as Frontal')
            xlabel('Frontal')
        elseif(c2.Var6(ind)==2)
            disp('Image Identified as Lateral')
        else
            disp('Something weird about Front/Lat')
        end
        disp(' ')
        
        % Is this the original image or enhanced? %
        if(c2.Var7(ind)==1)
            disp('Image Identified as Original')
            ylabel('Original')
        elseif(c2.Var7(ind)==2)
            disp('Image Identified as Enhanced')
        else
            disp('Something weird about Orig/Enh')
        end
        disp(' ')
        
    else
        
        disp('Image identified as not a chest image')
        
    end
    
    Question = ['Would you like to re-enter answers for Image ' num2str(ind) '?\n' ...
        'Enter 1 to GO TO PREVIOUS IMAGE,\n'...
        'Enter 2 to RESTART THIS IMAGE,\n' ...
        'Enter 3 to GO TO NEXT IMAGE: ' ];
    Case1 = 'Returning to previous image.';
    Case2 = ['Restarting image ' num2str(ind)];
    Case3 = 'Proceeding to next image..';
    go_to_next = threeCaseQ(Question, Case1, Case2, Case3);
    
    if(go_to_next==1)
        ind = ind - 1;
        if(ind==0)
            ind=1;
        end
    elseif(go_to_next==2)
        %do nothing        
    elseif(go_to_next==3)
        ind = ind + 1;
    else
        disp('Error with image restart select')
    end
    
%     pause(1)
    clc;
    close(f);
end


disp('All images evaluated.')

function outputOut = twoCaseQ(Question, Case1, Case2)

looper = 1;
while(looper)
    arg_in = input(Question);
    if(arg_in==1)
        fprintf([Case1 '\n'])
        outputOut = 1;
        looper = 0;
    elseif(arg_in==2)
        fprintf([Case2 '\n'])
        outputOut = 2;
        looper = 0;
    else
        fprintf('Invalid selection, try again. \n')
    end
    
end
disp(' ')
disp(' ')
end

function outputOut = threeCaseQ(Question, Case1, Case2, Case3)

looper = 1;
while(looper)
    arg_in = input(Question);
    if(arg_in==1)
        fprintf([Case1 '\n'])
        outputOut = 1;
        looper = 0;
    elseif(arg_in==2)
        fprintf([Case2 '\n'])
        outputOut = 2;
        looper = 0;
    elseif(arg_in==3)
        fprintf([Case3 '\n'])
        outputOut = 3;
        looper = 0;
    else
        fprintf('Invalid selection, try again. \n')
    end
    
end
disp(' ')
disp(' ')
end

function pathOut = interpretPath(startPath, path)

parts = strsplit(path{:},'/');
pathOut = startPath;
for i = 1:length(parts)
    pathOut = fullfile(pathOut, parts{i});
end

end