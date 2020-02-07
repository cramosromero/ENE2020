function [Y,T,Fs,DT] = Bb_acces_to_TDMS(my_tdms_struct)
%% ACCESO AL TDMS, para obtener:
% Y = vector de datos - multicanal.
% T = vector de tiempos.
% Fs = frecuencia de sampleo.
% DT = fecha y hora.
%Ramos-Romero2019
%% DT
%my_tdms_struct = TDMS_getStruct(filename); %ingreso al struct
       names_0 = fieldnames(my_tdms_struct); % nombres del struct
%% acceso al dato inicial de DATE-time
         props = getfield(my_tdms_struct,'Props'); %lectura del primer elemento
            DT = getfield( props,'Title');
            DT = datetime(DT,'InputFormat','dd/MM/yyyy HH:mm:ss');
%% Frecuencia de sampleo
          Fs_0 = getfield(my_tdms_struct,names_0{2});
        Fs_0_0 = fieldnames(Fs_0);
          Fs_1 = getfield(Fs_0,Fs_0_0{3});
          Fs_2 = getfield(Fs_1,'Props');
            Fs = getfield(Fs_2,'wf_samples');
            
%% Amplitudes
channels = length(fieldnames(Fs_0))-2;

for chann = 1:channels
    Y_data = getfield(Fs_0,Fs_0_0{chann+2});
    Y(chann,:) = getfield(Y_data,'data');
end
%% Tiempos
T = linspace(0,length(Y(1,:)),length(Y(1,:)))./double(Fs);
end

