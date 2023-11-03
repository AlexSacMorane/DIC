%% PostProcessing
clear
close all

%% Parameters of the post proccessing

FolderName = 'camera1';
FileName = 'Test.mat';
s = load(strcat(FolderName,'/',... %Folder name
                FileName)); % File name 
            
% Parameter for the display
e11_max = 0.04;
e11_min = 0;

% Time parameters
te = size(s.Displacement.Times,1)-10; % start
ts = te-24; % end

%% Load data

% Load data
Times = s.Displacement.Times;
TimeStep = s.TimeStep ; 
SpatialStep = s.SpatialStep;
SizePixel = s.SizePixel;
Maps = s.Displacement.Maps;
thales = s.thales;

%% Initialization 

% Compute the width of the shear band
ListWidthX = zeros(4,te-ts+1);
ListWidthY = zeros(4,te-ts+1);
ListWidth = zeros(4,te-ts+1);

% Count the number of iteration to do and to plot
IterationCounter = ts-1;
IterationCounterLS = 0;

%% Definition of the figure

%You can change the name of the figure
fEvol = figure('Name','Evolution of Shear Band','Color','white');
fEvolCutX = figure('Name','Cut of Shear Band X','Color','white');
fEvolCutY = figure('Name','Cut of Shear Band Y','Color','white');

%% To make nice plot
% It save only 12 times

ListSaving = ts:te;
ListSaving = ListSaving(1:end);
while size(ListSaving,2)~=24 
    % select random times
    DeleteTime = ent(rand*(size(ListSaving,2)),1)+1;
    ListSaving(DeleteTime) = [];
end

%% Iteration on time

for t = ts:te
    
    IterationCounter = IterationCounter+1;
    if ismember(t,ListSaving)
        IterationCounterLS = IterationCounterLS+1;
    end

    Discretisation_X = s.Displacement.Discretisation_X;
    Discretisation_X = Discretisation_X(t,:);
    Discretisation_X = Discretisation_X - Discretisation_X(1);
    Discretisation_Y = s.Displacement.Discretisation_Y;
    Discretisation_Y = Discretisation_Y(t,:);
    Discretisation_Y = Discretisation_Y - Discretisation_Y(end);
    Vector_X = s.Displacement.Vector_X;
    Vector_X = Vector_X(t,:);
    Vector_Y = s.Displacement.Vector_Y;
    Vector_Y = Vector_Y(t,:);
    
%% Data control

    [Vector_X_c,Vector_Y_c,Discretisation_X_c,Discretisation_Y_c,Maps_c]=DataControl(Maps,Vector_X,Vector_Y,Discretisation_X,Discretisation_Y);

%% Gradient computing

    V1 = zeros(size(Maps_c));
    V2 = zeros(size(Maps_c));
    e11 = zeros(size(Maps_c));
    e22 = zeros(size(Maps_c));
    e12 = zeros(size(Maps_c));
    
    for l = 1:size(Maps_c,1)
        for c = 1:size(Maps_c,2)
            indice = (l-1)*(size(Maps_c,2))+c;
            V1(l,c) = Vector_X_c(indice);
            V2(l,c) = Vector_Y_c(indice);
        end
    end
    
    h=(SpatialStep+SizePixel(1))*thales;
    [Gx1, Gy1] = gradient(V1,h);
    [Gx2, Gy2] = gradient(V2,h);
    X = zeros(size(Maps_c));
    Y = zeros(size(Maps_c));
    
    for l = 1: size(Maps_c,1)
        for c = 1 : size(Maps_c,2)
            indice = (l-1)*size(Maps_c,2) + c ;
            X(l,c)= Discretisation_X_c(indice);
            Y(l,c)= Discretisation_Y_c(indice);
            if Gx1(l,c)<5*e11_max && Gx1(l,c)>0
                e11(l,c) = Gx1(l,c);
            else 
                e11(l,c) = 0;
            end
            e22(l,c)=Gy2(l,c);
            e12(l,c)=(Gy1(l,c)+Gx2(l,c))/2;
        end
    end

    ListCutY = X(1,:); %list of x
    StepX = abs(ListCutY(2)-ListCutY(1));
    ListCutX = Y(:,1)'; %list of y
    StepY = abs(ListCutX(2)-ListCutX(3));

