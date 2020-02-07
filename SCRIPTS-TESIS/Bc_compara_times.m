function [T_i,T_f,t_vec_GPS,DTG_i,DTG_f,DT_f,valores_T,clean_GPS_data] = Bc_compara_times(DT,DT_fin,GPS_data)
%Compara los tiempos de lectura entre el TDMS y el GPX corrrespondientes a
%una lectura (se recomeinda de máximo 15 minutos por 5 canales a 44100 Hz.)
%DT = date inicial de TDMS
%DT_fin = date final de TDMS
%GPS_data = datos íntegros del GPX
%
%T_i = hora inicial efectiva
%T_f = hora final efectiva
%t_vec_GPS = vector de horas del GPS
%DTG_i = hora inicial GPX
%DTG_f = hora final GPX
%DT_f = duration final de TDMS
%valores_T = índices de tiempos entre los cuales se leerá la señal de audio
%% Hora de inicio y fin del TDMS
DT_i = duration(timeofday(DT),'Format','hh:mm:ss.SSS'); 
DT_f = duration(timeofday(DT_fin),'Format','hh:mm:ss.SSS');

GPS_data = rmmissing(GPS_data); %Borra missing data
GPS_times = GPS_data.Time(:); %tiempos
for n = 1:numel(GPS_times)
    TTT = char(GPS_times(n));
    TT = TTT(1:8);
    t_vec_GPS(n)= duration(TT,'Format','hh:mm:ss.SSS');
    %disp (n);
end
%Limpiamos Indices y lecturas ducplicadas de la tabla del GPS_Data
    t_vec_GPS = t_vec_GPS';
    [t_vec_GPS,ia,~] = unique(t_vec_GPS,'rows','stable');
    clean_GPS_data = GPS_data(ia,:);
%% Hora de inicio y fin del GPX
    DTG_i = t_vec_GPS(1); %tiempo inicial del GPS
    DTG_f = t_vec_GPS(length(t_vec_GPS)); %tiempo final del GPS

%%
%Ajuste fino de tiempos
T_minimo = t_vec_GPS>=DT_i;
    T_minimo = T_minimo.*(1:numel(T_minimo))';
T_maximo = t_vec_GPS<=DT_f;
    T_maximo = T_maximo.*(1:numel(T_maximo))';
valores_T = sqrt(T_minimo.*T_maximo);
valores_T(valores_T==0) = [];
T_i = t_vec_GPS(min(valores_T));
T_f = t_vec_GPS(max(valores_T));

end

