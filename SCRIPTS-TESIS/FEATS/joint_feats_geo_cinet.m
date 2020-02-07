clear;clc;close
%% LECTURA del ARCHIVO DE FEATURES
[FEATS_data,pth_feats_csv] = uigetfile('D:\GESTOR-INFO\03_FEATS\01_tercio\*.csv',...
                                   'CSV file of FEATS');
feats_file = fullfile(pth_feats_csv, FEATS_data);
FEATS_data = readtable(feats_file); %loeo la tabla
FEATS_data.Var32=[]; %elimio una columna nula

names_feats = table2array(FEATS_data(1,:)); %obtengo los nombres de las características
            names_feats = string(names_feats);
            names_feats(end) = 'level';
            
FEATS_data(1,:)=[]; %borro una fila;
for b=1:length(names_feats)
    names_feats(b)=strrep(names_feats(b),'.','_');
   Name(b) = strcat('B_',names_feats(b));
end
names_feats = cellstr(Name);
FEATS_data.Properties.VariableNames= names_feats;
%% LECTURA del ARCHIVO DE GEOREFERENCIAS
[GEO_data,pth_geo_csv] = uigetfile('D:\GESTOR-INFO\03_FEATS\ventana_georeferenciada\*.csv',...
                                   'CSV file of GEO an CINEMAT');
geo_file = fullfile(pth_geo_csv, GEO_data);
GEO_data = readtable(geo_file);
GEO_data(1,:)=[]; %borro una fila;

ID = (1:height(GEO_data)).';
ID = table(ID,'VariableNames',{'ID'});
%% Tabla final
Final_Data = [ID FEATS_data GEO_data ];
%% Guardo el CSV generado
mkdir(char(strcat(...
        strcat('D:\GESTOR-INFO\03_FEATS\Data_to_GIS\',...
      strrep(char(geo_file(end-33:end-22)),'-','_')))));
writetable(Final_Data,char(strcat(...
        strcat('D:\GESTOR-INFO\03_FEATS\Data_to_GIS\',...
      strrep(char(geo_file(end-33:end-22)),'-','_'),'\','data2GIS_',...
      strrep(char(feats_file(end-8:end-4)),':','_')),'.csv')),'Delimiter',',');