%% Definition of the slides
% A figure window open for the for time step
% You need to select 3 slices
% The position of the cursor defines the slice following x and y axis

    if t==ts
        ViewE11 = figure('Name','Overlook on \epsilon11');

        surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
        set(gca,'DataAspectRatio',[1,1,1])
        xlabel('x')
        ylabel('y')
        TitleName = ['\epsilon_{11} at time ' int2str(IterationCounter)];
        title(TitleName)
        colorbar
        caxis([e11_min e11_max])
        view(2)

        uiwait(msgbox('You have to select 3 slices of \epsilon_{11}'))

        [Cut1_x,Cut1_y] = ginput(1);
        [Cut2_x,Cut2_y] = ginput(1);
        [Cut3_x,Cut3_y] = ginput(1);

        close(ViewE11)

        indiceCutX1 = find(abs(ListCutY-Cut1_x)<StepX/2);
        indiceCutX2 = find(abs(ListCutY-Cut2_x)<StepX/2);
        indiceCutX3 = find(abs(ListCutY-Cut3_x)<StepX/2);

        IndiceCutX = [ indiceCutX1 indiceCutX2 indiceCutX3];

        indiceCutY1 = find(abs(ListCutX-Cut1_y)<StepY/2);
        indiceCutY2 = find(abs(ListCutX-Cut2_y)<StepY/2);
        indiceCutY3 = find(abs(ListCutX-Cut3_y)<StepY/2);

        IndiceCutY = [ indiceCutY1 indiceCutY2 indiceCutY3];

    end

    e11Cut = e11;
    for l = IndiceCutY
        e11Cut(l,:)=1;
    end
    for c = IndiceCutX
        e11Cut(:,c)=1;
    end

%% Cut to interpolate a Gaussian

    %Initialisation of the first parameter
    if t == ts

        InitialParameterX = zeros(3,3); 
        i=1;
        for c = IndiceCutX
            LTempo = zeros(1,size(Maps_c,1));     
            for l = 1:size(Maps_c,1)
                LTempo(l) = max(0,e11(l,c));
            end

            InitialParameterX(i,1) = max(LTempo); %Initialisation on a1x

            Max1 = find(LTempo == max(LTempo)); %find the max

            InitialParameterX(i,2) = ListCutX(Max1(1)); % Initialisation on b1x
            InitialParameterX(i,3) = 0.02; % Initialisation on c1x 
            i=i+1;
        end

        InitialParameterY = zeros(3,3);
        i = 1;
        for l = IndiceCutY
            LTempo = zeros(1,size(Maps_c,2)); 
            for c = 1:size(Maps_c,2)
                LTempo(c) = max(0,e11(l,c));
            end

            InitialParameterY(i,1) = max(LTempo); % Initialisation on a1y

            Max1 = find(LTempo == max(LTempo)); %find the max

            InitialParameterY(i,2) = ListCutY(Max1(1)); % Initialisation on b1y
            InitialParameterY(i,3) = 0.01; % Initialisation on c1y 
            i = i+1;
        end  
    end

%% Interpolation and compute of the width

    c1XL = [0 0 0];
    c1YL = [0 0 0];

%% Initialization

    xDataXs = zeros(size(Maps_c,1),3);
    yDataXs = zeros(size(Maps_c,1),3);
    xDataYs = zeros(size(Maps_c,2),3);
    yDataYs = zeros(size(Maps_c,2),3);
    
%% Iterate on the 3 slices
    for  i = 1:3

        [fitresultX, gof, xDataX, yDataX] = createFitX(ListCutX, e11(:,IndiceCutX(i))', ...
                                                        InitialParameterX(i,1),InitialParameterX(i,2),InitialParameterX(i,3));
        xDataXs(:,i) = xDataX;
        yDataXs(:,i) = yDataX;
        c1X = fitresultX.c1; 
        c1XL(i) = c1X;
        InitialParameterX(i,:)= [fitresultX.a1 fitresultX.b1 fitresultX.c1];

        [fitresultY, gof, xDataY, yDataY] = createFitY(ListCutY, e11(IndiceCutY(i),:), ....
                                                        InitialParameterY(i,1),InitialParameterY(i,2),InitialParameterY(i,3));
        xDataYs(:,i) = xDataY;
        yDataYs(:,i) = yDataY;
        c1Y = fitresultY.c1;
        c1YL(i) = c1Y; 
        InitialParameterY(i,:)= [fitresultY.a1 fitresultY.b1 fitresultY.c1];

        if ismember(t,ListSaving)
            figure(fEvolCutX);
            subplot(4,6,IterationCounterLS)
            hold on
            if i==1 
                plot(fitresultX,'r', xDataX, yDataX,'xr');
            end
            if i==2
                plot(fitresultX,'b', xDataX, yDataX, 'xb');
            end
            if i==3
                plot(fitresultX,'g', xDataX, yDataX, 'xg');
            end
            TitleName = ['Slide following x at t ' int2str(IterationCounter)];
            title(TitleName)
            legend off

            figure(fEvolCutY);
            subplot(4,6,IterationCounterLS)
            hold on
            if i==1 
                plot(fitresultY,'r', xDataY, yDataY, 'xr');
            end
            if i==2
                plot(fitresultY,'b', xDataY, yDataY, 'xb');
            end
            if i==3
                plot(fitresultY,'g', xDataY, yDataY, 'xg');
            end
            TitleName = ['Slide following y at t ' int2str(IterationCounter)];
            title(TitleName)
            legend off
        end
    end

    for i = 1:3
        ListWidthX(i,t-ts+1) = 2*sqrt(log(2))*c1XL(i);
        ListWidthY(i,t-ts+1) = 2*sqrt(log(2))*c1YL(i);
        ListWidth(i,t-ts+1) = (2*sqrt(log(2))*c1XL(i)*c1YL(i))/(sqrt((c1XL(i)^2+c1YL(i)^2)));
    end
    
    % A mean is computed
    ListWidthX(4,t-ts+1) = 2*sqrt(log(2))*mean(c1XL);
    ListWidthY(4,t-ts+1) = 2*sqrt(log(2))*mean(c1YL);
    ListWidth(4,t-ts+1) = (2*sqrt(log(2))*mean(c1XL)*mean(c1YL))/(sqrt((mean(c1XL)^2+mean(c1YL)^2)));

