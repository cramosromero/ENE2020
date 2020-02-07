%% Une FEATS y GPS Etiquetado
%%{
clear;clc;close all;
%% Proceso automático de lectura TDMS y GPS
%%{
ID = datetime('now', 'Format','dd-MM-yyyy HH:mm');
ID = string(ID); ID = strrep(ID,' ','-');ID = strrep(ID,':','-');
%% REFERENCIA de LABELS
%%{
dir_labels = dir('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\05_Databases\*.xls');
   pathname_labels = dir_labels.folder;
   filename_labels= dir_labels.name;
   filePath_labels = fullfile(pathname_labels,filename_labels);
   LAB = readtable(filePath_labels);
        LAB = sortrows(LAB,11,'ascend'); %ordenamos por columna Order
        %Time
        LAB.t_vec_GPS = datetime(LAB.t_vec_GPS,'Format','HH:mm:ss'); %Lectura correcta de hora 
        LAB.t_vec_GPS = duration(string(LAB.t_vec_GPS));
        LAB.date_vec_G = datetime(LAB.date_vec_G,'Format','dd-MM-yyyy'); %Lectura correcta de fecha  
        %LAB(:,12:39)=[];LAB(:,end)=[];
        %}
%% FEATS
dir_feats = dir('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\04_FEATS_mfcc_2chan\*.csv');
fichas = 1:length(dir_feats);% todos los ficheros
%fichas = [9:15 16:23 24:28 29:32 43:46 47:56];
 %tabla inicial vacía de geowin
 feats_folder = dir_feats(fichas(1)).folder; %carpeta
 feats_name = dir_feats(fichas(1)).name; %archivo
 FEA = readtable([feats_folder '\' feats_name]);
 %{
 %activarlo para los tercios de octava
 names_feats = table2array(FEA(1,:)); %obtengo los nombres de las características
            names_feats = string(names_feats);
            names_feats(32) = 'level';names_feats(end) = 'level'; %renombro la celda de nivel
            ind_channel = string([repmat("A",1,32) repmat("B",1,32)]); %canal A y canal B
            Name0 = ind_channel+'_'+names_feats;
            Name = strrep(Name0,'.','_');
            
names_feats = cellstr(Name);
FEA.Properties.VariableNames = names_feats;
FEA(1,:)=[]; %borro una fila;
%}
disp(feats_name)

%% GPXs _WIN (Ventana) desde la carpeta '03_Geo_Win'
dir_gpx_win = dir('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\03_Geo_Win\*.csv');
%tabla inicial vacía de geowin
 gpx_win_folder = dir_gpx_win(fichas(1)).folder; %carpeta
 gpx_win_name = dir_gpx_win(fichas(1)).name; %archivo
 GW = readtable([gpx_win_folder '\' gpx_win_name],'Delimiter',',');    
        %Time
%         GW.Daate = datetime(char(GW.Daate),'Format','dd-MM-yyyy'); %Lectura correcta de hora  
%         GW.Daate = datetime(GW.Daate,'Format','dd-MM-yyyy'); %Lectura correcta de fecha 
%         GW.Tiime = datetime(char(GW.Tiime),'Format','HH:mm:ss'); %Lectura correcta de hora
%         GW.Tiime = duration(string(GW.Tiime));
disp(gpx_win_name)
disp('--0--')
 exte = min(height(FEA),height(GW)); %limita la extención de datos
 GW = GW(1:exte,:);
 FEA = FEA(1:exte,:);
%clearvars -except dir_labels dir_feats dir_gpx_win TAB_LAB    TABLE_F   TABLE_GW
for regis = 2: length(fichas)
    disp(regis)
   pathname_feats = dir_feats(fichas(regis)).folder;
   filename_feats= dir_feats(fichas(regis)).name;
   filePath_feats = fullfile(pathname_feats,filename_feats);
   feats = readtable(filePath_feats);
         %feats.Properties.VariableNames = names_feats; %activarlo en tercio de octava
         feats(1,:)=[]; %borro una fila;
        
   pathname_gpx_win = dir_gpx_win(fichas(regis)).folder;
   filename_gpx_win = dir_gpx_win(fichas(regis)).name;
   filePath_gpx_win = fullfile(pathname_gpx_win,filename_gpx_win);
   gpx_win = readtable(filePath_gpx_win,'Delimiter',',');
%    gpx_win.Daate = datetime(gpx_win.Daate,'Format','dd-MM-yyyy'); %Lectura correcta de hora 
%    gpx_win.Tiime = datetime(char(gpx_win.Tiime),'Format','HH:mm:ss'); %Lectura correcta de hora
%    gpx_win.Tiime = duration(string(gpx_win.Tiime));
exte = min(height(feats),height(gpx_win)); %limita la extención de datos
gpx_win = gpx_win(1:exte,:);
feats = feats(1:exte,:);
    FEA = [FEA; feats]; %tabla total
    GW = [GW; gpx_win]; %tabla total
      
disp(filename_feats)
disp(filename_gpx_win)
end

 %}
%clearvars -except LAB    FEA   GW

%% ASIGNADOR de ETIQUETA
%%{
%fechas y horas para comparación
Date_GW = datetime(GW.date_vec_GPS, 'InputFormat', 'dd-MM-yyyy HH:mm:ss');
%dt_GW = Date_GW + GW.t_vec_GPS; %por si está separado la hora y el tiempo
Date_GW.Format ='dd-MM-yyyy HH:mm:ss';

dt_LB = LAB.date_vec_G + LAB.t_vec_GPS;
dt_LB.Format ='yyyy-MM-dd HH:mm:ss';
%}
IDX = (1:height(LAB)).';
Class =  zeros(height(GW),1);
for fecha_GW = 1:height(GW)
    logicos = Date_GW(fecha_GW)==dt_LB;
    index = IDX.*logicos;
    index(index==0) = [];
    Class(fecha_GW)= LAB.Label(index); %clase o Carretera
end
Class = array2table(Class);
DATASET = [GW FEA Class];
%% DATA SET PARA ML
destino5 = char('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\06_DATA_ML');
mkdir(destino5)

writetable(DATASET,char(strcat(...
        strcat(destino5,'\','Generado_',char(ID)),'.csv')),'Delimiter',',');
