%% PostProcessing
clear
close all

%% Data information

% The name of the pictures folder
FolderName = 'save';

% The name of the simulation (the output of the script Displacement 2D.m)
% This is where the data are saved
FileName = 'Test.mat';

% The iteration limits
% To have a faster script, you can focus on iterations where the shear band
% changes (see pictures generated)
ts = 15; % start
te = 23; % stop

% Set a threshold value
% values lower or greater than this will be considered as error
% Need to be set for every postprocessing
min_max_eps = 0.5;

%% Load the data

s = load(strcat(FolderName,'/',... %Folder name
                FileName)); % File name

%% Read data and Initialization

% Read data
TimeStep = s.TimeStep ; % the time step used
Maps = s.Displacement.Maps; % the mesh used
Times = s.Displacement.Times; % the list of the time you used
M1 = s.Displacement.Discretisation_X(1,:); % The x coordinates of the mesh
M2 = s.Displacement.Discretisation_Y(1,:); % The x coordinates of the mesh

% Initialization
ListWidthX = zeros(4,te-ts+1); % 3 slices + 1 mean
ListWidthY = zeros(4,te-ts+1); % 3 slices + 1 mean
ListWidth = zeros(4,te-ts+1); % 3 slices + 1 mean

%% Iteration on time

for t = ts:te

    % Read strain maps
    e11 = s.Displacement.e11(:,:,t);
    e12 = s.Displacement.e12(:,:,t);
    e22 = s.Displacement.e22(:,:,t);

    % Build the map of X and Y
    X = zeros(size(Maps));
    Y = zeros(size(Maps));
    for l = 1 : size(Maps,1)
        for c = 1 : size(Maps,2)
            indice = (l-1)*size(Maps,2) + c ;
            X(l,c)= M1(indice);
            Y(l,c)= M2(indice);
        end
    end

    % Adapt strain maps with the threshold value
    for l = 1 : size(Maps,1)
        for c = 1 : size(Maps,2)
          if e11(l,c) < 0 || min_max_eps < e11(l,c)
            e11(l,c) = 0;
          end
          if e12(l,c) < 0 || min_max_eps < e12(l,c)
            e12(l,c) = 0;
          end
          if e22(l,c) < 0 || min_max_eps < e22(l,c)
            e22(l,c) = 0;
          end
        end
    end

    % Replot the figure
    NameFigure = ['Iteration ' int2str(t-ts+1)];
    figure('Name', NameFigure);

    % Plot e11
    subplot(131)
    surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['\epsilon_{11} at time ' int2str(t-ts+1)];
    title(TitleName)
    colorbar
    view(2)

    % Plot e22
    subplot(132)
    surf(X,Y,e22,'EdgeColor', 'None', 'facecolor', 'interp')
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['\epsilon_{22} at time ' int2str(t-ts+1)];
    title(TitleName)
    colorbar
    view(2)

    % Plot e12
    subplot(133)
    surf(X,Y,e12,'EdgeColor', 'None', 'facecolor', 'interp')
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['\epsilon_{12} at time ' int2str(t-ts+1)];
    title(TitleName)
    colorbar
    view(2)

    saveas(gcf,strcat('png/pp_t_',int2str(t-ts+1),'.png'))
    close gcf

    % Build the list of x/y axis for the slices
    ListCutY = X(1,:); % list of x
    StepX = abs(ListCutY(2)-ListCutY(1));
    ListCutX = Y(:,1)'; % list of y
    StepY = abs(ListCutX(2)-ListCutX(3));

%% Definition of the slides
% At the first iteration, it is asked for the user to select 3 points
% Those points define the slices where the algorithm is applied

    if t==ts
        % Here the overview is on e11
        % It can be on other strain map, just change
        % The same slices are used for the other strain maps

        % Create the figure
        ViewE11 = figure('Name','Overlook on \epsilon11');
        surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
        set(gca,'DataAspectRatio',[1,1,1])
        xlabel('x')
        ylabel('y')
        TitleName = ['\epsilon_{11} at initial time'];
        title(TitleName)
        colorbar
        view(2)
        % wait for the input of the user
        uiwait(msgbox('You have to select 3 slides of \epsilon_{11}'))

        % Receive the information from the GUI
        [Cut1_x,Cut1_y] = ginput(1);
        [Cut2_x,Cut2_y] = ginput(1);
        [Cut3_x,Cut3_y] = ginput(1);

        close(ViewE11)

        % Look for the nearest lines and column
        indiceCutX1 = find(abs(ListCutY-Cut1_x)<StepX/2);
        indiceCutX2 = find(abs(ListCutY-Cut2_x)<StepX/2);
        indiceCutX3 = find(abs(ListCutY-Cut3_x)<StepX/2);

        IndiceCutX = [ indiceCutX1 indiceCutX2 indiceCutX3];

        indiceCutY1 = find(abs(ListCutX-Cut1_y)<StepY/2);
        indiceCutY2 = find(abs(ListCutX-Cut2_y)<StepY/2);
        indiceCutY3 = find(abs(ListCutX-Cut3_y)<StepY/2);

        IndiceCutY = [ indiceCutY1 indiceCutY2 indiceCutY3];
    end