%% Plots

    % To see the evolution of ShearBand
    if ismember(t,ListSaving)

        figure(fEvol)
        subplot(4,6,IterationCounterLS)
        surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
        set(gca,'DataAspectRatio',[1,1,1])
        xlabel('x')
        ylabel('y')
        TitleName = ['\epsilon_{11} at time ' int2str(IterationCounter)];
        title(TitleName)
        colorbar
        caxis([e11_min e11_max])
        view(2)
        
    end

% -------------------------------------------------------------------------
% To see the displacement field no corrected, corrected and e10

% NameFigure = ['At time ' int2str(t)]; 
% figure('Name', NameFigure);
% 
% subplot(131)
% quiver(Discretisation_X_c,Discretisation_Y_c,Vector_X_c,Vector_Y_c)
% set(gca,'ydir','normal');
% set(gca,'DataAspectRatio',[1,1,1])
% xlabel('x')
% ylabel('y')
% TitleName = ['Displacement without correction at time ' int2str(t)];
% title(TitleName)
% 
% % subplot(132)
% quiver(Discretisation_X_c,Discretisation_Y_c,Vector_X_c,Vector_Y_c)
% set(gca,'ydir','normal');
% set(gca,'DataAspectRatio',[1,1,1]);
% xlabel('x')
% ylabel('y')
% TitleName = ['Displacement with correction at time ' int2str(t)];
% title(TitleName)
% 
% subplot(133)
% surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
% set(gca,'DataAspectRatio',[1,1,1])
% xlabel('x')
% ylabel('y')
% TitleName = ['\epsilon_{11} with corrrection at time ' int2str(t)];
% title(TitleName)
% colorbar
% caxis([e11_min e11_max])
% view(2)
% 

%% save data

    NameData = ['Slide_XY_t' int2str(IterationCounter) ];
    save(strcat(FolderName,'/',NameData,'_data.mat'),'xDataXs','yDataXs','xDataYs','yDataYs')    

end

NameDate = 'SlideDefinition' ; 
save(strcat(FolderName,'/',NameData,'_data.mat'),'IndiceCutX','IndiceCutY')

%% Ploting

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

figure('Name','View on slide  of \epsilon_{11}')
subplot(121)
surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
set(gca,'DataAspectRatio',[1,1,1])
xlabel('x')
ylabel('y')
TitleName = ['\epsilon_{11} at time ' int2str(IterationCounter)];
title(TitleName)
colorbar
caxis([e11_min e11_max])
view(2)

subplot(122)
surf(X,Y,e11Cut,'EdgeColor', 'None', 'facecolor', 'interp')
set(gca,'DataAspectRatio',[1,1,1])
xlabel('x')
ylabel('y')
TitleName = ['Slides at time ' int2str(IterationCounter)];
title(TitleName)
colorbar
caxis([e11_min e11_max])
view(2)

% savefig(strcat('/Volumes/Temp_Storage/RunTest/',FolderName,'figure/SlideDefinition_SP',int2str(SP),'.fig'))
% %'D:\Desktop\Data1\',FolderName,
% %% Saving
% 
% savefig(fEvol,strcat('/Volumes/Temp_Storage/RunTest/',FolderName,'figure/EvolutionSB_SP',int2str(SP),'.fig'))
% savefig(fEvolCutX,strcat('/Volumes/Temp_Storage/RunTest/',FolderName,'figure/CutX_SP',int2str(SP),'.fig'))
% savefig(fEvolCutY,strcat('/Volumes/Temp_Storage/RunTest/',FolderName,'figure/CutY_SP',int2str(SP),'.fig'))
% %savefig(fEvol,strcat(FolderName,'/figure/RecognitionSB_SP',int2str(SP),'_discriminant_',int2str(discriminant*1000),'.fig'))

