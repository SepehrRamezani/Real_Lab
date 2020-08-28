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
for i=1:length(GRFdata) %finds first heel strike
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
        if MarkerData(i,rc*3-1)<MarkerData(i-1,rc*3-1) && MarkerData(i,rc*3-1)<MarkerData(i-2,rc*3-1) && MarkerData(i,rc*3-1)<MarkerData(i-3,rc*3-1) && MarkerData(i,rc*3-1)>MarkerData(i,lc*3-1)
            rhs=[rhs i-2];
            r=1;
        end
    elseif r==1
        if l==0 %looking for left heel strike
            if MarkerData(i,lc*3-1)<MarkerData(i-1,lc*3-1) && MarkerData(i,lc*3-1)<MarkerData(i-2,lc*3-1) && MarkerData(i,lc*3-1)<MarkerData(i-3,lc*3-1) && MarkerData(i,rc*3-1)<MarkerData(i,lc*3-1)
                lhs=[lhs i-2];
                l=1;
            end
        elseif l==1
            if MarkerData(i,lc*3-1) > MarkerData(i,rc*3-1)%looking for right toe off
                if MarkerData(i,rt*3-1)>MarkerData(i-1,rt*3-1) && MarkerData(i,rt*3-1)>MarkerData(i-2,rt*3-1) && MarkerData(i,rt*3-1)>MarkerData(i-3,rt*3-1)
                    rto=[rto i-2];
                    r=0;
                    if MarkerData(i-2,lc*3-1) < 325 %checks if left heel is on back plate
                        disp(['Late Right Toe Off Detected at ' num2str(length(rto)) 'th Toe Off, Time: ' num2str(MarkerData(i-2,1))]) 
                    end
                end
            elseif MarkerData(i,lc*3-1) < MarkerData(i,rc*3-1) %looking for left toe off
                if MarkerData(i,lt*3-1)>MarkerData(i-1,lt*3-1) && MarkerData(i,lt*3-1)>MarkerData(i-2,lt*3-1) && MarkerData(i,lt*3-1)>MarkerData(i-3,lt*3-1)
                    lto=[lto i-2];
                    l=0;
                    if MarkerData(i-2,rc*3-1) < 325 %checks if right heel is on back plate
                        disp(['Late Left Toe Off Detected at ' num2str(length(lto)) 'th Toe Off, Time: ' num2str(MarkerData(i-2,1))])
                    end
                end
            end
        end
    end
end
if MarkerData(ceil(initialstrike/10),lc*3-1) > MarkerData(ceil(initialstrike/10),rc*3-1) %left ahead of right
    for i=1:ceil(initialstrike/10)
        if MarkerData(i,lc*3-1) == max(MarkerData(1:ceil(initialstrike/10),lc*3-1))
            lhs=[i lhs];%adds initial heel strike
        end
    end
    for i=1:ceil(initialstrike/10) %looks for a left toe off before initial heel strike
        if MarkerData(i,lt*3-1) == min(MarkerData(1:ceil(initialstrike/10),lt*3-1)) && i>3
            lto=[i lto];
        end
    end
else
    for i=1:ceil(initialstrike/10)
        if MarkerData(i,rc*3-1) == max(MarkerData(1:ceil(initialstrike/10),rc*3-1))
            rhs=[i rhs];%adds initial heel strike
        end
    end
    for i=1:ceil(initialstrike/10) %looks for a right toe off before initial heel strike
        if MarkerData(i,rt*3-1) == min(MarkerData(1:ceil(initialstrike/10),rt*3-1)) && i>3
            rto=[i rto];
        end
    end    
end

%tests gait events
figure
hold on
plot(MarkerData(1:500,1),MarkerData(1:500,rc*3-1),'k',MarkerData(1:500,1),MarkerData(1:500,lc*3-1),'b')
plot(MarkerData(1:500,1),MarkerData(1:500,rt*3-1),'m',MarkerData(1:500,1),MarkerData(1:500,lt*3-1),'r')
i=1;
while rhs(i)<500
    plot([MarkerData(rhs(i),1),MarkerData(rhs(i),1)],[0,500],'k')
    i=i+1;
end
i=1;
while lhs(i)<500
    plot([MarkerData(lhs(i),1),MarkerData(lhs(i),1)],[0,500],'b')
    i=i+1;
