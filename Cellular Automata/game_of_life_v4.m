clear

n = 101;                % Breite des Gitters
m = 101;                % Höhe des Gitters
T = 1100;               % Ende
t_pause = 0.1;          % Zeit zwischen Iterationen
%r = 1;                 % Radius der Moore Nachbarschaft

% Varianten für Anfangsbedingungen
Init =int8(rand(m,n));  % 50% Wahrsch. für eine lebendige Zelle
%Init = ones(m,n);

Init(1,:)=0;            % Bloecke
Init(3:2:101,:)=0;
Init(:,1)=0;
%Init(49,50)=1;


X=(int8(zeros(m+2,n+2,T)));      %3D-Array für das 2D-Gitter über Zeit
Y=(int8(zeros(m+2,n+2,T))); 

X(2:m+1,2:n+1,1)=Init;   %Übertragen des Anfangszustandes innerhalb des Randes

% Anteil lebendiger Zellen über Zeit
alive(1, T) = 0;

for t=1:T  
    
    for i=1+1:m+1
         for j=1+1:n+1
              for k=i-1:i+1
                  for l=j-1:j+1
                      Y(i,j,t)=Y(i,j,t)+X(k,l,t);    %Werte aller Umgebungszellen werden addiert
                                                     %Y zählt also die lebendigen Nachbarn                             
                  end
              end
              
              if X(i,j,t)== 1
                 if Y(i,j,t)==3                     %Eigentlich ==2, aber die Zelle selbst wird mitgezählt
                     X(i,j,t+1)=1;
                 elseif Y(i,j,t)==4                 %Eigentlich ==3, aber die Zelle selbst wird mitgezählt
                     X(i,j,t+1)=1;
                 else
                     X(i,j,t+1)=0;
                 end      
              elseif X(i,j,t)==0
                  if Y(i,j,t)==3
                      X(i,j,t+1)=1;
                  else
                      X(i,j,t+1)=0;
                  end 
              end
         end     
    end
    % plot
    imagesc(X(2:m+1,2:n+1,t));
    colormap(gray);
    cmap = colormap;
    cmapi = flipud(cmap);
    colormap(cmapi);
    axis equal
    xlim([0.5 n+0.5])
    ylim([0.5 m+0.5])

    pause(t_pause)
    
    alive(t)=sum(sum((X(:,:,t))))/(n*m);
end
    
plot(alive)