%% Gaussian Interpolation
% The interpolation is made on e11 but you can change the strain map
% Initialization of the first parameters

    if t == ts
        % x slices
        InitialParameterX = zeros(3,3);
        i=1;
        % iterate on the slices indices
        for c = IndiceCutX
            LTempo = zeros(1,size(Maps,1));
            % iterate on the y
            for l = 1:size(Maps,1)
                LTempo(l) = e11(l,c);
            end
            InitialParameterX(i,1) = max(LTempo); % Initialization on a1x
            Max1 = find(LTempo == max(LTempo)); % find the max
            InitialParameterX(i,2) = ListCutX(Max1(1)); % Initialisation on b1x
            InitialParameterX(i,3) = 2; % Initialisation on c1x
            % The parameter cly must be tried and changed if needed
            % It is the width of the sb guessed
            i=i+1;
        end

        % y slices
        InitialParameterY = zeros(3,3);
        i = 1;
        % iterate on the slices indices
        for l = IndiceCutY
            LTempo = zeros(1,size(Maps,2));
            % iterate on the x
            for c = 1:size(Maps,2)
                LTempo(c) = e11(l,c);
            end
            InitialParameterY(i,1) = max(LTempo); % Initialization on a1y
            Max1 = find(LTempo == max(LTempo)); % find the max
            InitialParameterY(i,2) = ListCutY(Max1(1)); % Initialization on b1y
            InitialParameterY(i,3) = 3; % Initialisation on c1y
            % The parameter cly must be tried and changed if needed
            % It is the width of the sb guessed
            i = i+1;
        end

        % To define initial value of c, please see https://fr.mathworks.com/help/curvefit/gaussian.html
        % This documentation will help you to play easily with the
        % parameter and find  the good set
        % you need to load some data
    end

%% Interpolation and compute of the width
% The width is computed from the width obtained on x/y slices

    % Initilization
    c1XL = [0 0 0];
    c1YL = [0 0 0];

    % Plot the result
    NameFigure = ['Iteration ' int2str(t-ts+1)];
    f=figure('Name', NameFigure);
    f.Position = [1 31 1280 617];
    
    % Iteration on the slices
    for  i = 1:3
        % fit
        fitresultX = fit(ListCutX', e11(:,IndiceCutX(i)), 'gauss1',...
                        'StartPoint',[InitialParameterX(i,1),InitialParameterX(i,2),InitialParameterX(i,3)]);
        % look for the parameter c, the variance
        c1X = fitresultX.c1;
        c1XL(i) = fitresultX.c1;
        % update initial guess for next interpolation
        InitialParameterX(i,:)= [fitresultX.a1 fitresultX.b1 fitresultX.c1];

        % fit
        fitresultY = fit(ListCutY', e11(IndiceCutY(i),:)', 'gauss1',...
                         'StartPoint',[InitialParameterY(i,1),InitialParameterY(i,2),InitialParameterY(i,3)]);
        % look for the parameter c, the variance
        c1Y = fitresultY.c1;
        c1YL(i) = c1Y;
        % update initial guess for next interpolation
        InitialParameterY(i,:)= [fitresultY.a1 fitresultY.b1 fitresultY.c1];
    
        % Plot fit x-i
        subplot(3,2,2*i-1)
        plot(fitresultX, ListCutX, e11(:,IndiceCutX(i)),'o')
        title(['X constant, slice ' int2str(i)])
        xlabel('Y')
        ylabel('\Delta\epsilon11')
        % Plot fit y-i
        subplot(3,2,2*i)
        plot(fitresultY, ListCutY, e11(IndiceCutY(i),:),'o')
        title(['Y constant, slice ' int2str(i)])
        xlabel('X')
        ylabel('\Delta\epsilon11')
    
    end
    
    saveas(gcf,strcat('png/pp_fit_t_',int2str(t-ts+1),'.png'))
    close gcf
    

%% Compute the real width of the shear band

    % iterate on the slice
    for i = 1:3
        ListWidthX(i,t-ts+1) = 2*sqrt(2*log(2))*c1XL(i);
        ListWidthY(i,t-ts+1) = 2*sqrt(2*log(2))*c1YL(i);
        ListWidth(i,t-ts+1) = (ListWidthX(i,t-ts+1)*ListWidthY(i,t-ts+1))/(sqrt(ListWidthX(i,t-ts+1)^2+ListWidthY(i,t-ts+1)^2)));
    end

    % Compute the mean
    ListWidthX(4,t-ts+1) = 2*sqrt(2*log(2))*mean(c1XL);
    ListWidthY(4,t-ts+1) = 2*sqrt(2*log(2))*mean(c1YL);
    ListWidth(4,t-ts+1) = (2*sqrt(log(2))*mean(c1XL)*mean(c1YL))/(sqrt((mean(c1XL)^2+mean(c1YL)^2)));

end

%% Save data

save(strcat('save/pp_',FileName),'IndiceCutX','IndiceCutY','ListWidthX','ListWidthY','ListWidth')

%% Plot

figure('Name','Evolution of the width')
subplot(311)
plot(ts:te,ListWidthX(4,:),'-.x')
title('Cut following X')

subplot(312)
plot(ts:te, ListWidthY(4,:),'-.x')
title('Cut following Y')

subplot(313)
plot(ts:te, ListWidth(4,:),'-.x')
title('Real Width')

saveas(gcf,strcat('png/Evolution_SB_width.png'))
close gcf
