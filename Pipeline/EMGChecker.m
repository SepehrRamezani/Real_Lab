function [] = EMGChecker(EMGdata,colname)
%The function inputs a vector of raw EMG and its header and checks it for errors

samfreq=2000;
l=length(EMGdata);
g=0;

%fast fourier
y=fft(EMGdata);
P2 = abs(y/l);
P1 = P2(1:floor(l/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = samfreq*(0:floor(l/2))/l;

%checks
if mean(P1(sum(f<20):sum(f<100)))<2*mean(P1(sum(f<200):sum(f<500)))
    warning(['poor signal to noise ratio, check sensor connectivity of ' colname])
    g=1;
elseif mean(P1(sum(f<20):sum(f<150)))<2*mean(P1(1:sum(f<20)))
    warning(['low frequency motion artifact detected in ' colname])
    g=1;
end

%plot if check flagged
if g==1
    figure
    subplot(2,1,1)
    plot(1:length(EMGdata),EMGdata)
    title([colname ' Raw EMG'])
    subplot(2,1,2)
    plot(f,P1)
    title(['Single-Sided Amplitude Spectrum of ' colname])
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    axis([0 1000 0 max(P1)])
end
end