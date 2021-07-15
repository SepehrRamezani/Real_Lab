function [sgrf] = OG_SeparateGRF(MarkerData,GRFdata,Markerset,ForceplateNum,ForcePlate)
  sgrf=zeros([length(GRFdata) 19]);
  sgrf(:,1)=GRFdata(:,1);
  CAL_margin = 30; %margins for the bounds of each marker
  MT5_margin = 30;
  MML_margin = 30;
  TOE_margin = 10;
  m_interval=MarkerData(2,1)-MarkerData(1,1);
  fp_interval=GRFdata(2,1)-GRFdata(1,1);
  freq_scale=m_interval./fp_interval;
  
for i=1:length(Markerset)
    if strcmp(Markerset(i),{'RCAL'})
        rc = i;
    elseif strcmp(Markerset(i),{'RTOE'})
        rt = i;
    elseif strcmp(Markerset(i),{'LCAL'})
        lc = i;
    elseif strcmp(Markerset(i),{'LTOE'})
        lt = i;
    elseif strcmp(Markerset(i),{'LMML'})
        lmal = i;
    elseif strcmp(Markerset(i),{'RMML'})
        rmal = i;
    elseif strcmp(Markerset(i),{'LMT5'})
        lmt5 = i;
    elseif strcmp(Markerset(i),{'RMT5'})
        rmt5 = i;
    end
end
% xf1=GRFdata(1,5); old code that swapped plates 1 and 2 to fix a vicon     
% zf1=GRFdata(1,7); issue in OG testing data
% xf2=GRFdata(1,14);
% zf2=GRFdata(1,16);
% GRFdata(:,5)=GRFdata(:,5)+xf2-xf1;
% GRFdata(:,7)=GRFdata(:,7)+zf2-zf1;
% GRFdata(:,14)=GRFdata(:,14)+xf1-xf2;
% GRFdata(:,16)=GRFdata(:,16)+zf1-zf2;
% corn=ForcePlate{1};
% ForcePlate{1}=ForcePlate{2};
% ForcePlate{2}=corn;
for c = ForceplateNum
    a = 0; fp{c}=[];
    for i = 1:length(GRFdata)
        %Check if the force plate is activated
        if a == 0
            if GRFdata(i, 9*c - 6) > 20 
                fp{c} = [fp{c} i];
                a = 1;
            end
        end
        if a == 1
            if GRFdata(i, 9*c-6) < 10
                fp{c} = [fp{c} i];
                a = 0;
            end
        end
    end
    if a==1 %handles case where a foot ends on a plate
        fp{c} = [fp{c} i];
    end
end
 %Find times when the foot is within the bounds of the FP 
for c = ForceplateNum
    a = 0;
    b = 0;
    rf{c} = [];
    lf{c} = [];
    x1 = min(ForcePlate{c}(:,1));
    x2 = max(ForcePlate{c}(:,1));
    z1 = min(ForcePlate{c}(:,3));
    z2 = max(ForcePlate{c}(:,3));
%If right foot is within bounds (x1 will be lower value bound, x2 will be higher value bound, z1 will smaller z and z2 will be higher z)
%Handles the case of foot being parallel to force plate 
    for i= 1:length(MarkerData)
        if a == 0 
            if MarkerData(i,rc*3-1)>x1-CAL_margin && MarkerData(i,rc*3-1)<x2+CAL_margin && MarkerData(i,rc*3+1)>z1-CAL_margin && MarkerData(i,rc*3+1)<z2+CAL_margin && MarkerData(i,rt*3-1)>x1-TOE_margin && MarkerData(i,rt*3-1)<x2+TOE_margin && MarkerData(i,rt*3+1)>z1-TOE_margin && MarkerData(i,rt*3+1)<z2+TOE_margin && MarkerData(i,rmal*3-1)>x1-MML_margin && MarkerData(i,rmal*3-1)<x2+MML_margin && MarkerData(i,rmal*3+1)>z1-MML_margin && MarkerData(i,rmal*3+1)<z2+MML_margin && MarkerData(i,rmt5*3-1)>x1-MT5_margin && MarkerData(i,rmt5*3-1)<x2+MT5_margin && MarkerData(i,rmt5*3+1)>z1-MT5_margin && MarkerData(i,rmt5*3+1)<z2+MT5_margin
