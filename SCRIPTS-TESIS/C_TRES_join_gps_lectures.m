%% Unirá todas las lecturas de los GPS en un solo csv, irán a etiquetarse
%% LECTURA del ARCHIVOs GPS desde OBD2
fols_outs = char(strcat(mother_dir(1:end-3),'_out')); %
dir_gps_reads = dir(char(strcat(fols_outs,'\01_GPXLabel\GPS_finales\**\*.csv')));

fichas = 1:length(dir_gps_reads);% todos los ficheros
%fichas = [9:15 16:23 24:28 29:32 43:46 47:56];

%tabla inicial vacía
 gps_folder = dir_gps_reads(fichas(1)).folder; %carpeta
 gps_name = dir_gps_reads(fichas(1)).name; %archivo
 TABLE_T = readtable([gps_folder '\' gps_name],'Delimiter',',');
% cols = TABLE_1.Properties.VariableNames; %nombre de variables
% tipo = varfun(@class,TABLE_1,'OutputFormat','cell'); %tipo de variables
% table_z = table('Size', [1 length(cols)],...
%             'VariableTypes', tipo,...
%             'VariableNames',cols);
%FEATS_data(1,:)=[]; %borro una fila;
for regis = 2:length(fichas)
    gps_folder = dir_gps_reads(fichas(regis)).folder; %carpeta
    gps_name = dir_gps_reads(fichas(regis)).name; %archivo
    TABLE = readtable([gps_folder '\' gps_name],'Delimiter',',');
    TABLE_T = [TABLE_T; TABLE]; %tabla total
end
destino4 = char(strcat(mother_dir(1:end-3),'_out','\05_Databases'));
mkdir(destino4)

ID = datetime('now', 'Format','dd-MM-yyyy HH:mm');
ID = string(ID); ID = strrep(ID,' ','-');ID = strrep(ID,':','-');

writetable(TABLE_T,char(strcat(destino4,'\','ALL_GPS_',char(ID),'.csv')),'Delimiter',',');
