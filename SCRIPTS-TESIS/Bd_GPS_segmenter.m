function [date_vec_GPS,t_vec_GPS,GPS_Lat,GPS_Lon,GPS_Alt,Speed_OBD,Speed_GPS,RPM] = Bd_GPS_segmenter(clean_GPS_data,valores_T,DT)
%% Crea un vector tiempos desde la lectura del GPS
%DT_i: tiempo inicial del segmento de interés
%DT_f: tiempo final del segmento de interés
%GPS_data: Tabla de la lectura del GPS.csv
%DT: referenica datetime

%t_vec_GPS: duration vector de los puntos de la sección del track
%GPS_Lat: Latitudes de los puntos de la sección del track
%GPS_Lon: Longitures de los puntos de la sección del track
%GPS_Spe: Velocidades de los puntos de la sección del track
%T_i: duration tiempo inicial del segmento 
%T_f: duration tiempo final del segmento
%valores_T = índices de tiempos entre los cuales se leerá la señal de audio
%y gpx

%% extracion of time, speed, longitude and latitude of the time parcial
   date_vec_GPS = clean_GPS_data.Date_N(valores_T);       %Fechas
      t_vec_GPS = clean_GPS_data.Time(valores_T);         %Horas
        GPS_Lat = clean_GPS_data.Latitude(valores_T);     %Latitud
        GPS_Lon = clean_GPS_data.Longitude(valores_T);    %Longitud
        GPS_Alt = clean_GPS_data.Altitude(valores_T);     %Longitud
      Speed_OBD = clean_GPS_data.Speed_kmh_OBD(valores_T);%Velocidad kmh_OBD
      Speed_GPS = clean_GPS_data.Speed_kmh_GPS(valores_T);%Velocidad kmh_GPS
            RPM = clean_GPS_data.RPM(valores_T);%RPM Engine
%% Plot del tramo
%{
%datos del mapa base
name = 'openstreetmap';
url = 'a.tile.openstreetmap.org';
copyright = char(uint8(169));
attribution = "i2a2" + copyright + "OpenStreetMap contributors";
displayName = 'Open Street Map';
addCustomBasemap(name,url,'Attribution',attribution,'DisplayName',displayName)

figure()
subplot(2,1,1)
geoplot(GPS_Lat,GPS_Lon,'LineWidth',2,'Color',[.4 0 0.4]);
    title({'Effective Path',char(DT)})
geobasemap(name(:));
set(gca,'LooseInset',get(gca,'TightInset'))

subplot(2,1,2)%órden de la circulación
scatter3(GPS_Lon,GPS_Lat,t_vec_GPS, 5, Speed_OBD, 'filled')
    grid on
    title({'Effective Path','by Time'})
    xlabel('Longitude');ylabel('Latitude');zlabel('Time')
%}
 end

