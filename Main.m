%% Parameter to define

% | Test | Dossier Image | Extraction | Pas de temps | Facteur d'échelle |
% | R3D  |  2 pictures   |     x      |       0      |                   |
% | D2D  |   1 folder    |     x      |       x      |                   |
% | RD3D |   2 folders   |     x      |       x      |                   |

% | Test | Bordure | Ecart entre échantillon | Taille | Focale | Cameras |
% | R3D  |    x    |              x          |   x    |    x   |    x    |
% | D2D  |    x    |              x          |   x    |    0   |    0    |
% | RD3D |    x    |              x          |   x    |    x   |    x    |

% x Needed
% 0 No needed

%% 
clear
close all
tic

for NCamera = 2:2
%% Data information
% All in str
% You have to change it

Date = '31JUL2019_'; %Number of camera

%NCamera = 1; %Numero of camera

Specificity = '_f24_'; % Granulometry or Fractal indice

Sand = 'Durham_'; %Kind of sand

Speed = '2mm_min_';%Speed of the plate

Pressure = '40Mpsi_' ; %Pressure

TimeLapse = '30sec' ; %TimeLapse 

SizePixelValue = 75; % Size for the discretisation

FileName = strcat(Date,int2str(NCamera),Specificity,Sand,Speed,Pressure,TimeLapse,...
    strcat('_SP',int2str(SizePixelValue)),'.mat');
%SP is about the SizePixel (see after). This mention is used when you make
%different discretization. Be sure it aggres with the variable 'SizePixel'




FolderName = '31-07-durham-sand-f24';%SP is about the SizePixel (see after). This mention is used when you make
%different discretisation. Be sure it aggres with the variable 'SizePixel'






%% Show the picture and select the extract zone

if 1==0
    for i = 1:3
        images = imageDatastore(fullfile(strcat(FolderName,'/C',int2str(i))));
        image = readimage(images,39);
        if i == 1 
            image=imrotate(image,-90);
        else
            image=imrotate(image,90);
        end
        figure
        imshow(image)
        imrect(gca,[1 1 100 100])
   
    end
end


%%

extraction = [478.957446808510 172.574468085106 380.914893617021;
              2478.53191489362 2386.61702127660 2386.61702127659;
              975.297872340425 301.255319148936 809.851063829787;
              3054.53191489362 2840.06382978724 3072.91489361702];



% Orientation of picture
PictureOrientation = [-90 90 90];

% Scalling Factor

thalesL = [0.1/3825.6170212766 0.1/3766.29787234043 0.1/3415.06382978723];





%%
 i = NCamera;
    disp('---------------------------------------')
    disp('---------------------------------------')
    disp(strcat('C',int2str(i)))
    disp('---------------------------------------')
    disp('---------------------------------------')
    
    
sf=0.0149/3456;

% Picture Folder 
    %imageDatastore(fullfile('Dossier')) or imread('Files')
    images = imageDatastore(fullfile(strcat(FolderName,'/C',int2str(i))));
    %images2 = readimage(images,2);
    %images1 = imread('Images/1_0.JPG'); 

% Focale lens
    % In meters
    f = 0.055*1.6;

% Focale lens
    % In meters
    f = 0.055*1.6;
    

    
    
% Extract data

    e1sl = extraction(1,i);
    e1el = extraction(2,i);
    e1sc = extraction(3,i);
    e1ec = extraction(4,i);
    
% For 3D Reconstruction
%     e2sl = extraction2(1,i+1);
%     e2el = extraction2(2,i+1);
%     e2sc = extraction2(3,i+1);
%     e2ec = extraction2(4,i+1);

% Orientation Defaut  
    Orientation = PictureOrientation(i);
    
% Scalling Factor
    % Real height / height on the focal plan
    thales=thalesL(i);
    
% Time Step
    TimeStep = 1;
        
% Limits 
    limit = 5 ;
    
% Space for the discretisation
    SpatialStep = 10 ;

% Size Sample for thediscretisation
    % [line column]
    % See the beginning of the code to change the value
    SizePixel = [SizePixelValue SizePixelValue] ;
  
   

  
  
    
%% To see the discretisation

if 1==0
    images = imageDatastore(fullfile(strcat(FolderName,'/C',int2str(NCamera))));
    view1 = rgb2gray(readimage(images,i)); 
    view1 = imrotate(view1,90);
    extract1 = view1(e1sl:e1el,e1sc:e1ec);
    
    
    Nl = (e1el-e1sl+1 - 2*limit) / (SizePixel(1)+SpatialStep);
    Nl = ent(Nl,1);
    Nc = (e1ec-e1sc+1 - 2*limit) / (SizePixel(2)+SpatialStep);
    Nc = ent(Nc,1);
    Ntot = Nl*Nc;
    
    figure()
    imshow(extract1)
    for l = 0:Nl-1
        for c = 0:Nc-1
            indice = l * Nc + c + 1;
            disp(indice/Ntot)

            imrect(gca,[limit+c*(SpatialStep+SizePixel(2))+1 ...
                        limit+l*(SpatialStep+SizePixel(1))+1 ...
                        SizePixel(2) SizePixel(1)]);
        end
    end
    title('Picture and Discretisation')
    
end


    
%% What do you want ?

% Reconstruction 3D
% R3D = Reconstruction3D(images1,images2,...
%                           e1sl,e1el,e1sc,e1ec,...
%                           e2sl,e2el,e2sc,e2ec,...
%                           limit,SpatialStep,SizePixel,f,...
%                           C1,theta1,C2,theta2);

% ObjRecons(:,end+1:end+size(R3D,2))=R3D;

% Displacement 2D
 Displacement = Displacement2D(images,e1sl,e1el,e1sc,e1ec,...
                           limit,SpatialStep,TimeStep,SizePixel,thales,Orientation);


 
% Reconstruction 3D et Déplacement 3D
% ReconstructionAndDisplacement3D(images1,images2,...
%                                          e1sl,e1el,e1sc,e1ec,...
%                                          e2sl,e2el,e2sc,e2ec,...
%                                          TimeStep,thales1,thales2,...
%                                          limit,SpatialStep,SizePixel,...
%                                          f,C1,theta1,C2,theta2);
% 
% Reconstruction 3D with Ray-Tracking
% ReconstructionAndDisplacement3DRT(images1,images2,...
%                                          e1sl,e1el,e1sc,e1ec,...
%                                          e2sl,e2el,e2sc,e2ec,...
%                                          TimeStep,thales1,thales2,...
%                                          limit,SpatialStep,SizePixel,...
%                                          f,C1,theta1,C2,theta2);
% Parameter of refraction indice for exemple are in Snell_3D, need to be in
% main


% Reconstruction 3D with Ray-Tracking
% Displacement2DRT(images,e1sl,e1el,e1sc,e1ec,...
%                  limit,SpatialStep,TimeStep,SizePixel,thales,f);
% Parameter of refraction indice for exemple are in Snell_3D, need to be in
% main
% More Over Sh is computed but not used
                                     
% Need to be coded

%% Do you want more ?

% Adapt the Searchzone 
% Geometric deformation
% Camera deformation


%% Saving

save(strcat(FolderName,'/',FileName),'Displacement','f',...
    'SizePixel','SpatialStep','limit','thales','TimeStep',...
    'e1sl','e1el','e1sc','e1ec','images','Orientation');



end

toc
 