%Handles case of foot being perpendicular to fp
                rf{c} = [rf{c} i];
                a = 1;
            end
        end
        if a == 1
            if MarkerData(i,rc*3-1)<x1-CAL_margin || MarkerData(i,rc*3-1)>x2+CAL_margin || MarkerData(i,rc*3+1)<z1-CAL_margin || MarkerData(i,rc*3+1)>z2+CAL_margin || MarkerData(i,rt*3-1)<x1-TOE_margin || MarkerData(i,rt*3-1)>x2+TOE_margin || MarkerData(i,rt*3+1)<z1-TOE_margin || MarkerData(i,rt*3+1)>z2+TOE_margin || MarkerData(i,rmal*3-1)<x1-MML_margin || MarkerData(i,rmal*3-1)>x2+MML_margin || MarkerData(i,rmal*3+1)<z1-MML_margin || MarkerData(i,rmal*3+1)>z2+MML_margin || MarkerData(i,rmt5*3-1)<x1-MT5_margin || MarkerData(i,rmt5*3-1)>x2+MT5_margin || MarkerData(i,rmt5*3+1)<z1-MT5_margin || MarkerData(i,rmt5*3+1)>z2+MT5_margin
                rf{c} = [rf{c} i];
                a = 0;
            end
        end
        if b == 0
            if MarkerData(i,lc*3-1)>x1-CAL_margin && MarkerData(i,lc*3-1)<x2+CAL_margin && MarkerData(i,lc*3+1)>z1-CAL_margin && MarkerData(i,lc*3+1)<z2+CAL_margin && MarkerData(i,lt*3-1)>x1-TOE_margin && MarkerData(i,lt*3-1)<x2+TOE_margin && MarkerData(i,lt*3+1)>z1-TOE_margin && MarkerData(i,lt*3+1)<z2+TOE_margin && MarkerData(i,lmal*3-1)>x1-MML_margin && MarkerData(i,lmal*3-1)<x2+MML_margin && MarkerData(i,lmal*3+1)>z1-MML_margin && MarkerData(i,lmal*3+1)<z2+MML_margin && MarkerData(i,lmt5*3-1)>x1-MT5_margin && MarkerData(i,lmt5*3-1)<x2+MT5_margin && MarkerData(i,lmt5*3+1)>z1-MT5_margin && MarkerData(i,lmt5*3+1)<z2+MT5_margin
%Handles case of foot being perpendicular to fp
                lf{c} = [lf{c} i];
                b = 1;
            end
        end
        if b == 1
            if MarkerData(i,lc*3-1)<x1-CAL_margin || MarkerData(i,lc*3-1)>x2+CAL_margin || MarkerData(i,lc*3+1)<z1-CAL_margin || MarkerData(i,lc*3+1)>z2+CAL_margin || MarkerData(i,lt*3-1)<x1-TOE_margin || MarkerData(i,lt*3-1)>x2+TOE_margin || MarkerData(i,lt*3+1)<z1-TOE_margin || MarkerData(i,lt*3+1)>z2+TOE_margin || MarkerData(i,lmal*3-1)<x1-MML_margin || MarkerData(i,lmal*3-1)>x2+MML_margin || MarkerData(i,lmal*3+1)<z1-MML_margin || MarkerData(i,lmal*3+1)>z2+MML_margin || MarkerData(i,lmt5*3-1)<x1-MT5_margin || MarkerData(i,lmt5*3-1)>x2+MT5_margin || MarkerData(i,lmt5*3+1)<z1-MT5_margin || MarkerData(i,lmt5*3+1)>z2+MT5_margin
%Handles case of foot being perpendicular to fp
                lf{c} = [lf{c} i];
                b = 0;
            end
        end
    end
    if a==1 %handles case where right foot ends on a plate
        rf{c} = [rf{c} i];
    end
    if b==1 %handles case where left foot ends on a plate
        lf{c} = [lf{c} i];
    end
end
  
for c = 1: length(ForceplateNum)
    if c == 1
        col1 = 2;
        col2 = 10;
    elseif c == 2 
        col1 = 11;
        col2 = 19;
    elseif c == 3 
      col1 = 20;
      col2 = 28;
    end
    for i = 1:2:length(fp{c})
        a=0; b=0;
        for j = 1:2:length(rf{c})
%If rf enters before fp is on and leaves after fp deactivated
            if rf{c}(j) * freq_scale - 1 < fp{c}(i) && rf{c}(j+1) * freq_scale - 1 > fp{c}(i+1)
                a = 1;
                rind=j;
            end
        end
        for k = 1:2:length(lf{c})
            if lf{c}(k) * freq_scale - 1 < fp{c}(i) && lf{c}(k+1) * freq_scale - 1 > fp{c}(i+1)
                b = 1;
                lind=k;
            end
        end
        if a == 1   %If rf inside fp and fp on       right foot is 2:10 left is 11:19
            if b == 0   %If rf inside fp and lf not
                sgrf(fp{c}(i):fp{c}(i+1),2:10) = GRFdata(fp{c}(i):fp{c}(i+1),col1:col2);
          %If lf and rf inside fp while on
            elseif b == 1
                if mean(MarkerData(rf{c}(rind):rf{c}(rind+1),rmal*3)) < mean(MarkerData(lf{c}(lind):lf{c}(lind+1),lmal*3))
                    %Put force plate data onto right foot
                    sgrf(fp{c}(i):fp{c}(i+1),2:10) = GRFdata(fp{c}(i):fp{c}(i+1),col1:col2);
                elseif mean(MarkerData(rf{c}(rind):rf{c}(rind+1),rmal*3)) > mean(MarkerData(lf{c}(lind):lf{c}(lind+1),lmal*3)) 
                    %Put FP data onto left foot
                    sgrf(fp{c}(i):fp{c}(i+1),11:19) = GRFdata(fp{c}(i):fp{c}(i+1),col1:col2);
                end
            end
        elseif b == 1   %If lf inside fp while activated     make this an else if to combine with above
            if a == 0   %If rf not inside fp
                sgrf(fp{c}(i):fp{c}(i+1),11:19) = GRFdata(fp{c}(i):fp{c}(i+1),col1:col2);
          %If rf and lf inside fp while activated
            end
        end
    end
end
end