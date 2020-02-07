%% Modifica las características originales en frecuecncia de acuerdo a los
% modelos lineales previos para minimizar la dependencia del logaritmo de la valocidad.
% F_n = A+Blog10(SpeedOBD)
clc;clear;close all;
%% Cargar la Base de datos a pmodificar.
[f_name, f_path] = uigetfile('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\06_DATA_ML\*.csv',...
                       'Selecciona la Data para MODIFICAR');
filePath_labels = fullfile(f_path,f_name);
DATA = readtable(filePath_labels);

%% Cargar los coeficientes del modelo por característica. B
[b_name, b_path] = uigetfile('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\07_DATA_ADJ\*.csv',...
                       'Selecciona el Archibo de coeff B');
filePath_labels = fullfile(b_path,b_name);
B = readtable(filePath_labels);

%% FILTROS para tener valores válidad por velocidad >20
OBD  = DATA.Speed_OBD;  % velocidades OBD
Class = DATA.Class;     % zonas desconocidas a priori
idx = (1:length(OBD))';
TR = (OBD>=25);% & Class~=-99);
idx = idx.* TR; idx(idx==0)=[];
DATA = DATA(idx,:);

%% Prelocación del nuevo data set
DATA_AJ = DATA;
%% Modificaciòn
Names = DATA.Properties.VariableNames;
%FEATURES =[9:40 41:72];         %9:40 channel 0 , 41:72 channel 1. % 1/3 2 canales concatenados horizontalmente
 FEATURES = (9:22); %MFCC 2 canales concatenados vertivcalmente
% Componentes multivariantes que permiten la correciòn del DATA
X = table2array(DATA(:,6));     %log10(velocidad_OBD)  añadir

b=1; %óden en el valor de B, pValue y R2
for feature = FEATURES    
    col_name = string(Names(feature)); % nombre de la columna
    Y = table2array(DATA(:,feature)); % Características Y "Nivel total"
                
    if B.pVal(b) < 0.005 && B.R2(b) > 30
        Y_mod = Y - B.B(b).*(log10(X)); %corrección por la velocidad en cada banda
        DATA_AJ{:,feature} = Y_mod;
        correc = " ajustado";
    else
        Y_mod = Y;
        DATA_AJ{:,feature} = Y;
        correc = " no ajustado";
    end
    disp(string(feature) + ': '+ col_name + correc + ' pVal=' + B.pVal(b) + ' R^2=' + B.R2(b)+'%');
    %%{
    figure();
    subplot (1,2,1)
    plot(log10(X),Y,'+k','DisplayName','Measured'); hold on;
    
    plot(log10(X),Y_mod,'ob','DisplayName',['Adjusted by (' num2str(B.B(b)),')']);
    xlabel('log_{10}speed OBD [km/h]'); yl1 = ylabel('Ampli '+ col_name+'[dB]'); set(yl1, 'Interpreter', 'none')
    ti1 = title('Reg. Feat: ' + col_name); legend('Location','northwest')
    set(ti1, 'Interpreter', 'none')
 
    subplot (1,2,2)
    plot(Y,'k','DisplayName','Measured'); hold on;plot(Y_mod,'b--','DisplayName','Adjusted')
    xlabel('time [s]')
    ti2 = title(['Amp. Corregida';'Coef B= '+string(B.B(b))]);
    legend('Location','northwest')
    %}
b=b+1;
end

%% Dataset ajustado
writetable(DATA_AJ,char(strcat(...
        strcat(b_path,f_name(1:end-4),'_mod'),'.csv')),'Delimiter',',');