end
i=1;
while rto(i)<500
    plot([MarkerData(rto(i),1),MarkerData(rto(i),1)],[0,500],'m')
    i=i+1;
end
i=1;
while lto(i)<500
    plot([MarkerData(lto(i),1),MarkerData(lto(i),1)],[0,500],'r')
    i=i+1;
end
hold off

%Uses the gait cycle event data to separate GRF
sGRFdata=zeros(size(GRFdata));
sGRFdata(:,1)=GRFdata(:,1);%time data
fweight=GRFdata(:,3)./(GRFdata(:,3)+GRFdata(:,12));
bweight=GRFdata(:,12)./(GRFdata(:,3)+GRFdata(:,12));
%determines starting feature and adds pre-event data
if rhs(1)<lto(1) && rhs(1)<lhs(1) && rhs(1)<rto(1)
    intevent=1;%start rhs, pre-event left single stance
    sGRFdata(1:rhs(1)*10-1,11:13)=GRFdata(1:rhs(1)*10-1,2:4)+GRFdata(1:rhs(1)*10-1,11:13);%combine force for left
    sGRFdata(1:rhs(1)*10-1,14:16)=GRFdata(1:rhs(1)*10-1,5:7).*fweight(1:rhs(1)*10-1)+GRFdata(1:rhs(1)*10-1,14:16).*bweight(1:rhs(1)*10-1);%combine COP for left
    sGRFdata(1:rhs(1)*10-1,17:19)=GRFdata(1:rhs(1)*10-1,8:10)+GRFdata(1:rhs(1)*10-1,17:19);%combine moment for left
elseif lto(1)<lhs(1) && lto(1)<rto(1) && lto(1)<rhs(1)
    intevent=2;%start lto, pre-event right led dual stance
    sGRFdata(1:lto(1)*10-1,2:10)=GRFdata(1:lto(1)*10-1,2:10);%right on front
    sGRFdata(1:lto(1)*10-1,11:19)=GRFdata(1:lto(1)*10-1,11:19);%left on back
elseif lhs(1)<rto(1) && lhs(1)<rhs(1) && lhs(1)<lto(1)
    intevent=3;%start lhs, pre-event right single stance
    sGRFdata(1:lhs(1)*10-1,2:4)=GRFdata(1:lhs(1)*10-1,2:4)+GRFdata(1:lhs(1)*10-1,11:13);%combine force for right
    sGRFdata(1:lhs(1)*10-1,5:7)=GRFdata(1:lhs(1)*10-1,5:7).*fweight(1:lhs(1)*10-1)+GRFdata(1:lhs(1)*10-1,14:16).*bweight(1:lhs(1)*10-1);%combine COP for right
    sGRFdata(1:lhs(1)*10-1,8:10)=GRFdata(1:lhs(1)*10-1,8:10)+GRFdata(1:lhs(1)*10-1,17:19);%combine moment for right
elseif rto(1)<rhs(1) && rto(1)<lto(1) && rto(1)<lhs(1)
    intevent=4;%start rto, pre-event left led dual stance
    sGRFdata(1:rto(1)*10-1,2:10)=GRFdata(1:rto(1)*10-1,11:19);%right on back
    sGRFdata(1:rto(1)*10-1,11:19)=GRFdata(1:rto(1)*10-1,2:10);%left on front
end
%adds data between rhs and lto (right led dual stance)
if intevent==2
    if length(lto)==length(rhs)%starts on lto, ends on rhs
        for i=1:length(rhs)-1
            sGRFdata(rhs(i)*10:lto(i+1)*10-1,2:10)=GRFdata(rhs(i)*10:lto(i+1)*10-1,2:10);
            sGRFdata(rhs(i)*10:lto(i+1)*10-1,11:19)=GRFdata(rhs(i)*10:lto(i+1)*10-1,11:19);
        end
    else%starts on lto, doesn't end on rhs
        for i=1:length(rhs)
            sGRFdata(rhs(i)*10:lto(i+1)*10-1,2:10)=GRFdata(rhs(i)*10:lto(i+1)*10-1,2:10);
            sGRFdata(rhs(i)*10:lto(i+1)*10-1,11:19)=GRFdata(rhs(i)*10:lto(i+1)*10-1,11:19);
        end
    end
