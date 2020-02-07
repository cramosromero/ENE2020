function [Tabla_out] = Bab_corrige_tipo(Tabla_in)
%corrige el tipo de dato de cada columna por si entran como tipo cell
%   Detailed explanation goes here
columnas = string(Tabla_in.Properties.VariableNames);
tf = iscell(Tabla_in.(columnas(2)));
if tf == 1
    [f,c]=size(Tabla_in);
    columnas = string(Tabla_in.Properties.VariableNames);
    %segunda columna ->hora
    tf = iscell(Tabla_in.(columnas(2)));
    if tf == 1
        Time = string(Tabla_in.Time);
        Time = datetime(Time,'Format', 'HH:mm:ss');%hora en 24 horas.
        ho=hour(Time(:)); mi=minute(Time(:)); se=second(Time(:));
        Time = duration(ho,mi,se);
    end
    %columnas numéricas de la tres en adelante
    Numericos = zeros(f,c-2);
    for col = 3:c
        tf = iscell(Tabla_in.(columnas(col)));
            if tf == 1
                Numericos(:,col-2) = str2double(Tabla_in.(columnas(col)));
            end
    end
    Tabla_out = table(Tabla_in.(columnas(1)),Time,Numericos(:,1),Numericos(:,2),Numericos(:,3),Numericos(:,4),Numericos(:,5));
    Tabla_out.Properties.VariableNames = Tabla_in.Properties.VariableNames;
else
    Tabla_out = Tabla_in;
end
end

