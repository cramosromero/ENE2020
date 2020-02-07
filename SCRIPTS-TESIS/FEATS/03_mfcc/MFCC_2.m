%% Extractor de MFCC feats por zonas etiquetadas previas 
% La extracción con Auditory Toolbox
% i2a2 - Ramos_2020 - Enero2020
clear; close all; clc

%hacerlo una sola vez por día
%% ingreso la carpeta que contiene los csvs de referencias etiquetadas.
reffs_dir = uigetdir('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out','Carpeta de referencias');
dir_CSV = dir(strcat(reffs_dir,'\*.csv'));
T = readtable(strcat(dir_CSV.folder,'\',dir_CSV.name));
T_lims = table2array(T(:,1:2)); %referencias inicial y final de las señalaes

win_t = 1000; %ms Ventanado
%%
%tdm_externo = 'D:\Registros_de_rodadura';
%addpath(genpath(tdm_externo));
%addpath(genpath('D:\GESTOR-INFO'));
%% LECTURA del ARCHIVO DE SEÑAL DE RUIDO
tdms_tools = strcat('D:\Registros_de_rodadura\SCRIPTS-TESIS','\','leerTDMS');
addpath(genpath(tdms_tools));
my_tdms_struct = TDMS_getStruct(filePath_tdms);

%% EXTRACCIÓN de información desde la estructura multicanal del TDMS
%prompt = 'El TDMS a leer será etiquetado 1/0[1]: ';
%label_pross = input(prompt);
label_pross = 0;

[Y,T,Fs,DT] = Bb_acces_to_TDMS(my_tdms_struct);
    Fs = double(Fs);
    [~,sam] = size(Y);%tamaño de la matriz de datos
    DT_fin = DT + seconds(sam/Fs);    
    disp(['TDMS corresponds to ' char(DT)] ); %muestra el ID del TDMS seleccionado 




%% Leo el TDMS relacionado.
    % lectura del archivo TDMS
disp('TDMS ASOCIADO')
win_len = 100; % largo de ventana (ms).
[~,t,Y,Fs] = TDMS_signal_separator_2(folder_dia,win_len); 
%% Extención de cada ventana en samples y clase y etiqueta de clase
win_len_sam = double((Fs*win_len/1000)); % largo de ventana(samples).

tex_clase = {'New';'Low_sev'; 'M&H_sev'; 'Pothole'}; %clase en string
num_clase = [1 , 2 , 3 , 4]; %clase ordinal

%% Lectura de zonas en T_lim para dividirlas según win_len_sam y EXTRACCIÒN
MX_mfcc = find(1<0); %arreglo vacío donde se guardarán las características y etiquetas
for i = 1:length(T_labels) %va contando las zonas etiquetadas
    segement = Y(T_lims(i,1):T_lims(i,2)); %segmentos según etiquetado previo
    [ceps,freqresp,fb,fbrecon,freqrecon] = mfcc_tool(segement,double(Fs),10,win_len_sam); %AudToolBox
    lab = T_labels(i); %label del segemento
    index = find(strcmp(tex_clase, lab)); %encuentra número de etiquera respectivo
    %construyo la matriz[feats;etiqueta]
    [a,b] = size(ceps);
    etiqueta = ones(b,1)*index;
    MAT = [ceps.' etiqueta];
    MX_mfcc = cat(1,MX_mfcc,MAT);
end

%% Guardar la tabla del buffer generado con su respectiva etiqueta
DataFrame = table(MX_mfcc);
%DATA_WPT_full = table(DATA_WPT_full);
writetable(DataFrame,strcat(folder_dia,'/',file(1:2),'_',file(4:7),'_mfcc','.csv'),'Delimiter',',');
% limpio 
disp({'XXXXXXXXXXXXX';'XXX LISTO XXX';'XXXXXXXXXXXXX'})