else
    if length(lto)==length(rhs)%doesn't start on lto, doesn't end on rhs
        for i=1:length(rhs)
            sGRFdata(rhs(i)*10:lto(i)*10-1,2:10)=GRFdata(rhs(i)*10:lto(i)*10-1,2:10);
            sGRFdata(rhs(i)*10:lto(i)*10-1,11:19)=GRFdata(rhs(i)*10:lto(i)*10-1,11:19);
        end
    else%doesn't start on lto, ends on rhs
        for i=1:length(rhs)-1
            sGRFdata(rhs(i)*10:lto(i)*10-1,2:10)=GRFdata(rhs(i)*10:lto(i)*10-1,2:10);
            sGRFdata(rhs(i)*10:lto(i)*10-1,11:19)=GRFdata(rhs(i)*10:lto(i)*10-1,11:19);
        end
    end
end
%adds data between lto and lhs (right single stance)
if intevent==3
    if length(lhs)==length(lto)%starts on lhs, ends on lto
        for i=1:length(lto)-1
            sGRFdata(lto(i)*10:lhs(i+1)*10-1,2:4)=GRFdata(lto(i)*10:lhs(i+1)*10-1,2:4)+GRFdata(lto(i)*10:lhs(i+1)*10-1,11:13);
            sGRFdata(lto(i)*10:lhs(i+1)*10-1,5:7)=GRFdata(lto(i)*10:lhs(i+1)*10-1,5:7).*fweight(lto(i)*10:lhs(i+1)*10-1)+GRFdata(lto(i)*10:lhs(i+1)*10-1,14:16).*bweight(lto(i)*10:lhs(i+1)*10-1);
            sGRFdata(lto(i)*10:lhs(i+1)*10-1,8:10)=GRFdata(lto(i)*10:lhs(i+1)*10-1,8:10)+GRFdata(lto(i)*10:lhs(i+1)*10-1,17:19);
        end
    else%starts on lhs, doesn't end on lto
        for i=1:length(lto)
            sGRFdata(lto(i)*10:lhs(i+1)*10-1,2:4)=GRFdata(lto(i)*10:lhs(i+1)*10-1,2:4)+GRFdata(lto(i)*10:lhs(i+1)*10-1,11:13);
            sGRFdata(lto(i)*10:lhs(i+1)*10-1,5:7)=GRFdata(lto(i)*10:lhs(i+1)*10-1,5:7).*fweight(lto(i)*10:lhs(i+1)*10-1)+GRFdata(lto(i)*10:lhs(i+1)*10-1,14:16).*bweight(lto(i)*10:lhs(i+1)*10-1);
            sGRFdata(lto(i)*10:lhs(i+1)*10-1,8:10)=GRFdata(lto(i)*10:lhs(i+1)*10-1,8:10)+GRFdata(lto(i)*10:lhs(i+1)*10-1,17:19);
        end
    end
else
    if length(lhs)==length(lto)%doesn't start on lhs, doesn't end on lto
        for i=1:length(lto)
            sGRFdata(lto(i)*10:lhs(i)*10-1,2:4)=GRFdata(lto(i)*10:lhs(i)*10-1,2:4)+GRFdata(lto(i)*10:lhs(i)*10-1,11:13);
            sGRFdata(lto(i)*10:lhs(i)*10-1,5:7)=GRFdata(lto(i)*10:lhs(i)*10-1,5:7).*fweight(lto(i)*10:lhs(i)*10-1)+GRFdata(lto(i)*10:lhs(i)*10-1,14:16).*bweight(lto(i)*10:lhs(i)*10-1);
            sGRFdata(lto(i)*10:lhs(i)*10-1,8:10)=GRFdata(lto(i)*10:lhs(i)*10-1,8:10)+GRFdata(lto(i)*10:lhs(i)*10-1,17:19);
        end
    else%doesn't start on lhs, ends on lto
        for i=1:length(lto)-1
            sGRFdata(lto(i)*10:lhs(i)*10-1,2:4)=GRFdata(lto(i)*10:lhs(i)*10-1,2:4)+GRFdata(lto(i)*10:lhs(i)*10-1,11:13);
            sGRFdata(lto(i)*10:lhs(i)*10-1,5:7)=GRFdata(lto(i)*10:lhs(i)*10-1,5:7).*fweight(lto(i)*10:lhs(i)*10-1)+GRFdata(lto(i)*10:lhs(i)*10-1,14:16).*bweight(lto(i)*10:lhs(i)*10-1);
            sGRFdata(lto(i)*10:lhs(i)*10-1,8:10)=GRFdata(lto(i)*10:lhs(i)*10-1,8:10)+GRFdata(lto(i)*10:lhs(i)*10-1,17:19);
        end
    end
