function [T1,Y1,sam_ini,sam_fin] = Be_snal_parci(T_i,T_f,DT,DTG_i,T,Y,Fs)
%SEÑAL Parcial del TDMS a analizar a posterior
%T_i = tiempo inicial efectivo del TDMS
%T_f = tiempo final efectivo del TDMS
%DT = tiempo inicial del TDMS
%DTG_i = tiempo inicial del GPS
%T = vector de tiempos
%Y = vector/matriz de señal
%Fs = frec de sampleo
%Fi = frame inicial
%
% T1 = vector de tiempos efecticvo
% Y1 = vector/matriz de señal efectivo
elap_parcial = T_f - T_i;
DT_i = duration(timeofday(DT),'Format','hh:mm:ss.SSS');
    if DT_i-DTG_i>=0
     sam_ini = 1;
    else
    sam_ini = seconds(abs(DTG_i-DT_i)).*Fs; %original sin seconds
    end
    T1 = T(sam_ini:Fs*seconds(elap_parcial));
    Y1 = Y(:,sam_ini:Fs*seconds(elap_parcial));
    %% Rango de samples para feature estraction
    sam_fin = Fs*seconds(elap_parcial);
    
end

