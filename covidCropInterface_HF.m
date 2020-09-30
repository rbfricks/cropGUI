%%% Read in the table with all file locations and info %%%
pause on
warning off
t =  readtable('HF_index.csv', 'Delimiter', ',');
fname = 'Answers_HFHS2.csv';
warning on
n_max = size(t,1);
im_size = [1000 1000];
im_position = [0, 0, 1000, 1000];

clc;
fprintf('Welcome to the COVID Crop Interface, prompt-guided system!')
fprintf('\n\n')
fprintf(['DICOM header information for each file will be printed here in the Command \n' ...
    'Window in MATLAB, followed by questions. Answer each question by typing \n'...
    'a number choice and hitting enter. ' num2str(n_max) ' images identified in the list.'])
fprintf('\n\n')
fprintf(['For each image, the image will pop up in a separate window. If the \n' ...
    'image has been identified as a chest radiograph, you will be prompted to \n' ...
    'select the ROI in the image window. After the ROI has been selected, double \n' ...
    'click anywhere on the ROI to proceed to the next step. \n' ...
    'DO NOT CLOSE THE ROI WINDOW!'])
fprintf('\n\n')
fprintf('YOU WILL HAVE A CHANCE TO CHANGE ANSWERS AT THE END OF EACH IMAGE!')
fprintf('\n\n')
input('Press enter to locate the COVID Image directory and begin.')
clc;

% db_path = uigetdir(pwd,'Select the COVID-19 folder');
db_path = pwd;

roi_records = zeros(n_max,4);
is_chest = ones(n_max,1);
front_or_lat = ones(n_max,1);
orig_or_enhanced = zeros(n_max,1);

ind = 513;
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
    namer = [t.Center{ind} '-' num2str(t.Patient(ind))];
    disp(['CURRENTLY: Showing information for ' namer ' (' num2str(ind) ' out of ' num2str(n_max) ').']);
    disp(' ')
    disp(' ')
    
    f = figure(1);
    
%     if(strcmpi(t.Center{ind},'Busto'))
%         img = (double(img) - 8000)/(22000 - 8000);
%         img = abs(img - 1);
%         wmin = 0;
%         wmax = 1;
%     else
%         wmin = 0;
%         wmax = 4095;
%     end

    %%% Correct for multiformat %%%
    try
        PIR = info.PixelIntensityRelationship;
    catch ME
        PIR = [];
    end

    try
        PLS = info.PresentationLUTShape;
    catch ME2
        PLS = [];
    end



    if(strcmpi(PLS,'Inverse'))
        dmax = 22000;
        dmin = 8000;
        img(img>dmax) = dmax;
        img(img<dmin) = dmin;
        img = (double(img) - dmin)/(dmax-dmin);
        img = abs(1-img);
        wmin = 0;
        wmax = 1;
        
    else
        try
            wc = info.WindowCenter(1);
            ww = info.WindowWidth(1);
            wmin = wc - ww/2;
            wmax = wc + ww/2;
          
        catch ME3
            wmin = 0;
            wmax = 4095;
            
        end
    end
    %%% END Correct for multiformat %%%
    
    imshow(img, [wmin wmax],'InitialMagnification','fit')
    title(namer)
    % axes(f, 'tight')
    axis tight
    set(f, 'Position',  im_position)
    ax = gca;
    ax.Toolbar.Visible = 'off';

    % Is this a chest image? %
    disp('Image identified as Frontal Chest X-Ray.')
    disp(' ')
    xlabel('Frontal')
    
    % Is this the original image or enhanced? %
    Question = ['Is the image ORIGINAL (enter 1) or is the image ENHANCED or OTHERWISE UNUSABLE (enter 2)?' ...
        '\n(Enhancements include Bone Enhancement, Bone Removal, Clearview, etc.): '];
    Case1 = 'Original image identified.';
    Case2 = 'Enhanced image identified';
    orig_or_enhanced(ind) = twoCaseQ(Question, Case1, Case2);
    
    if(orig_or_enhanced(ind)==1)
        roi = images.roi.Rectangle(gca,'Position',[0.5,0.5,1000,1000],'StripeColor','r');
        pos = customWait(roi);
        pos(1:2) = floor(pos(1:2))/10;
        pos(3:4) = ceil(pos(3:4))/10;
        roi_records(ind,:) = pos;     
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
    
    pause(1)
    clc;
    close(f);
    dat = [is_chest roi_records front_or_lat orig_or_enhanced];
    writematrix(dat,fname);
end


disp(['All images evaluated. Thank you for your answers, your responses have been recorded as ' fname])

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

function pos = customWait(hROI)

% Listen for mouse clicks on the ROI
l = addlistener(hROI,'ROIClicked',@clickCallback);

% Block program execution
uiwait;

% Remove listener
delete(l);

% Return the current position
pos = hROI.Position;

end

function clickCallback(~,evt)

if strcmp(evt.SelectionType,'double')
    uiresume;
end

end