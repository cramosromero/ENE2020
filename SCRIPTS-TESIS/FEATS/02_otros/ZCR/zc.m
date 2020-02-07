function [zcr_coeff] = zc(chunk_de_senal,Fs)
%Zero crossing rate
[ff,cc] = size(chunk_de_senal);
signo = zeros(ff,cc);
for f = 1:ff
    for c = 1:cc
        if chunk_de_senal(f,c)>0
            signo(f,c) = 1;
        elseif chunk_de_senal(f,c) == 0
            signo(f,c) = 0;
        else
            signo(f,c) = -1;
        end
    end
end

signo = signo.';
%{
figure()
subplot(2,1,1)
plot(chunk_de_senal(1,:));hold on; plot(signo(:,1))
subplot(2,1,2)
plot(chunk_de_senal(2,:));hold on; plot(signo(:,2))
%}

d_signo = diff(signo);
zcr_coeff =(1/2).* sum(abs(d_signo)).*(Fs/cc);
end


