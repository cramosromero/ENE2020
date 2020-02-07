%[a, MSGID] = lastwarn(); warning('off', MSGID);warning('off', MSGID);
%% Proceso automático de lectura TDMS y GPS
%%{
%% TDMSs
disp('Running: B_DOS_DAQELM_AUTO')
dir_tdms = dir(strcat(mother_dir,'\**\DAQ\**\*_Pressure.tdms'));

%% GPSs ELM237
dir_elm = dir(strcat(destino0,'\*.csv'));
%fichas = 1:length(dir_elm);% todos los ficheros
%fichas = [9:15 16:23 24:28 29:32 43:46 47:56];
for regis = 1: length(fichas)
   disp(fichas(regis))
   pathname_tdms = dir_tdms(fichas(regis)).folder;
   filename_tdms = dir_tdms(fichas(regis)).name;
   filePath_tdms = fullfile(pathname_tdms,filename_tdms);
   
   pathname_elm = dir_elm(fichas(regis)).folder;
   filename_elm = dir_elm(fichas(regis)).name;
   filePath_elm = fullfile(pathname_elm,filename_elm);
   run('Ba_Gestor_Principal_AUTOMATIC.m')
disp('---o---')
end
%}
%{
%% Proceso automático de concatenación de datos GPS y FEATS
% features from labview

dir_feats = dir('D:\GESTOR-INFO\03_FEATS\01_tercio\csv_OUT\*.csv');

%% geográficos y cinemáticos
dir_geocine = dir('D:\GESTOR-INFO\03_FEATS\ventana_georeferenciada\**\*.csv');

for regis = 1: length(dir_feats)
    disp(regis)
   pathname_feats = dir_feats(regis).folder;
   filename_feats = dir_feats(regis).name;
   filePath_feats = fullfile(pathname_feats,filename_feats);
   
   pathname_geocine = dir_geocine(regis).folder;
   filename_geocine = dir_geocine(regis).name;
   filePath_geocine = fullfile(pathname_geocine,filename_geocine);
   
   run('D:\GESTOR-INFO\03_FEATS\joint_feats_geo_cinet_AUTO.m')
disp('---o---')
end
%}
clearvars -except mother_dir fichas
disp('%%%%%%%%%%%%%%%%% SIGUIENTE-FEATURE EXTRACTION EN LABVIEW%%%%%%%%%%%%%')