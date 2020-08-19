function [sGRFdata] = SeparateGRF(MarkerData,GRFdata,Markerset)
%SeparateGRF function separate ground reaction force data into forces onto
%each foot

%Identifies RTOE, RCAL, LTOE, and LCAL data columns
for i=1:length(Markerset)
    if strcmp(Markerset(i),{'RCAL'})
        rc=i;
    elseif strcmp(Markerset(i),{'RTOE'})
        rt=i;
    elseif strcmp(Markerset(i),{'LCAL'})
        lc=i;
    elseif strcmp(Markerset(i),{'LTOE'})
        lt=i;
    end
end

%Identifies initial gait condition
a=0;
for i=1:lengthGRFdata %finds first heel strike
    if a==0
        if GRFdata(i,3)==0
            a=1;
        end
    elseif a==1
        if GRFdata(i,3)>20
            initialstrike=i;
            a=2;
        end
    end
end
r=1; %right foot contact status
l=1;%left foot contact status

%Identifies heel strike and toe off timings
rhs=[]; lhs=[];
rto=[]; lto=[];
for i=ceil(initialstrike/10)+5:length(MarkerData)
    if r==0 %looking for right heel strike
        if MarkerData(i,rc*3-1)<MarkerData(i-1,rc*3-1) && MarkerData(i,rc*3-1)<MarkerData(i-2,rc*3-1) && MarkerData(i,rc*3-1)<MarkerData(i-3,rc*3-1)
            rhs=[rhs i-2];
            r=1;
        end
    elseif r==1
        if l==0 %looking for left heel strike
            if MarkerData(i,lc*3-1)<MarkerData(i-1,lc*3-1) && MarkerData(i,lc*3-1)<MarkerData(i-2,lc*3-1) && MarkerData(i,lc*3-1)<MarkerData(i-3,lc*3-1)
                lhs=[lhs i-2];
                l=1;
            end
        elseif l==1
            if MarkerData(i,lc*3-1) > MarkerData(i,rc*3-1)%looking for right toe off
                if MarkerData(i,rt*3-1)>MarkerData(i-1,rt*3-1) && MarkerData(i,rt*3-1)>MarkerData(i-2,rt*3-1) && MarkerData(i,rt*3-1)>MarkerData(i-3,rt*3-1)
                    rto=[rto i-2];
                    r=0;
                end
            elseif MarkerData(i,lc*3-1) < MarkerData(i,rc*3-1) %looking for left toe off
                if MarkerData(i,lt*3-1)>MarkerData(i-1,lt*3-1) && MarkerData(i,lt*3-1)>MarkerData(i-2,lt*3-1) && MarkerData(i,lt*3-1)>MarkerData(i-3,lt*3-1)
                    lto=[lto i-2];
                    l=0;
                end
            end
        end
    end
end
if GRFdata(1,3)==0

%Uses the gait cycle event data to separate GRF

end