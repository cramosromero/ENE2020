clear; clc; close;
t = 2;
Fs = 44100;
y1 = wgn(t.*Fs,1,0) ;
T = linspace(1,Fs*t,Fs*t)./Fs;
tt = linspace(1,Fs*t,Fs*t)./Fs;
hz = 50; tp = 10.*sin(hz.tt);



wt = 100;   %miliseconds
n_sam = wt.*Fs/1000;

B = buffer(y1,n_sam);
chunk_de_senal = B(:,1);
[~,chunks ]= size(B);
zcr = zeros(1,chunks);
for W = 1:chunks
    zcr(W)=zc(B(:,W),Fs);
end
figure();plot(zcr./max(zcr))
figure();plot(y1)
% Hs = hamming(n_sam,'symmetric');
% wvtool(Hs)
% W_whamm = B(:,W).*Hs;
% 
% Hh = hann(n_sam,'symmetric');
% wvtool(Hh)
% W_whann = B(:,W).*Hh;
% 
% plot(B(:,W)); hold on; plot(W_whamm); hold on; plot(W_whann);