end
%adds data between lhs and rto (left led dual stance)
if intevent==4
    if length(rto)==length(lhs)%starts on rto, ends on lhs
        for i=1:length(lhs)-1
            sGRFdata(lhs(i)*10:rto(i+1)*10-1,2:10)=GRFdata(lhs(i)*10:rto(i+1)*10-1,11:19);
            sGRFdata(lhs(i)*10:rto(i+1)*10-1,11:19)=GRFdata(lhs(i)*10:rto(i+1)*10-1,2:10);
        end
    else%starts on rto, doesn't end on lhs
        for i=1:length(lhs)
            sGRFdata(lhs(i)*10:rto(i+1)*10-1,2:10)=GRFdata(lhs(i)*10:rto(i+1)*10-1,11:19);
            sGRFdata(lhs(i)*10:rto(i+1)*10-1,11:19)=GRFdata(lhs(i)*10:rto(i+1)*10-1,2:10);
        end
    end
else
    if length(rto)==length(lhs)%doesn't start on rto, doesn't end on lhs
        for i=1:length(lhs)
            sGRFdata(lhs(i)*10:rto(i)*10-1,2:10)=GRFdata(lhs(i)*10:rto(i)*10-1,11:19);
            sGRFdata(lhs(i)*10:rto(i)*10-1,11:19)=GRFdata(lhs(i)*10:rto(i)*10-1,2:10);
        end
    else%doesn't start on rto, ends on lhs
        for i=1:length(lhs)-1
            sGRFdata(lhs(i)*10:rto(i)*10-1,2:10)=GRFdata(lhs(i)*10:rto(i)*10-1,11:19);
            sGRFdata(lhs(i)*10:rto(i)*10-1,11:19)=GRFdata(lhs(i)*10:rto(i)*10-1,2:10);
        end
    end
end
%adds data between rto and rhs (left single stance)
if intevent==1
    if length(rhs)==length(rto)%starts on rhs, ends on rto
        for i=1:length(rto)-1
            sGRFdata(rto(i)*10:rhs(i+1)*10-1,11:13)=GRFdata(rto(i)*10:rhs(i+1)*10-1,2:4)+GRFdata(rto(i)*10:rhs(i+1)*10-1,11:13);
            sGRFdata(rto(i)*10:rhs(i+1)*10-1,14:16)=GRFdata(rto(i)*10:rhs(i+1)*10-1,5:7).*fweight(rto(i)*10:rhs(i+1)*10-1)+GRFdata(rto(i)*10:rhs(i+1)*10-1,14:16).*bweight(rto(i)*10:rhs(i+1)*10-1);
            sGRFdata(rto(i)*10:rhs(i+1)*10-1,17:19)=GRFdata(rto(i)*10:rhs(i+1)*10-1,8:10)+GRFdata(rto(i)*10:rhs(i+1)*10-1,17:19);
        end
    else%starts on rhs, doesn't end on rto
        for i=1:length(rto)
            sGRFdata(rto(i)*10:rhs(i+1)*10-1,11:13)=GRFdata(rto(i)*10:rhs(i+1)*10-1,2:4)+GRFdata(rto(i)*10:rhs(i+1)*10-1,11:13);
            sGRFdata(rto(i)*10:rhs(i+1)*10-1,14:16)=GRFdata(rto(i)*10:rhs(i+1)*10-1,5:7).*fweight(rto(i)*10:rhs(i+1)*10-1)+GRFdata(rto(i)*10:rhs(i+1)*10-1,14:16).*bweight(rto(i)*10:rhs(i+1)*10-1);
            sGRFdata(rto(i)*10:rhs(i+1)*10-1,17:19)=GRFdata(rto(i)*10:rhs(i+1)*10-1,8:10)+GRFdata(rto(i)*10:rhs(i+1)*10-1,17:19);
        end
    end
