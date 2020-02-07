function [spec_coeff]=spec(segment,Fs,n_bins_fft)
% Obtener el espectro mediante FFT
% Ingresa el segmento de señal, FS y los n bins
TF = fft(segment,n_bins_fft,2);
P2 = abs(TF/length(TF));
    P1_1 = P2(1,1:length(TF)/2+1);
    P1_2 = P2(2,1:length(TF)/2+1);
P1_1(2:end-1) = 2*P1_1(2:end-1);
P1_2(2:end-1) = 2*P1_2(2:end-1);
f = Fs*(0:(length(TF)/2))/length(TF);

spec_coeff = [P1_1 P1_2];
% semilogx(f,P1_1); hold on; semilogx(f,P1_2)
end