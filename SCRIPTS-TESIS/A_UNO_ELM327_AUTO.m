clear; close all; clc;
disp('Running: A_UNO_ELM327_AUTO')
%% Lector ficheros CSV del ODB2 from "TORQUE-PRO"

%% Localizar la carpeta Principal TDMS&GPX
mother_dir = uigetdir('D:\Registros_de_rodadura','Carpeta Principal IN - TDMS&GPX');
dir_CSV = dir(strcat(mother_dir,'\**\GPS\*.csv'));
%% generar la carpeta donde se guardarán los archivos.
destino0 = strcat(mother_dir,'\','All_ELM327'); 
mkdir (destino0)
fichas = 1:length(dir_CSV);% todos los ficheros
%fichas = [9:15 16:23 24:28 29:32 43:46 47:56]; % fichas específicas
%fichas =[8:9];

for regis = 1: length(fichas)
   pathname_csv = dir_CSV(fichas(regis)).folder;                                    %directorio completo
   filename_csv = dir_CSV(fichas(regis)).name; identifier = filename_csv(1:end-5);  %nombre del fuchero
                                     
   GPS_data = fullfile(pathname_csv,filename_csv); % genera el directorio completo
   GPS_full_path = fullfile(pathname_csv,filename_csv); %genera el directorio completo
        %% PARTES 01 primera lectura del registro específico
        GPS_data = readtable(GPS_data,'Delimiter',',');
        %Lectura de Fecha y hora
        Date = GPS_data.GPSTime;
        Date_ch = char(Date);
            yyyy = string(Date_ch(:,end-3:end));    %AÑO
            mmm = string(Date_ch(:,5:5+2));         %MES
            dd = string(Date_ch(:,9:9+1));          %DIA
            ho = string(Date_ch(:,12:12+1));        %HORA
            mi = string(Date_ch(:,15:15+1));        %MINUTO
            se = string(Date_ch(:,18:18+1));        %SEGUNDO
            hour = string(Date_ch(:,12:12+7));      %HORA
           
            
            Date_N = strcat(string(yyyy),'-',string(mmm),'-',string(dd),...
                " ",string(ho),':',string(mi),':',string(se));
            Date_N = datetime(Date_N,'Format', 'yyyy-MM-dd HH:mm:ss');

        %Lectura de Tiempo
        Time = datetime(hour,'Format', 'HH:mm:ss');%hora en 24 horas.
         %% CORECCIÒN
            ad_h = hours(0); ad_m = minutes(0);ad_s = seconds(0); % revisar ajuste
            Time = Time+ad_h+ad_m+ad_s;
        %% GEOREFERENCIA    
        Latitude = GPS_data.Latitude;	%Latitude
        Longitude = GPS_data.Longitude;	%Longitude
        Altitude = GPS_data.Altitude;	%Altitude
        Speed_kmh_OBD = GPS_data.Speed_OBD__km_h_;	%Velocidad OBD
        Speed_kmh_GPS = GPS_data.Speed_GPS__km_h_;  %Velocidad GPS
        RPM = GPS_data.EngineRPM_rpm_;  % RPM engine
%% ESCRIBIR DATOS ELM237
T = table(Date_N,Time,Latitude,Longitude,Altitude,Speed_kmh_OBD,Speed_kmh_GPS,RPM);
writetable(T,[destino0,'\','E3_',filename_csv(1:end-4),'.csv']);
disp([num2str(fichas(regis)) ': ' identifier]);

end
%% Paso a la segunda parte
clearvars -except mother_dir destino0 fichas
run ('B_DOS_DAQELM_AUTO.m')