function Displacement = Displacement2D(images,e1sl,e1el,e1sc,e1ec,...
                          limit,SpatialStep,TimeStep,SizePixel,thales,orientation)
TimeStep2=2;
Nl = (e1el-e1sl+1 - 2*limit) / (SizePixel(1)+SpatialStep);
Nl = ent(Nl,1);
Nc = (e1ec-e1sc+1 - 2*limit) / (SizePixel(2)+SpatialStep);
Nc = ent(Nc,1);
Ntot = Nl*Nc;                     

NImage = size(images.Files);
NImage = NImage(1); 
Ntimes = ent(NImage/TimeStep-1,1);

%% Saving Files

Displacement = struct('Times',zeros(Ntimes,1),...
    'Discretisation_X',zeros(Ntimes,Ntot),'Discretisation_Y',zeros(Ntimes,Ntot),...
    'Vector_X',zeros(Ntimes,Ntot),'Vector_Y',zeros(Ntimes,Ntot),'Maps',[]);

                      
%% Information                     
                     

px = 0.0149/2;
py = 0.0223/2;
sf=0.0149/3456; % pixel to meter


%% Correlation 

for i =1:TimeStep:NImage-TimeStep2
    
    Displacement.Times(ent(i,TimeStep)+1)=i;
    
    view1 = rgb2gray(readimage(images,i)); 
    view1 = imrotate(view1,orientation);
    extract1 = view1(e1sl:e1el,e1sc:e1ec);
        
    view2 = rgb2gray(readimage(images,i+TimeStep2)); 
    view2 = imrotate(view2,orientation);
    extract2 = view2(e1sl:e1el,e1sc:e1ec);




%% Discretisation of picture extract
Nl = (size(extract1,1) - 2*limit) / (SizePixel(1)+SpatialStep);
Nl = ent(Nl,1);
Nc = (size(extract1,2) - 2*limit) / (SizePixel(2)+SpatialStep);
Nc = ent(Nc,1);
Ntot = Nl*Nc;

if 1==0
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
    title('Image 1 échantillonée')
end


% figure
% imshow(extract2)
% title('Image2 recherchée')
%% Correlation

Maps = zeros(Nl,Nc);
M1 = zeros(2,Ntot);
M2 = zeros(2,Ntot);
V = zeros(2,Ntot);
V1 = zeros(Nl,Nc);
V2 = zeros(Nl,Nc);
e11 = zeros(Nl,Nc);
e22 = zeros(Nl,Nc);
e12 = zeros(Nl,Nc);


for l = 0: Nl-1

    for c = 0 : Nc-1
        
        indice = l*Nc + c +1; 
        Maps(l+1,c+1) = indice;
        disp(strcat('Iteration on time:_',int2str(Ntimes),'_max'))
        disp(ent(i,TimeStep)+1)
        disp('Iteration on space')
        disp(indice/Ntot)
        
        %Definition of the sample
        Sls = limit+l*(SpatialStep+SizePixel(1))+1;
        Sle = limit+l*(SpatialStep+SizePixel(1))+1+SizePixel(1);
        Scs = limit+c*(SpatialStep+SizePixel(2))+1;
        Sce = limit+c*(SpatialStep+SizePixel(2))+1+SizePixel(2);
        Sample = extract1(Sls:Sle,Scs:Sce);  
        
%%  You can change the size of the SZ
% 
        
        %Definition of the search zone
        SZls = max(Sls-300,1);
        SZle = min(Sle,size(extract1,1));
        SZcs = max(Scs-100,1);
        SZce = min(Sce+100,size(extract1,2));
        SearchZone = extract2(SZls:SZle,SZcs:SZce);               
 
%%        
        
        %looking for the sample in the search zone
        cor = normxcorr2(Sample,SearchZone);
        %figure, surf(cor), shading flat, xlabel('x')

        [ypeak, xpeak] = find(cor==max(cor(:)));
        yoffSet = ypeak(1)-size(Sample,1);
        xoffSet = xpeak(1)-size(Sample,2);
                
%          figure()
%          imshowpair(SearchZone,Sample,'montage')
%          imrect(gca,[xoffSet+1, yoffSet+1, size(Sample,2), size(Sample,1)]);

        yoffSet = ypeak(1)-size(Sample,1) +SZls ;
        xoffSet = xpeak(1)-size(Sample,2) +SZcs ;
        
        %imrect(gca,[xoffSet ...
        %           yoffSet ...
        %            SizePixel(2) SizePixel(1)]);
                
        p1 = [Scs-px/sf;py/sf-(Sls)]*thales;
        p2 = [xoffSet-px/sf;py/sf-yoffSet]*thales;     
        %correction of p2 because of the plateform movement
          
        M1(:,indice)=p1;
        M2(:,indice)=p2;
        
        V(:,indice)=p2-p1;
       
        V1(l+1,c+1)=V(1,indice);        
        V2(l+1,c+1)=V(2,indice);
               
    end   
end



%% Saving

Displacement.Discretisation_X(ent(i,TimeStep)+1,:) = M1(1,:);
Displacement.Discretisation_Y(ent(i,TimeStep)+1,:) = M1(2,:);
Displacement.Vector_X(ent(i,TimeStep)+1,:) = V(1,:);
Displacement.Vector_Y(ent(i,TimeStep)+1,:) = V(2,:);
Displacement.Maps = Maps;


end
toc
