clc; clear all; close all
%% Cargar el dataframe a suavizar.
% Training
[f_name, f_path] = uigetfile('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\07_DATA_ADJ\*.csv',...
                       'Selecciona la Data para MODIFICAR');
filePath_labels = fullfile(f_path,f_name);
DATA = readtable(filePath_labels); %datos
varNames = DATA.Properties.VariableNames; %nombres de las columnas

FIRST_COLS = DATA(:,1:8);   %primeras columnas
A_level= DATA(:,40);        %Nivel total micro 1    
B_level= DATA(:,72);        %Nivel total micro 2
F_ch1 = table2array(DATA(:,9:39));  %Bandas micro 1
F_ch2 = table2array(DATA(:,41:71)); % BAndas micro 2
Class = DATA(:,73); %Target.

F_ch1_s = zeros(size(F_ch1));
for r = 1:length(F_ch1)
F_ch1_s(r,:) = movmean(F_ch1(r,:),3);
end
F_ch1_s = array2table(F_ch1_s,'VariableNames',varNames(9:39));

F_ch2_s = zeros(size(F_ch2));
for r = 1:length(F_ch2)
F_ch2_s(r,:) = movmean(F_ch2(r,:),3);
end
F_ch2_s = array2table(F_ch2_s,'VariableNames',varNames(41:71));

%Tabla suavizada
DATA_S = horzcat(DATA(:,1:8), F_ch1_s, DATA(:,40), F_ch2_s, DATA(:,72), DATA(:,73));

%% Dataset suavizado
writetable(DATA_S,char(strcat(...
        strcat(f_path,f_name(1:end-4),'_sua'),'.csv')),'Delimiter',',');
