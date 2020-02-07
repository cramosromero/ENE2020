%% GESTOR PRINCIAPL DE DATOS TDMS-GPX
%[a, MSGID] = lastwarn(); warning('off', MSGID);warning('off', MSGID);
% Carga los archivos TDMS y las georeferencias del OBD2,
% El script mostrará la señal de ruido que ha sdo georeferenciada y mostrará
% el mapa de la ruta seguida, con el órden de registro y la señal en el tiempo.
% adicionalmente se mostrará la evolución de velocidad y aceleración
% asociada a la pista del TDMS
% Ramos-Romero_2019

%% INICIO.
% win_t -> viene desde A_UNO_ELM327_AUTO.m
win_t = 1000; %ms Ventanado
%%
%tdm_externo = 'D:\Registros_de_rodadura';
%addpath(genpath(tdm_externo));
%addpath(genpath('D:\GESTOR-INFO'));
%% LECTURA del ARCHIVO DE SEÑAL DE RUIDO
tdms_tools = strcat('D:\Registros_de_rodadura\SCRIPTS-TESIS','\','leerTDMS');
addpath(genpath(tdms_tools));
my_tdms_struct = TDMS_getStruct(filePath_tdms);
% EXTRACCIÓN de información desde la estructura multicanal del TDMS
%prompt = 'El TDMS a leer será etiquetado 1/0[1]: ';
%label_pross = input(prompt);
label_pross = 0;

[Y,T,Fs,DT] = Bb_acces_to_TDMS(my_tdms_struct);
    Fs = double(Fs);
    [~,sam] = size(Y);%tamaño de la matriz de datos
    DT_fin = DT + seconds(sam/Fs);    
    disp(['TDMS corresponds to ' char(DT)] ); %muestra el ID del TDMS seleccionado     
%% LECTURA del ARCHIVO DE GPX: SPEE & ACC
GPS_data = readtable(filePath_elm,'Delimiter',',');
% corrige tipo de datos
[GPS_data] = Bab_corrige_tipo(GPS_data);
disp(['GPS corresponds to ' filename_elm] ); %muestra el ID del TDMS seleccionado
% SELECTOR DE DATOS efectivos TDMS vs. GPX
    [T_i,T_f,~,DTG_i,DTG_f,DT_f,valores_T,clean_GPS_data] = Bc_compara_times(DT,DT_fin,GPS_data);
    [date_vec_GPS,t_vec_GPS,GPS_Lat,GPS_Lon,GPS_Alt,Speed_OBD,Speed_GPS,RPM] = Bd_GPS_segmenter(clean_GPS_data,valores_T,DT);
%% Guardo las tablas de CINEMÁTICA generado por OBD2
Table2graph = table(date_vec_GPS,t_vec_GPS,GPS_Lat,GPS_Lon,GPS_Alt,Speed_OBD,Speed_GPS,RPM);

destino1 = char(strcat(mother_dir(1:end-3),'_out','\01_GPXLabel\GPS_finales\',filePath_elm(end-17:end-10)));
mkdir(destino1);
writetable(Table2graph,char(strcat(destino1,'\GPS2graph_',filePath_elm(end-17:end-4),'.csv')),'Delimiter',',');
    
       
%% EXTRACCIÓN de información efectiva desde el TDMS a procesarse después.
[T1,Y1,sam_ini,sam_fin] = Be_snal_parci(T_i,T_f,DT,DTG_i,T,Y,Fs);
[chann,sam1] = size(Y1);
%Plot de señal referencial
%{
figure()
plot(T1,Y1(1,:),'k');hold on; plot(T1,Y1(2,:),'r')
title({'Señal útil Georeferenciada',char(DT)})
    xlabel('TIme[s]'); ylabel('Amplitude[Pa]')
    axis tight; grid on
%}
%% Observación Correlación speed - level
%{
Y2 = envelope(Y1(1,:),40,'rms');
Y2 = downsample(Y2,44100-1);
SP = Table2graph.Speed_OBD;
[C2,lag2] = xcorr(Y2,SP);
[~,I] = max(abs(C2)); SampleDiff = lag2(I);
timeDiff = SampleDiff; disp(timeDiff);
figure(); plot(SP./max(SP));hold on;plot(Y2./max(Y2));
%}
%% Plotear la velocidad sobre la señal de audio para verificar las zonas de posible etiquetado.
CH1=1;CH2=2; %canales a plotear
[date2samp,time2samp,coord_asig,speOBD2samp,speGPS2samp,RPM2samp] = Bf_signal_speed_GEO(date_vec_GPS,t_vec_GPS,...
                                                                                        GPS_Lat,GPS_Lon,GPS_Alt,...
                                                                                        Speed_OBD,Speed_GPS,RPM,...
                                                                                        Y1,T1,Fs,DT,CH1,CH2);
%% Revisar zonas de interès: GEO-Speed.
%run ('D:\GESTOR-INFO\01_Gestor_principal\subplots_mejor.m')
%% Ejecutar el Ventaeo para el proceso de Feature-extraction


if label_pross == 1
    run ('D:\GESTOR-INFO\02_ROI_Etiquetador_2.0\A_PRIN_LECTOR.m')
    return
else
    Inicio = sam_ini;
    Final = sam_fin;
    T_comodin = table(Inicio,Final);
    name_t = char(DT);
    destino2 = strcat(mother_dir(1:end-3),'_out','\','02_total_reff');
    mkdir(destino2);
    writetable(T_comodin,char(strcat(destino2,'\',filePath_elm(end-17:end-4),'.csv')),'Delimiter',',');
end
%% Samples a plotearse e ingresarse en los clasificadores

win_t_s = win_t/1000; salto=Fs*win_t_s;
date_asig2Sam = NaT(floor((Final-Inicio)/salto),1); date_asig2Sam.Format = 'dd-MM-yyyy HH:mm:ss';
time_asig2Sam = NaT(floor((Final-Inicio)/salto),1)- NaT(1);
coord_asig2Sam = zeros(floor((Final-Inicio)/salto),3);
cinet_asig2Sam = zeros(floor((Final-Inicio)/salto),3);
ss = salto;
for r=1:floor(sam1/(salto)) 
    %date, time, coordenadas, velo OBD, velo GPS asignadas a los samples por ventana temporal
    date_asig2Sam(r,1) = date2samp(ss,1);
    time_asig2Sam(r,1) = time2samp(ss,1);
    coord_asig2Sam(r,1)= coord_asig(ss,1);
    coord_asig2Sam(r,2)= coord_asig(ss,2);
    coord_asig2Sam(r,3)= coord_asig(ss,3);
    cinet_asig2Sam(r,1)= speOBD2samp(ss,1);
    cinet_asig2Sam(r,2)= speGPS2samp(ss,1);
    cinet_asig2Sam(r,3)= RPM2samp(ss,1);
    ss = ss+salto;
end
%{
figure()
plot(coord_asig2Sam(:,2),coord_asig2Sam(:,1),'o','MarkerSize',8,'Color',[.4 0 0.4]);
    grid on
    title({'Win-time Path','by Time'})
    xlabel('Longitude');ylabel('Latitude');zlabel('Time')
%}
% TABLAS COMPLETAS CINEMÄTICA POR SAMPLE de T_WIN
date_vec_GPS = date_asig2Sam(:,1);
t_vec_GPS = time_asig2Sam (:,1);
GPS_Lat = coord_asig2Sam(:,1);
GPS_Lon = coord_asig2Sam(:,2);
GPS_Alt = coord_asig2Sam(:,3);
Speed_OBD = cinet_asig2Sam(:,1);
Speed_GPS = cinet_asig2Sam(:,2);
RPM = cinet_asig2Sam(:,3);

Table2graph = table(date_vec_GPS,t_vec_GPS,GPS_Lat,GPS_Lon,GPS_Alt,Speed_OBD,Speed_GPS,RPM);

destino3 = strcat(mother_dir(1:end-3),'_out','\','03_Geo_Win');
mkdir(destino3);

writetable(Table2graph,char(strcat(destino3,'\gw_',filename_elm(end-17:end-4),'.csv')),'Delimiter',',');

%% MFCC y TIME features extraction
addpath('D:\Registros_de_rodadura\SCRIPTS-TESIS\FEATS\02_otros\ZCR') %path ZCR
addpath('D:\Registros_de_rodadura\SCRIPTS-TESIS\FEATS\03_mfcc') %path MFCC
addpath('D:\Registros_de_rodadura\SCRIPTS-TESIS\FEATS\02_otros\FFT') %path FFT
run('D:\Registros_de_rodadura\SCRIPTS-TESIS\FEATS\03_mfcc\MFCC_y_time_feats.m')

