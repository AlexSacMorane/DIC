clear
close all
tic

%% Data information

% The name of the pictures folder
% There is one folder per camera spot
FolderName = 'camera1';

% The name of the simulation (it must end with '.mat')
% This name is used to save data
FileName = 'Test.mat';


%% Show the picture and select the extract zone

% Put 1==0 if you do not want to run
% Put 1==1 if you want to run
if 1==0
    % Load all pictures
    images = imageDatastore(fullfile(FolderName));
    % Take a picture in the middle of the test
    % The number 39 is a random number and can be changed
    image = readimage(images,39);
    % You can rotate the picture if you want
    % The angle is in degree 
    image=imrotate(image,-90);
    % A new window opens with your picture
    figure
    imshow(image)
    imrect(gca,[1 1 100 100])
end


%% Information given by the previous section
% Run the previous one to fill those information
% Help is given in the README.md

extraction = [216 ;
              1090;
              400 ;
              790];

% Orientation of picture
PictureOrientation = [-90];

% Scalling Factor
thalesL = [0.1/3825.6170212766];

%% Parameters of the postprocessing

% Picture Folder
images = imageDatastore(fullfile(FolderName));    

% Extract data
e1sl = extraction(1);
e1el = extraction(2);
e1sc = extraction(3);
e1ec = extraction(4);

% Orientation Defaut
Orientation = PictureOrientation(1);

% Scalling Factor
% Real height / height on the focal plan
thales=thalesL(1);

% Time Step
TimeStep = 1;

% Limits
limit = 5 ;

% Space for the discretisation
SpatialStep = 5 ;

% Size Sample for the discretisation
SizePixelValue = 30 ;
% [line column]
% See the beginning of the code to change the value
SizePixel = [SizePixelValue SizePixelValue] ;

%% To see the discretisation

% Put 1==0 if you do not want to run
% Put 1==1 if you want to run
if 1==0
    % Load all pictures
    images = imageDatastore(fullfile(FolderName));
    % Take a picture in the middle of the test
    % The number 30 is a random number and can be changed
    image = readimage(images,30);
    % Rotate the picture 
    view1 = imrotate(image,Orientation);
    % Extract the zone defined sooner
    extract1 = view1(e1sl:e1el,e1sc:e1ec);
    
    % Compute the mesh
    Nl = (e1el-e1sl+1 - 2*limit) / (SizePixel(1)+SpatialStep);
    Nl = ent(Nl,1);
    Nc = (e1ec-e1sc+1 - 2*limit) / (SizePixel(2)+SpatialStep);
    Nc = ent(Nc,1);
    Ntot = Nl*Nc;
    
    % Open a new figure window and show the mesh
    figure()
    imshow(extract1)
    for l = 0:Nl-1
        for c = 0:Nc-1
            indice = l * Nc + c + 1;
            disp(indice/Ntot)
            % Create the mesh in the window
            imrect(gca,[limit+c*(SpatialStep+SizePixel(2))+1 ...
                        limit+l*(SpatialStep+SizePixel(1))+1 ...
                        SizePixel(2) SizePixel(1)]);
        end
    end
    title('Picture and Discretisation')
end

%% What do you want ?

% Displacement 2D
Displacement = Displacement2D(images,e1sl,e1el,e1sc,e1ec,...
                           limit,SpatialStep,TimeStep,SizePixel,thales,Orientation);

%% Saving

save(strcat(FolderName,'/',FileName),'Displacement',...
    'e1sl','e1el','e1sc','e1ec','images','Orientation',...
    'thales','TimeStep','limit','SpatialStep','SizePixel');

toc
