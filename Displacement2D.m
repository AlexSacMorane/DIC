function Displacement = Displacement2D(images,e1sl,e1el,e1sc,e1ec,...
                          limit,SpatialStep,TimeStep,SizePixel,thales,orientation)

Nl = (e1el-e1sl+1 - 2*limit) / (SizePixel(1)+SpatialStep);
Nl = ent(Nl,1);
Nc = (e1ec-e1sc+1 - 2*limit) / (SizePixel(2)+SpatialStep);
Nc = ent(Nc,1);
Ntot = Nl*Nc;

NImage = size(images.Files);
NImage = NImage(1);
Ntimes = ent(NImage/TimeStep-1,1);
    
Maps = zeros(Nl,Nc);
for l = 0: Nl-1
    for c = 0 : Nc-1
        indice = l*Nc + c +1;
        Maps(l+1,c+1) = indice;
    end
end

%% Saving Files

Displacement = struct('Times',zeros(Ntimes,1),...
    'Discretisation_X',zeros(Ntimes,Ntot),'Discretisation_Y',zeros(Ntimes,Ntot),...
    'Vector_X',zeros(Ntimes,Ntot),'Vector_Y',zeros(Ntimes,Ntot),'Maps',Maps,...
    'e11',zeros(Nl,Nc,Ntimes),'e12',zeros(Nl,Nc,Ntimes),'e22',zeros(Nl,Nc,Ntimes));

%% Correlation

for i =1:TimeStep:NImage-TimeStep
   
    % Iterate on times
    Displacement.Times(ent(i,TimeStep)+1)=i;

    % Extract first image (where samples are)
    view1 = rgb2gray(readimage(images,i));
    view1 = imrotate(view1,orientation);
    extract1 = view1(e1sl:e1el,e1sc:e1ec);

    % Extract second image (where search zones are)
    view2 = rgb2gray(readimage(images,i+TimeStep));
    view2 = imrotate(view2,orientation);
    extract2 = view2(e1sl:e1el,e1sc:e1ec);

%% Correlation

    M1 = zeros(2,Ntot);
    M2 = zeros(2,Ntot);
    V = zeros(2,Ntot);
    V1 = zeros(Nl,Nc);
    V2 = zeros(Nl,Nc);
    Discretisation_X = zeros(Ntot);
    Discretisation_Y = zeros(Ntot);
    Vector_X = zeros(Ntot);
    Vector_Y = zeros(Ntot);

    % Iterate in the first picture on the extracted parts
    for l = 0: Nl-1
        for c = 0 : Nc-1

            indice = l*Nc + c +1;
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

%%  Definition of the search zone
% The search zone is in the second picture
% It is where the extracted pictures are correlated

            % You can change the size of the SZ
            % Here the value of 100 and 50 are selected but you can change
            % It depends on the problem
            SZls = max(Sls-100,1);
            SZle = min(Sle,size(extract1,1));
            SZcs = max(Scs-50,1);
            SZce = min(Sce+50,size(extract1,2));
            SearchZone = extract2(SZls:SZle,SZcs:SZce);

%% Looking for the sample in the search zone

            % Compute a correlation map
            cor = normxcorr2(Sample,SearchZone);

            % Find the maximum of the correlation
            [ypeak, xpeak] = find(cor==max(cor(:)));
            yoffSet = ypeak(1)-size(Sample,1) + SZls ;
            xoffSet = xpeak(1)-size(Sample,2) + SZcs ;

            % Convert the pixel information into a positon
            p1 = [Scs;-(Sls)]*thales;
            p2 = [xoffSet;-yoffSet]*thales;

            % Save results
            M1(:,indice)=p1;
            M2(:,indice)=p2;
            V(:,indice)=p2-p1;
            V1(l+1,c+1)=V(1,indice);
            V2(l+1,c+1)=V(2,indice);
            % for plot
            Discretisation_X(indice) = p1(1);
            Discretisation_Y(indice) = p1(2);
            Vector_X(indice) = V(1,indice);
            Vector_Y(indice) = V(2,indice);         
        end
    end
             
%% Compute gradient field

    % Initialisation
    e11 = zeros(Nl,Nc);
    e22 = zeros(Nl,Nc);
    e12 = zeros(Nl,Nc);
    
    % Compute gradients
    h=(SpatialStep+SizePixel(1))*thales;
    [Gx1, Gy1] = gradient(V1,h);
    [Gx2, Gy2] = gradient(V2,h);
    X = zeros(Nl,Nc);
    Y = zeros(Nl,Nc);
    
    for l = 1 : Nl
        for c = 1 : Nc
            indice = (l-1)*size(Maps,2) + c ;
            X(l,c)= M1(1,indice);
            Y(l,c)= M1(2,indice);
            e11(l,c) = Gx1(l,c);
            e22(l,c) = Gy2(l,c);
            e12(l,c) =(Gy1(l,c)+Gx2(l,c))/2;
        end
    end   

    
%% Plot displacement field and strain fields
    
    NameFigure = ['At time ' int2str(i)]; 
    figure('Name', NameFigure);
    
    % Plot displacement field
    subplot(221)
    quiver(Discretisation_X,Discretisation_Y,Vector_X,Vector_Y,10)
    set(gca,'ydir','normal');
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['Displacement field at time ' int2str(i)];
    title(TitleName)
    
    % Plot e11
    subplot(222)
    surf(X,Y,e11,'EdgeColor', 'None', 'facecolor', 'interp')
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['\epsilon_{11} at time ' int2str(i)];
    title(TitleName)
    colorbar
    view(2)
    
    % Plot e22
    subplot(223)
    surf(X,Y,e22,'EdgeColor', 'None', 'facecolor', 'interp')
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['\epsilon_{22} at time ' int2str(i)];
    title(TitleName)
    colorbar
    view(2)
    
    % Plot e12
    subplot(224)
    surf(X,Y,e12,'EdgeColor', 'None', 'facecolor', 'interp')
    set(gca,'DataAspectRatio',[1,1,1])
    xlabel('x')
    ylabel('y')
    TitleName = ['\epsilon_{12} at time ' int2str(i)];
    title(TitleName)
    colorbar
    view(2)
    
    saveas(gcf,strcat('png/t_',int2str(i),'.png'))
    close gcf
    

%% Saving

    Displacement.Discretisation_X(ent(i,TimeStep)+1,:) = M1(1,:);
    Displacement.Discretisation_Y(ent(i,TimeStep)+1,:) = M1(2,:);
    Displacement.Vector_X(ent(i,TimeStep)+1,:) = V(1,:);
    Displacement.Vector_Y(ent(i,TimeStep)+1,:) = V(2,:);
    Displacement.Maps = Maps;
    Displacement.e11(:,:,ent(i,TimeStep)+1) = e11(:,:);
    Displacement.e12(:,:,ent(i,TimeStep)+1) = e12(:,:);
    Displacement.e22(:,:,ent(i,TimeStep)+1) = e22(:,:);
    
end
toc
end
