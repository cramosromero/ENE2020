% Reshape de tablas MFCC
% Separar sensores
clc;clear;close all;
%% Cargar la base de datos.
[f_name, f_path] = uigetfile('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\06_DATA_ML\*.csv',...
                       'Selecciona la Data para separa los sensores');
filePath_labels = fullfile(f_path,f_name);
DATA = readtable(filePath_labels);
colnames = {'C1' 'C2' 'C3' 'C4' 'C5' 'C6' 'C7' 'C8' 'C9' 'C10' 'C11' 'C12' 'C13' 'C14'};

S1 =  array2table(table2array(DATA(:,9:22)),'VariableNames',colnames);
S2 =  array2table(table2array(DATA(:,23:36)),'VariableNames',colnames);

N_ARR = [DATA(:,1:8) S1  DATA(:,37);...
         DATA(:,1:8) S2  DATA(:,37)];
     
N_ARR = N_ARR(N_ARR.Class ~= -99,:);

scatter(N_ARR.Speed_OBD,N_ARR.C1,[],N_ARR.Class,'filled')

%% DATA SET PARA ML
destino = char('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\08_Split_sensors');
mkdir(destino)

writetable(N_ARR,char(strcat(...
        strcat(destino,'\','split_','',f_name(1:end-4)),'.csv')),'Delimiter',',');
disp({'XXXXXXXXXXXXX';'XXX LISTO XXX';'XXXXXXXXXXXXX'})

