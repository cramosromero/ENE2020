clear;clc;close;
%% Unirá todos los archivos de FEATURES extraidos por Labview en un solo csv
%cd 'D:\GESTOR-INFO\03_FEATS\01_tercio'
%% Lectura de FEATURES desde el Labview por ventana temporal win_t
dir_feats_reads = dir('D:\GESTOR-INFO\03_FEATS\01_tercio\csv_OUT\**\*.csv');
%% LECTURA del ARCHIVO Geogr´ñafica por ventana temporal win_t
dir_geowin_reads = dir('D:\GESTOR-INFO\03_FEATS\ventana_georeferenciada\**\*.csv');
%tabla inicial vacía de geowin
 geowin_folder = dir_geowin_reads(1).folder; %carpeta
 geowin_name = dir_geowin_reads(1).name; %archivo
 TABLE_GW = readtable([geowin_folder '\' geowin_name]); TABLE_GW(end,:)=[];

 %tabla inicial vacía de geowin
 feats_folder = dir_feats_reads(1).folder; %carpeta
 feats_name = dir_feats_reads(1).name; %archivo
 TABLE_F = readtable([feats_folder '\' feats_name]);
 TABLE_F.Var32=[]; %elimio una columna nula
names_feats = table2array(TABLE_F(1,:)); %obtengo los nombres de las características
            names_feats = string(names_feats);
            names_feats(end) = 'level';
            
         
            Name = strcat('L_',strrep(names_feats,'.','_'));
names_feats = cellstr(Name);
TABLE_F.Properties.VariableNames= names_feats;
TABLE_F(1,:)=[]; %borro una fila;
 disp(feats_name)
 disp(geowin_name)
 disp('--0--')

%FEATS_data(1,:)=[]; %borro una fila;
for b = 49:length(dir_geowin_reads)
    geowin_folder = dir_geowin_reads(b).folder; %carpeta
    geowin_name = dir_geowin_reads(b).name; %archivo
    TABLE_g = readtable([geowin_folder '\' geowin_name]); TABLE_g(end,:)=[];
    TABLE_GW = [TABLE_GW; TABLE_g]; %tabla total
   
    feats_folder = dir_feats_reads(b).folder; %carpeta
    feats_name = dir_feats_reads(b).name; %archivo
    TABLE_f = readtable([feats_folder '\' feats_name]); 
         TABLE_f.Var32=[]; %elimio una columna nula
         TABLE_f.Properties.VariableNames = names_feats;
         TABLE_f(1,:)=[]; %borro una fila;
    TABLE_F = [TABLE_F; TABLE_f]; %tabla total
 disp(b)   
 disp(feats_name)
 disp(geowin_name)
 disp('--0--')
end

%% Tabla final
Final_Data = [TABLE_F TABLE_GW];
%% Guardo el CSV generado
mkdir(char(strcat(...
        strcat('D:\GESTOR-INFO\03_FEATS\Data_to_GIS\',...
      strrep(char(geo_file(end-33:end-22)),'-','_')))));
writetable(Final_Data,char(strcat(...
        strcat('D:\GESTOR-INFO\03_FEATS\Data_to_GIS\',...
      strrep(char(geo_file(end-33:end-22)),'-','_'),'\','data2GIS_',...
      strrep(char(feats_file(end-8:end-4)),':','_')),'.csv')),'Delimiter',',');





