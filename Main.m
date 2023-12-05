clear
close all
tic

%% Data information

% The name of the pictures folder
% There is one folder per camera spot
FolderName = 'images_1';

% The name of the simulation (it must end with '.mat')
% This name is used to save data
FileName = 'Test.mat';

%% Sort pictures

% Put 1==1 if you  want to do this step
% Put 1==0 if you  want to skip this step
if 1==0
    % Count the number of pictures
    D = dir(FolderName);
    size_D = size(D,1);
    counter_no_file = 0;

    % Count the number of file which are not pictures
    for i = 1:size_D
        if D(i).isdir
            counter_no_file = counter_no_file + 1;
        end
    end    

    number_picture = size_D - counter_no_file;

    % Rename picture if the number is larger than 100
    if number_picture >= 100
        % Give a template for the name file
        template_name = 'test18camera2_Movie_Ref_Step';
        % Give the extension name
        extension_name = '.jpeg';
        % Change the name of pictures until 99
        for i = 0:99
            if i <10
                chr = strcat('0',int2str(i));
            else 
                chr = int2str(i);
            end
            oldName = strcat(FolderName,'/',template_name,chr,extension_name);
            newName = strcat(FolderName,'/',template_name,'0',chr,extension_name);
            movefile(oldName,newName);
        end
    end
end

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

save(strcat('save/',FileName),'Displacement',...
    'e1sl','e1el','e1sc','e1ec','Orientation',...
    'thales','TimeStep','limit','SpatialStep','SizePixel');

toc
