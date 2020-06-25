classdef covidCropInterface < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        covidCropUIFigure        matlab.ui.Figure
        UIAxes                   matlab.ui.control.UIAxes
        UITable                  matlab.ui.control.Table
        
        ImageSelectSpinnerLabel  matlab.ui.control.Label        
        ImageSelectSpinner       matlab.ui.control.Spinner
        winMinSpinnerLabel       matlab.ui.control.Label
        winMinSpinner            matlab.ui.control.Spinner
        winMaxSpinnerLabel       matlab.ui.control.Label
        winMaxSpinner            matlab.ui.control.Spinner
        
        OFImageButtonGroup       matlab.ui.container.ButtonGroup
        OriginalButton           matlab.ui.control.ToggleButton
        EnhancedButton           matlab.ui.control.ToggleButton
        LateralButton            matlab.ui.control.ToggleButton
        
        SeenBeforeLabel          matlab.ui.control.Label
        SeenBefore               matlab.ui.control.Lamp
    end
    
    properties (Access = public)
       imag = [];
       info = []; 
       ind = 1;
       t = [];
        
    end


    methods (Access = private)
    
        
        function switchImage(app)
            % Read the path, convert to this OS     
            app.ind = app.ImageSelectSpinner.Value;
            
            path = app.t.ImagePath(app.ind);
            parts = strsplit(path{:},'/');
            path = pwd;
            for i = 1:length(parts)
                path = fullfile(path, parts{i});
            end
            disp(app.ind);
            disp(path);

            % Read the selected dicom image and info %
            app.imag = imresize(dicomread(path), [900 1200]);
            app.info = dicominfo(path);
            
            
            % Manipulate dicom header into displayed format %
            app.info = struct2table(app.info, 'AsArray', true);
            vars = app.info.Properties.VariableNames;
            app.info = table2cell(app.info);
            app.info = cell2table([vars' app.info']);
            app.UITable.Data = app.info;

            % Set the initial window to the most permissive
            minW = min(app.imag(:));
            maxW = max(app.imag(:));
            app.winMinSpinner.Value = double(minW);
            app.winMaxSpinner.Value = double(maxW);
            
            imshow(app.imag,[minW maxW], 'Parent',app.UIAxes);
        end
        
        
        function updateplot(app)
            % Read the selected dicom image and info %
%             imag = dicomread('RUN1.dcm');
%             info = dicominfo('RUN1.dcm');
            
            % Manipulate dicom header into displayed format %
%             info = struct2table(info, 'AsArray', true);
%             vars = info.Properties.VariableNames;
%             info = table2cell(info);
%             info = cell2table([vars' info']);
%             app.UITable.Data = info;

            % Set the initial window to the most permissive
            minW = app.winMinSpinner.Value;
            maxW = app.winMaxSpinner.Value;
            
            imshow(app.imag,[minW maxW], 'Parent',app.UIAxes);
        end
        
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Read table array from file
%             t = readtable('patients.xls');
            warning off
            app.t =  readtable('CV19_index.csv', 'Delimiter', ',');
            warning on
            n_max = size(app.t,1);
            
            % Set the spinner limits
            app.ImageSelectSpinner.Limits = [1 n_max];
            app.winMinSpinner.Limits = [0 25000];
            app.winMaxSpinner.Limits = [0 25000];

            app.ImageSelectSpinner.Value = app.ind;            

            % Select a subset of the table array
%             t = t(1:20,vars);
            
            % Sort the data by age
%             t = sortrows(t,'Age');
            % Combine Systolic and Diastolic into one variable
%             t.BloodPressure = [t.Systolic t.Diastolic];
%             t.Systolic = [];
%             t.Diastolic = [];
            
            % Convert SelfAssessedHealthStatus to categorical
%             cats = categorical(t.SelfAssessedHealthStatus,{'Poor','Fair','Good','Excellent'});
%             t.SelfAssessedHealthStatus = cats;
            
            % Rearrange columns
%             t = t(:,[1 4 3 2]);
            
            % Add data to the Table UI Component
%             app.UITable.Data = t;
            