else
    if length(rhs)==length(rto)%doesn't start on rhs, doesn't end on rto
        for i=1:length(rto)
            sGRFdata(rto(i)*10:rhs(i)*10-1,11:13)=GRFdata(rto(i)*10:rhs(i)*10-1,2:4)+GRFdata(rto(i)*10:rhs(i)*10-1,11:13);
            sGRFdata(rto(i)*10:rhs(i)*10-1,14:16)=GRFdata(rto(i)*10:rhs(i)*10-1,5:7).*fweight(rto(i)*10:rhs(i)*10-1)+GRFdata(rto(i)*10:rhs(i)*10-1,14:16).*bweight(rto(i)*10:rhs(i)*10-1);
            sGRFdata(rto(i)*10:rhs(i)*10-1,17:19)=GRFdata(rto(i)*10:rhs(i)*10-1,8:10)+GRFdata(rto(i)*10:rhs(i)*10-1,17:19);
        end
    else%doesn't start on rhs, ends on rto
        for i=1:length(rto)-1
            sGRFdata(rto(i)*10:rhs(i)*10-1,11:13)=GRFdata(rto(i)*10:rhs(i)*10-1,2:4)+GRFdata(rto(i)*10:rhs(i)*10-1,11:13);
            sGRFdata(rto(i)*10:rhs(i)*10-1,14:16)=GRFdata(rto(i)*10:rhs(i)*10-1,5:7).*fweight(rto(i)*10:rhs(i)*10-1)+GRFdata(rto(i)*10:rhs(i)*10-1,14:16).*bweight(rto(i)*10:rhs(i)*10-1);
            sGRFdata(rto(i)*10:rhs(i)*10-1,17:19)=GRFdata(rto(i)*10:rhs(i)*10-1,8:10)+GRFdata(rto(i)*10:rhs(i)*10-1,17:19);
        end
    end
end
%determines last feature and adds post-event data
if rto(end)>rhs(end) && rto(end)>lto(end) && rto(end)>lhs(end)%ends rto, post-event left single stance
    sGRFdata(rto(end)*10:end,11:13)=GRFdata(rto(end)*10:end,2:4)+GRFdata(rto(end)*10:end,11:13);%combine force for left
    sGRFdata(rto(end)*10:end,14:16)=GRFdata(rto(end)*10:end,5:7).*fweight(rto(end)*10:end)+GRFdata(rto(end)*10:end,14:16).*bweight(rto(end)*10:end);%combine COP for left
    sGRFdata(rto(end)*10:end,17:19)=GRFdata(rto(end)*10:end,8:10)+GRFdata(rto(end)*10:end,17:19);%combine moment for left
elseif rhs(end)>lto(end) && rhs(end)>lhs(end) && rhs(end)>rto(end)%ends rhs, post-event right led dual stance
    sGRFdata(rhs(end)*10:end,2:10)=GRFdata(rhs(end)*10:end,2:10);%right on front
    sGRFdata(rhs(end)*10:end,11:19)=GRFdata(rhs(end)*10:end,11:19);%left on back
elseif lto(end)>lhs(end) && lto(end)>rto(end) && lto(end)>rhs(end)%ends lto, post-event right single stance
    sGRFdata(lto(end)*10:end,2:4)=GRFdata(lto(end)*10:end,2:4)+GRFdata(lto(end)*10:end,11:13);%combine force for right
    sGRFdata(lto(end)*10:end,5:7)=GRFdata(lto(end)*10:end,5:7).*fweight(lto(end)*10:end)+GRFdata(lto(end)*10:end,14:16).*bweight(lto(end)*10:end);%combine COP for right
    sGRFdata(lto(end)*10:end,8:10)=GRFdata(lto(end)*10:end,8:10)+GRFdata(lto(end)*10:end,17:19);%combine moment for right
elseif lhs(end)>rto(end) && lhs(end)>rhs(end) && lhs(end)>lto(end)%ends lhs, post-event left led dual stance
    sGRFdata(lhs(end)*10:end,2:10)=GRFdata(lhs(end)*10:end,11:19);%right on back
    sGRFdata(lhs(end)*10:end,11:19)=GRFdata(lhs(end)*10:end,2:10);%left on front
end
end