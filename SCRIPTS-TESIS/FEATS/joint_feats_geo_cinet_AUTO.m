%% LECTURA del ARCHIVO DE FEATURES
FEATS_data = readtable(filePath_feats); %loeo la tabla
FEATS_data.Var32=[]; %elimio una columna nula

names_feats = table2array(FEATS_data(1,:)); %obtengo los nombres de las características
            names_feats = string(names_feats);
            names_feats(end) = 'level';
disp(['feats' FEATS_data 'rows' height(FEATS_data)] ); %muestra el ID del TDMS seleccionado            
FEATS_data(1,:)=[]; %borro una fila;
for b=1:length(names_feats)
    names_feats(b)=strrep(names_feats(b),'.','_');
   Name(b) = strcat('B_',names_feats(b));
end
names_feats = cellstr(Name);
FEATS_data.Properties.VariableNames= names_feats;
%% LECTURA del ARCHIVO DE GEOREFERENCIAS
GEO_data = readtable(filePath_geocine);
GEO_data(1,:)=[]; %borro una fila;
disp(['geocine' GEO_data 'rows' height(GEO_data)] ); %muestra el ID del TDMS seleccionado

ID = (1:height(GEO_data)).';
ID = table(ID,'VariableNames',{'ID'});
%% Tabla final
Final_Data = [ID FEATS_data GEO_data ];
%% Guardo el CSV generado
mkdir(char(strcat(...
        strcat('D:\GESTOR-INFO\03_FEATS\Data_to_GIS\',...
      strrep(char(filename_feats(7:end-10)),'-','_')))));
writetable(Final_Data,char(strcat(...
        strcat('D:\GESTOR-INFO\03_FEATS\Data_to_GIS\',...
      strrep(char(filename_feats(7:end-10)),'-','_'),'\','data2GIS_',...
      strrep(char(filename_feats(end-8:end-4)),':','_')),'.csv')),'Delimiter',',');
