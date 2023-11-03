function [Vector_X_c,Vector_Y_c,Discretisation_X_c,Discretisation_Y_c,Maps_c]=...
            DataControl(Maps,Vector_X,Vector_Y,Discretisation_X,Discretisation_Y)

    Nc = size(Maps,2);
    Nl = size(Maps,1);
    
    Vector_X_c = Vector_X;
    Vector_Y_c = Vector_Y;
    Vc = [Vector_X_c ; Vector_Y_c];
    V = [Vector_X ; Vector_Y];
    PlateLevel = Nl;
    
    NV = size(V,2);
    NormL = zeros(1,NV);
    for j=1:NV
        NormL(j) = norm(V(:,j)); 
    end
    NormM = mean(NormL);
    
    % Detection
    Blacklist = [] ;% List of errors
    CorrectionNeeded = 0; % Boolean variable
    for j=1:NV
        if NormL(j)>2*NormM
           Blacklist(end+1)=j;
           CorrectionNeeded = 1;
        end
    end

    if CorrectionNeeded == 1
        % Looking for the number of errors per line
        % If there is to many, delete the line   
        BlacklistIndice = 1;
        for l = 1: Nl
           counterLine = 0;
           sl = Nc*(l-1) + 1;
           el = Nc*l;

           for indice = sl:el
               if Blacklist(BlacklistIndice) == indice
                   counterLine = counterLine + 1;
                   BlacklistIndice = min(BlacklistIndice+1,size(Blacklist,2));
               end
           end

           if counterLine > Nc/4 && l>3% The line is false
               PlateLevel = min(PlateLevel,l);
           end 
           
        end
    end
    %PlateLevel = max(PlateLevel,25);
    %Delete all the part with errors
    Discretisation_Y_c = Discretisation_Y(1+Nc:Nc*(PlateLevel-1));
    Discretisation_X_c = Discretisation_X(1+Nc:Nc*(PlateLevel-1));
    
    Maps_c = Maps(2:PlateLevel-1,:);
    
    % Correction
    for j = Blacklist
        %if you want to interpolate the value of V 
        %this is not good if there is a lot of errors
            [l,c]=  find(j==Maps);
            Neighborhood = [;];

            sl = max(1,l-1);
            el = min(Nl,l+1);
            sc = max(1,c-1);
            ec = min(Nc,c+1);

            for ll = sl:el
                for cc = sc:ec
                    if ll~=l || cc~=c
                       indice2 = (ll-1)*Nc + cc;
                       if ismember(indice2,Blacklist)
                       else
                           Neighborhood(:,end+1)=V(:,indice2); 
                       end
                     end
                 end
            end
            if size(Neighborhood,2) == 0
                Vc(:,j) = [0;0];
            else
                Vc(:,j) = mean(Neighborhood,2);
            end
    end
    
    Vector_X_c = Vc(1,:);
    Vector_Y_c = Vc(2,:); 
    
    %Delete all the part with errors
    Vector_Y_c = Vector_Y_c(1+Nc:Nc*(PlateLevel-1));
    Vector_X_c = Vector_X_c(1+Nc:Nc*(PlateLevel-1));
    
