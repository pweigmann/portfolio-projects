clear

n=100;      % Breite des 1-D Automaten
k=2;        % Anzahl Möglicher Zustände eines Feldes 
r=1;        % Einfluss-Radius

t=1;
T=100;       % Anzahl Schritte

a=zeros(T,n+2); % Initialisierung plus Rand mit Breite 1

a(t,:)=int8(rand(1,n+2)*(k-1));   % Zufälliger Anfangszustand
% a(t,:)=1;                       % alle Zellen Zustand 1

regel=input('Wolfram Regel Nr: ')

% Umrechnung der Regel in Binärzahl 
% regel_b(1) entspr. 2^0=1, regel_b(2) entspr. 2^1=2, etc.
% (einfacher mit "bitget(regel,1:8)"

for k=8:-1:1
    regel_b_char(k) = dec2bin(mod(regel, 2^k)/(2^(k-1)));
end

regel_b = int8(regel_b_char)-48 % Ausgleich für Umwandlung von char zu int8

for t=1:T+1
    for i=2:(n+1)
        % Randbedingungen
        % Periodische RB
        a(t,1)=a(t,n+1);    %linkester Rand entspricht rechtester Zelle
        a(t,n+2)=a(t,2);    %rechter Rand entspricht linkester Zelle

        % Gespiegelte RB
        % a(t,1)=a(t,2);      %linkester Rand entspricht linkester Zelle
        % a(t,n+2)=a(t,n+1);  %rechter Rand entspricht rechtester Zelle

        % Konstante RB
        % a(t,1)=1;
        % a(t,n+2)=0;


        % Regeln
        % Modulo-Regel
        % a(t+1,i)=mod((a(t,i-1)+a(t,i)+a(t,i+1)),2)

        % Allgemeine Wolfram-Regeln 0-255 (einfachster Automat)
        if     [a(t,i-1),a(t,i),a(t,i+1)]==[0,0,0]
            a(t+1,i)=regel_b(1);
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[0,0,1]
            a(t+1,i)=regel_b(2);
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[0,1,0]
            a(t+1,i)=regel_b(3);    
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[0,1,1]
            a(t+1,i)=regel_b(4);
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[1,0,0]
            a(t+1,i)=regel_b(5);
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[1,0,1]
            a(t+1,i)=regel_b(6);
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[1,1,0]
            a(t+1,i)=regel_b(7);
        elseif [a(t,i-1),a(t,i),a(t,i+1)]==[1,1,1]
            a(t+1,i)=regel_b(8);
        end 
    end       
end

% plot
imagesc(a)
colormap(gray);
cmap = colormap;
cmapi = flipud(cmap);
colormap(cmapi);
axis equal
xlim([1.5 n+1.5])
