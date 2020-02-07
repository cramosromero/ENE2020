function [date2samp,time2samp,coord_asig,speOBD2samp,speGPS2samp,RPM2samp] = Bf_signal_speed_GEO(date_vec_GPS,t_vec_GPS,GPS_Lat,GPS_Lon,GPS_Alt,Speed_OBD,Speed_GPS,RPM,Y1,T1,Fs,DT,CH1,CH2)
%Plotear la velocidad sobre la señal de audio y asocia su posición
%georeferenciada
% t_vec_GPS = vector de tiempos del GPS (efectivo)
% Y1 = señal de audio del TDMS (efectivo)
% T1 = tiempo efectivo
% Fs = frecuencia de sampleo
% speOBD2samp = velocidades en cada tiempo del track ODB (efectivo)
% speGPS2samp = velocidades en cada tiempo del track GPS (efectivo)
% GPS_Lon = Longitudes (efectivas)
% GPS_Lat = Latitudes (efectivas)
% DT = identificado datetime
% sp2samp = speed to sample vector
%coord_asig = coordenates to sample matrix
% Carlos Ramos 2019

nseg_for_time = zeros(size(t_vec_GPS)); %segundos transcurridos entre las lecturas del GPS
for ti = 1:length(t_vec_GPS)-1
    nseg_for_time(ti+1)= seconds(t_vec_GPS(ti+1)-t_vec_GPS(ti));
end
date2samp = NaT(length(Y1),1); date2samp.Format = 'dd-MM-yyyy HH:mm:ss';
time2samp = NaT(length(Y1),1) - NaT(1);
speOBD2samp = zeros(length(Y1),1);  %vector de velocidades OBD asignadas a cada sample de audio
speGPS2samp = zeros(length(Y1),1);  %vector de velocidades GPS asignadas a cada sample de audio
RPM2samp = zeros(length(Y1),1);     %vector de RPM engine asignadas a cada sample de audio
coord_asig =zeros (length(Y1),3);   %vector de coordenadas asignadas a cada sample de audio
%sp_acc_asig =zeros (length(Y1),2); %vector de velocidad y aceleración asignadas a cada sample de audio

sam_seg = nseg_for_time.*Fs; % samples por segmento
aux = cumsum(sam_seg);aux(:,2)=aux+1; % frecuencia acumulada mas salto
%% Asignación de velocidad, aceleración y coordenadas a los samples
% últiles.
for gps_eye = 1:length(Speed_OBD)-1 
    %date y time
    date2samp(aux(gps_eye,2):aux(gps_eye+1,1)) = datetime(date_vec_GPS(gps_eye+1), 'Format', 'dd-MM-yyyy HH:mm:ss');
    time2samp(aux(gps_eye,2):aux(gps_eye+1,1)) = duration(t_vec_GPS(gps_eye+1), 'Format', 'hh:mm:ss');
    
    %velocidad y RPM
    speOBD2samp(aux(gps_eye,2):aux(gps_eye+1,1)) = Speed_OBD(gps_eye+1);
    speGPS2samp(aux(gps_eye,2):aux(gps_eye+1,1)) = Speed_GPS(gps_eye+1);
    RPM2samp(aux(gps_eye,2):aux(gps_eye+1,1)) = RPM(gps_eye+1);
    % coordenadas
    coord_asig(aux(gps_eye,2):aux(gps_eye+1,1),1) = GPS_Lat(gps_eye+1);
    coord_asig(aux(gps_eye,2):aux(gps_eye+1,1),2) = GPS_Lon(gps_eye+1);
    coord_asig(aux(gps_eye,2):aux(gps_eye+1,1),3) = GPS_Alt(gps_eye+1);
end
%% Gráficas
%{
fig = figure(); %figura con dos ejes
left_color = [0 0 0]; right_color = [1 0 0];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

plot_ruta_2d = subplot(2,1,1); %plot 2d de la ruta
plot(coord_asig(:,2),coord_asig(:,1),'*','MarkerSize',8,'Color',[.4 0 0.4]);
    grid on
    title({'Effective Path','by Time'})
    xlabel('Longitude');ylabel('Latitude');zlabel('Time')
    
plt_sig_spe_time = subplot(2,1,2); %plot de señal y velocidad vs tiempo
    yyaxis left
    plot(T1,Y1(CH1,:),'k'); hold on %canal 4
    plot(T1,Y1(CH2,:),'g');         %canal 5
    title({'Georef-Signal',char(DT)})
        xlabel('Time[s]'); ylabel('Amplitude[Pa]')
        axis tight; grid on
    yyaxis right
    plot(T1,speOBD2samp,'r'); ylabel('Speed [km/h]')
    grid on; grid minor;

fig_spe_acc = figure(); %figura velocidad y aceleración dos ejes
left_color = [1 0 0]; right_color = [0 0 1];
set(fig_spe_acc,'defaultAxesColorOrder',[left_color; right_color]);
title({'Speed and Acceleration',char(DT)})
    yyaxis left
    plot(T1,speOBD2samp,'r'); ylabel('Speed [km/h]')
        xlabel('Time[s]');
        axis tight; grid on
    yyaxis right
    plot(T1,speGPS2samp,'b'); ylabel('Acceleration [km/s^{2}]')
    grid on
%}
end

