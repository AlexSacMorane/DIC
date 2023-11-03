%% This is to rank picture in folder and create a document to put information
% Be sure pictures are ranked (not randomly) and run once 

% Change the name of the folder
FolderName = '30-07-durham-sand-f26';

% Put the number of camera you have
NC = 3;

% Put the indice of the first picture
sp = 1;

% Put the indice of the last picture
ep = 123;



%% Don't change

% create the information document about the test
Info= fopen(strcat(FolderName,'/Info.txt'),'w');
fprintf(Info,'%s\n','Time Lapse parameter = each [Complete Value] s');
fprintf(Info,'%s\n','Quality of views');
fprintf(Info,'%s\n','C1');
fprintf(Info,'%s\n','C2');
fprintf(Info,'%s\n','C3');
fclose(Info);


mkdir(strcat(FolderName,'/figure'))
mkdir(strcat(FolderName,'/data'))

for i = 1:NC
    nom=strcat(FolderName,'/C',int2str(i))
    mkdir(nom)
end

compteur = 1
for i = sp:ep
    if i>0 && i<10
        nomfile = strcat(FolderName,'/DSC_000',int2str(i))
    end
    if i>9 && i<100
        nomfile = strcat(FolderName,'/DSC_00',int2str(i))
    end
    if i>99 && i<1000
        nomfile = strcat(FolderName,'/DSC_0',int2str(i))
    end
   
    nomfolder = strcat(FolderName,'/C',int2str(compteur))
    compteur =compteur +1
    if compteur == NC+1
        compteur =1
    end
    nomfile =strcat(nomfile,'.jpg')
    copyfile(nomfile,nomfolder)
end



