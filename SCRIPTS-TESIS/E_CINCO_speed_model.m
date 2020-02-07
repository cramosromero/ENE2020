%% Corrije las características en frecuecncia de acuerdo a su relaciòn con la velocidad.
% GENERA UN MODELO para el ajuste
% F_n = A+Blog10(SpeedOBD)
clc;clear;close all;
%% Cargar la base de datos.
[f_name, f_path] = uigetfile('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\06_DATA_ML\*.csv',...
                       'Selecciona la Data para extrael el MODELO');
filePath_labels = fullfile(f_path,f_name);
DATA = readtable(filePath_labels);

%% Respuesta,  Fatores Multivariandes y Fatores de filtro
OBD  = DATA.Speed_OBD;  % velocidades OBD
RPM  = DATA.RPM;        % RPM

Class = DATA.Class;     % zonas desconocidas a priori
%% FILTROS
idx = (1:length(OBD))';
TR = (OBD>=25 & Class~=-99); % filtro por velocidad y zona conocida
idx = idx.* TR; idx(idx==0)=[];
DATA_CL = DATA(idx,:);
DATA_AJ = DATA(idx,:);
%% Ajuste de regresiòn a características filtradas a relacionar
% FEATURES =[9:40 41:72]; %9:40 channel 0 , 41:72 channel 1. % 1/3 2 canales concatenados horizontalmente
 FEATURES = (9:22); %MFCC 2 canales concatenados vertivcalmente
pVal = zeros(1,length(FEATURES));
R2 = zeros(1,length(FEATURES));
B = zeros(1,length(FEATURES));
A = zeros(1,length(FEATURES));
Names = DATA.Properties.VariableNames;

f=1;
for feature = FEATURES    
    col_name = string(Names(feature)); % nombre de la columna
    
    Y = table2array(DATA(:,feature)); % Características Y "Nivel total"
    Y = Y(idx);
    
    %Componentes multivariantes
    X = [OBD(idx)];      %log10(velocidad_OBD)  añadir        
    %% Modelo lineal
     Reg1 = fitlm(log10(X),Y);          %Modelo de Regresión Lineal
     Coef = Reg1.Coefficients;   %Coeficientes de la regresión
     A(f) = Reg1.Coefficients.Estimate(1); % Intercepto
     B(f) = Reg1.Coefficients.Estimate(2); % Pendientes aguardarse
   R2_ord = Reg1.Rsquared.Ordinary; %R^2 Ordinario
   R2_adj = Reg1.Rsquared.Adjusted; %R^2 Ajustado
  pVal(f) = Coef.pValue(2);       %P Valor del intercepto
    R2(f) = R2_adj*100;             %Coeficiente correlación
    %Mat_comp = [table2array(Coef) [R2_ord ;R2_adj ]]; %coefs en una sola M
    %% Ajuste si P>0.001
    Y_reg = A(f) + B(f).*(log10(X)); %modelo de regresión por cada banda
    
    if pVal(f) < 0.005 && R2(f) > 30
        Y_mod = Y - B(f).*(log10(X)); %corrección por la velocidad en cada banda
        DATA_AJ{:,feature} = Y_mod;
        correc = " ajustado";
    else
        Y_mod = Y;
        DATA_AJ{:,feature} = Y;
        correc = " no ajustado";
    end
    disp(string(feature) + ': '+ col_name + correc + ' pVal=' + pVal(f) + ' R^2=' + R2(f)+'%');
    %{
    figure();
    subplot (1,2,1)
    plot(log10(X),Y,'+k','DisplayName','Measured'); hold on;
    
    plot(log10(X),Y_mod,'ob','DisplayName',['Adjusted by (' num2str(B(f)),')']);
    xlabel('log_{10}speed OBD [km/h]'); yl1 = ylabel('Ampli '+ col_name+'[dB]'); set(yl1, 'Interpreter', 'none')
    ti1 = title('Reg. Feat: ' + col_name); legend('Location','northwest')
    set(ti1, 'Interpreter', 'none')
    
    plot(log10(X),Y_reg,'DisplayName',['y = (' num2str(A(f)) ') + (' num2str(B(f)) ')log_{10}OBD']);
    hold on;
    
    
    subplot (1,2,2)
    plot(Y,'k','DisplayName','Measured'); hold on;plot(Y_mod,'b--','DisplayName','Adjusted')
    xlabel('time [s]')
    ti2 = title(['Amp. Corregida';'Coef B= '+string(B(f))]);
    legend('Location','northwest')
    %}
f=f+1;
end

%Plot de R^2 y pValue
%{
vecs = (1:length(FEATURES)); %vectores de características
fig = figure; c1 = [.2  0.6 0]; c2 = [0 0 1];
set(fig,'defaultAxesColorOrder',[c1; c2]);
yyaxis left
      plot(vecs,R2,'o','Color',c1,'DisplayName','R^{2}[%]');
      ylabel('R^{2}[%]');
      hold on
yyaxis right
      plot(vecs,pVal,'+','Color',c2,'DisplayName','p-value');
      hold on
      ylim([0 0.005])
      xlim([1 length(FEATURES)])
      ylabel('p-Value');
xlabel('Features');
xlim([1-1 length(FEATURES)+1])
legend('R^{2}[%]','p-value','Location','northwest')
title('Regresion Coefficients')
%}
%% Guardar el dataset trasnformado 
ID = datetime('now', 'Format','dd-MM-yyyy HH:mm');
ID = string(ID); ID = strrep(ID,' ','-');ID = strrep(ID,':','-');
destino7 = char('D:\Registros_de_rodadura\ENE_2020\Ene_2020_out\07_DATA_ADJ');
mkdir(destino7)
% Dataset ajustado
writetable(DATA_AJ,char(strcat(...
        strcat(destino7,'\','Adjus_',char(ID)),'.csv')),'Delimiter',',');
    
% Coeficiente de ajustados
B = table(B'); B.Properties.VariableNames = {'B'};
pVal = table(pVal'); pVal.Properties.VariableNames = {'pVal'};
R2 = table(R2'); R2.Properties.VariableNames = {'R2'};

B = horzcat(B,pVal,R2);

writetable(B,char(strcat(...
        strcat(destino7,'\','B_',char(ID)),'.csv')),'Delimiter',',');







