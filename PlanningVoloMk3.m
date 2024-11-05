%Dati del volo
flag="Start";
check=1;
execNum=0;

while flag ~= "Esci"
execNum=execNum+1;


    
Choice ='No';
    %if flag=="Start"
Choice = questdlg('Vuoi usare i dati di default?','Utilizzo dati','Si','No','No');
    %end

switch Choice

    case 'No'
        while check>=1
        DV = inputdlg({'1-Scala di restituzione (Solo il secondo termine)','2-Ricoprimento longitudinale (percentuale)','3-Ricoprimento trasversale (percentuale)','4-Velocità di volo [m/s]'},'Dati di volo');
        CamG = inputdlg({'1-Focale [mm]','2-Lx [mm]','3-Ly [mm]','4-Dimensione pixel [Micron]'},'Geometria interna della camera');
        DimA= inputdlg({'1-Distanza longitudinale [m]','2-Distanza trasversale [m]'},'Dimensioni area');
        
        check = isempty(DV) | isempty(CamG) | isempty(DimA);
        StrCheck=vertcat(DV,CamG,DimA);

        for i=1:10 & check ~= 1
            if strcmp(StrCheck(i),'')
                fprintf("Errore inserimento dati");
                return
            end
        end

        end

        DV=str2double(DV');
        CamG=str2double(CamG');
        DimA=str2double(DimA');

    case 'Si'
        disp('Utilizzo dati default')

 %------precaricamento dati di defauult-----------------
        DV=[100 80 60 5];
        CamG=[8.8 13.2 8.8 2.4];
        DimA=[110 90];
       
end

%assegnazione dati



Scala=DV(1);

Ricoprimento_Longitudinale=DV(2);

Ricoprimento_Trasversale=DV(3);

Vel_Volo=DV(4);

Precisione=0.2*Scala;
DV(5)=Precisione;

Focale=CamG(1);

lx=CamG(2);

ly=CamG(3);

Dimensione_pixel=CamG(4);


%Creazione tabella dati
Valore=horzcat(DV,CamG,DimA);
Valore=Valore';

Variabile=["Scala";"Rcopriento longitudinale";"Ricoprimento trasversale";"Velocità di volo";"Precisione";"Distanza focale";"lx";"ly";"Dimensione pixel";"Distanza longitudinale";"Distanza trasversale"];
Grandezza=["1 a ";"%";"%";"m/s";"mm";"mm";"mm";"mm";"Micron";"m";"m"];


%elementi scenografici
fprintf('Raccolta dati');
for i=1:10
    fprintf('.')
    pause(0.1)
end
%------------------------

Tabella=table(Variabile,Valore,Grandezza);

fprintf('\n\n');
for i=1:length(Variabile)
    if i==1
        fprintf('%s: %s%d \n',Variabile(i),Grandezza(i),Valore(i)); %print della scala
    else
    fprintf('%s: %.2f%s \n',Variabile(i),Valore(i),Grandezza(i));
    end
end
fprintf('\n\n');

%Calcoli%


Risultati.Tolleranza=Precisione*2;

Risultati.GSD=Precisione/2;

Risultati.H_Max=Risultati.GSD*Focale/Dimensione_pixel;

Risultati.AbbracciamentoLx=lx*Risultati.H_Max/Focale;

Risultati.AbbracciamentoLy=ly*Risultati.H_Max/Focale;

Risultati.SovrapposizioneTrasversale=Risultati.AbbracciamentoLx*Ricoprimento_Trasversale/100;

Risultati.SovrapposizioneLongitudinale=Risultati.AbbracciamentoLy*Ricoprimento_Longitudinale/100;

Risultati.BaseDiPresa=Risultati.AbbracciamentoLx*(1-Ricoprimento_Longitudinale/100);

Risultati.Interasse=Risultati.AbbracciamentoLy*(1-Ricoprimento_Trasversale/100);

Risultati.TempoTraScatti=Risultati.BaseDiPresa/Vel_Volo;

Risultati.StrisciateX=DimA(1)/Risultati.Interasse;

Risultati.StrisciateY=DimA(2)/Risultati.Interasse;

%Fine calcoli


Misure=["mm";"mm";"m";"m";"m";"m";"m";"m";"m";"s";"(intero)";"(intero)"];

Variabili=string(fieldnames(Risultati));


Risultati_Elaborazione=struct2array(Risultati);

Risultati_Elaborazione=round(Risultati_Elaborazione);



Risultati_Elaborazione=Risultati_Elaborazione';


%elementi scenografici
fprintf('Elaborazione');
for i=1:10
    fprintf('.')
    pause(0.1)
end
%------------------------

%T=table(Variabili,Risultati_Elaborazione,Misure);
fprintf('\n\n');
for i=1:length(Variabili)
    fprintf('%s: %d%s \n',Variabili(i),Risultati_Elaborazione(i),Misure(i));
end


if execNum==1
    tiledlayout(2,2)
end
nexttile

img = imread('Immagine.png');
image('CData',img,'XData',[0 DimA(1)],'YData',[DimA(2) 0]);
hold on

xlabel('Metri [m]') 
ylabel('Metri [m]') 

strX=linspace(0,DimA(1),Risultati_Elaborazione(12));
xline(strX,'-r');
lx1=xline(0,'-r');

strY=linspace(0,DimA(2),Risultati_Elaborazione(11));
yline(strY,'-b');
ly1=yline(0,'-b');
legend([lx1 ly1],{'Trasversali','Longitudinali'})


fprintf('\n\n');

flag = questdlg('Vuoi apportare modifiche?','Menu',"Si","Esci","Esci");
end