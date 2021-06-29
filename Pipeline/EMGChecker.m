function [g] = EMGChecker(EMGdata,tname,colname,si)
%The function inputs a vector of raw EMG and its header and checks it for errors

samfreq=1/si;
l=length(EMGdata);
g=0;

%fast fourier
y=fft(EMGdata);
P2 = abs(y/l);
P1 = P2(1:floor(l/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = samfreq*(0:floor(l/2))/l;

%checks
if mean(P1(sum(f<20):sum(f<100)))<5*mean(P1(sum(f<200):sum(f<500)))
    warning('poor signal to noise ratio at %s, check sensor connectivity of %s', tname, colname)
    g=1;
elseif median(P1(sum(f<20):sum(f<100)))<2*median(P1(1:sum(f<15)))
    warning('low frequency motion artifact at %s, detected in %s', tname, colname)
    g=2;
end

%plot if check flagged
if g==1||g==2
    figure
    subplot(2,1,1)
    plot(1:length(EMGdata),EMGdata)
    title([tname colname ' Raw EMG'])
    subplot(2,1,2)
    plot(f,P1)
    title(['Single-Sided Amplitude Spectrum of ' tname colname])
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    axis([0 300 0 10^-6])
end
end