%             % Plot the original data
%             x1 = app.UITable.Data.Age;
%             y1 = app.UITable.Data.BloodPressure(:,2);
%             plot(app.UIAxes,x1,y1,'o-');
            
            % Plot the data
            switchImage(app);
        end

        % Display data changed function
        function WindowChanged(app, event)
            % Update the plots when user adjusts window values
            updateplot(app);
        end
        
        function SelectionChanged(app, event)
            % Update the plots when user adjusts window values
            switchImage(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create covidCropUIFigure and hide until all components are created
            app.covidCropUIFigure = uifigure('Visible', 'off');
            app.covidCropUIFigure.Position = [100 100 1820 980];
            app.covidCropUIFigure.WindowState = 'maximized';
            app.covidCropUIFigure.Name = 'covidCrop';

            % Create UIAxes
            app.UIAxes = uiaxes(app.covidCropUIFigure);
            title(app.UIAxes, 'Original Image')
%             xlabel(app.UIAxes, 'Age')
%             ylabel(app.UIAxes, 'Diastolic Blood Pressure')
            app.UIAxes.Interactions = []; 
            app.UIAxes.Toolbar.Visible = 'off';
            app.UIAxes.Position = [0 100 1200 900];

            % Create UITable
            app.UITable = uitable(app.covidCropUIFigure);
            app.UITable.ColumnName = {'Field Name'; 'Value'};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = [true false];
            app.UITable.ColumnEditable = [false false];
%             app.UITable.DisplayDataChangedFcn = createCallbackFcn(app, @UITableDisplayDataChanged, true);
            app.UITable.Position = [1150 50 650 950];

            % Create ImageSelectSpinnerLabel
            app.ImageSelectSpinnerLabel = uilabel(app.covidCropUIFigure);
            app.ImageSelectSpinnerLabel.HorizontalAlignment = 'right';
            app.ImageSelectSpinnerLabel.Position = [340 130 100 22];
            app.ImageSelectSpinnerLabel.Text = 'Image Select';
            
            % Create ImageSelectSpinner
            app.ImageSelectSpinner = uispinner(app.covidCropUIFigure);
            app.ImageSelectSpinner.Position = [450 130 100 22];
            app.ImageSelectSpinner.RoundFractionalValues = 'on';
            app.ImageSelectSpinner.ValueChangingFcn = createCallbackFcn(app, @SelectionChanged, true);
            
            % Create winMinSpinnerLabel
            app.winMinSpinnerLabel = uilabel(app.covidCropUIFigure);
            app.winMinSpinnerLabel.HorizontalAlignment = 'right';
            app.winMinSpinnerLabel.Position = [340 95 100 22];
            app.winMinSpinnerLabel.Text = 'Window Minimum';
            
            % Create winMinSpinner
            app.winMinSpinner = uispinner(app.covidCropUIFigure);
            app.winMinSpinner.Position = [450 95 100 22];
            app.winMinSpinner.RoundFractionalValues = 'on';
            app.winMinSpinner.ValueChangingFcn = createCallbackFcn(app, @WindowChanged, true);
            
            % Create winMaxSpinnerLabel
            app.winMaxSpinnerLabel = uilabel(app.covidCropUIFigure);
            app.winMaxSpinnerLabel.HorizontalAlignment = 'right';
            app.winMaxSpinnerLabel.Position = [340 60 100 22];
            app.winMaxSpinnerLabel.Text = 'Window Maximum';
            
            % Create winMaxSpinner
            app.winMaxSpinner = uispinner(app.covidCropUIFigure);
            app.winMaxSpinner.Position = [450 60 100 22];
            app.winMaxSpinner.RoundFractionalValues = 'on';
            app.winMaxSpinner.ValueChangingFcn = createCallbackFcn(app, @WindowChanged, true);
            
            % Create OriginalFrontalImageButtonGroup
            app.OFImageButtonGroup = uibuttongroup(app.covidCropUIFigure);
            app.OFImageButtonGroup.TitlePosition = 'centertop';
            app.OFImageButtonGroup.Title = 'Original Frontal Image?';
            app.OFImageButtonGroup.Position = [100 50 150 110];

            % Create OriginalButton
            app.OriginalButton = uitogglebutton(app.OFImageButtonGroup);
            app.OriginalButton.Text = 'Frontal Original';
            app.OriginalButton.Position = [12 57 124 22];
            app.OriginalButton.Value = true;

            % Create EnhancedButton
            app.EnhancedButton = uitogglebutton(app.OFImageButtonGroup);
            app.EnhancedButton.Text = 'Frontal Enhanced';
            app.EnhancedButton.Position = [12 36 124 22];

            % Create LateralButton
            app.LateralButton = uitogglebutton(app.OFImageButtonGroup);
            app.LateralButton.Text = 'Lateral (any kind)';
            app.LateralButton.Position = [12 15 124 22];
            
            % Create Lamp
            app.SeenBefore = uilamp(app.covidCropUIFigure);
            app.SeenBefore.Position = [850 100 20 20];
            app.SeenBefore.Enable = 'off';

            % Create winMinSpinnerLabel
            app.SeenBeforeLabel = uilabel(app.covidCropUIFigure);
            app.SeenBeforeLabel.HorizontalAlignment = 'right';
            app.SeenBeforeLabel.Position = [700 100 135 22];
            app.SeenBeforeLabel.Text = 'Image Seen Before?';

            % Show the figure after all components are created
            app.covidCropUIFigure.Visible = 'on';   
            
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = covidCropInterface

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.covidCropUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.covidCropUIFigure)
        end
    end
end