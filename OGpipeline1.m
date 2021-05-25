clc, clear, close all;
margin = .01
for i = 1:length(ForceplateNum)
    c = ForcePlateNum(i)
    endfor
function [sGRFdata] = SeparateGRF(MarkerData,GRFdata,Markerset,ForceplateNum)
  sgrf = zeros (sizeof(GRFdata))
  endfor
for i:length(Markerset)
  if strcmp(Markerset(i), ['RCAL'])
    rc = i
  endif
if strcmp(Markerset(i), ['RTOE'])
    rt = i
  endif
  if strcmp(Markerset(i), ['LCAL'])
    lc = i
  endif
  if strcmp(Markerset(i), ['LTOE'])
    lt = i
  endif
  if strcmp(Markerset(i), ['LTOE'])
    lt = i
  endif
  if strcmp(Markerset(i), ['LMML'])
    lmal = i
  endif
  if strcmp(Markerset(i), ['RMML'])
    rmal = i
  endif
  if strcmp(Markerset(i), ['LMT5'])
    lmt5 = i
  endif
  if strcmp(Markerset(i), ['RMT5'])
    rmt5 = i
  endif
endfor

for c = ForcePlateNum
  a = 0;
  for i = 1:length(GRFData}
  %Check if the force plate is activated 
  if a == 0
    if GRFdata(i, 9*c - 6) > 20 
      fp{c} = [fp{c} i]
      a = 1
    endif
    if a == 1
      endif
      if GRFData(i, 9*c-6) < 10
        fp{c} = [fp{c} i]
        a = 0
      endif
    endif
  %Find times when the foot is within the bounds of the FP 
  for c = ForcePlateNum
    a = 0
    b = 0
    rf{c} = []
    lf{c} = []
    for i= 1:length(MarkerData) 
      x1 = min(FocreplateNum{c}(:,1))-margin;
      x2 = max(ForcePlateNum{c}(:,1))+margin;
      z1 = min(ForcePlateNum{c}(:,3))-margin
      z2 = min(ForcePlateNum{c}(:.3))+margin
      
      %If right foot is within bounds (x1 will be lower value bound, x2 will be higher value bound, z1 will smaller z and z2 will be higher z)
      %Handles the case of foot being parallel to froce plate 
     if a == 0 
      if MarkerData(i, rc*3 - 1) > x1 && MarkerData(i, rc*3-1) < x2 && MarkerData(i,rt*3-1) > x1 && MarkerData(i, rt*3-1) < x2 && MarkerData(i, rmal*3+1) > z1 and MarkerData(i, rmal*3+1) < z2 && MarkerData(i, rmt5*3+1) >z1 && MarkerData(i, rmt5*3+1) < z2...
        %Handles case of foot being perpendicular to fp
        && MarkerData(i,rc*3+1) > z1 && MarkerData(i, rc*3+1) < z2 && MarkerData(i, rt *3+1) > z1 && MarkerData(i, rt*3+1) < z2 && MarkerData(i, rmal*3-1) > x1 && MarkerData(i, rmal*3-1) < x2 && MarkerData(i, rmt5*3-1) > x1 && MarkerData(i, rmt5*3 -1) < x1
        rf{c} = [rf{c} i]
        a = 1
      endif
      if a == 1
        if MarkerData(i, rc*3 - 1) > x1 || MarkerData(i, rc*3-1) < x2 || MarkerData(i,rt*3-1) > x1 || MarkerData(i, rt*3-1) < x2 || MarkerData(i, rmal*3+1) > z1 and MarkerData(i, rmal*3+1) < z2 || MarkerData(i, rmt5*3+1) >z1 || MarkerData(i, rmt5*3+1) < z2...
        || MarkerData(i,rc*3+1) > z1 || MarkerData(i, rc*3+1) < z2 || MarkerData(i, rt *3+1) >z1 || MarkerData(i, rt*3+1) < z2 || MarkerData(i, rmal*3-1) > x1 || MarkerData(i, rmal*3-1) < x2 || MarkerData(i, rmt5*3-1) > x1 || MarkerData(i, rmt5*3 -1) < x1
        rf{c} = [rf{c} i]
      endif
      if b == 0
         if MarkerData(i, lc*3 - 1) > x1 && MarkerData(i, lc*3-1) < x2 && MarkerData(i,lt*3-1) > x1 && MarkerData(i, lt*3-1) < x2 && MarkerData(i, lmal*3+1) > z1 and MarkerData(i,lmt5*3+1) < z2 && MarkerData(i, lmal*3+1) < z2 && MarkerData(i, lmt5*3+1) > z1...
        %Handles case of foot being perpendicular to fp
        && MarkerData(i,lc*3+1) > z1 && MarkerData(i, lc*3+1) < z2 && MarkerData(i, lt *3+1) >z1 && MarkerData(i, lt*3+1) < z2 && MarkerData(i, lmal*3-1) > x1 && MarkerData(i, lmal*3-1) < x2 && MarkerData(i, lmt5*3-1) > x1 && MarkerData(i, lmt5*3 -1) < x2
        lf{c} = [lf{c} i]
        b = 1
      endif
      if b == 1
           if MarkerData(i, lc*3 - 1) > x1 || MarkerData(i, lc*3-1) < x2 || MarkerData(i,lt*3-1) > x1 || MarkerData(i, lt*3-1) < x2 || MarkerData(i, lmal*3+1) > z1 and MarkerData(i,lmt5*3+1) < z2 || MarkerData(i, lmal*3+1) < z2 || MarkerData(i, lmt5*3+1) > z1...
        %Handles case of foot being perpendicular to fp
        || MarkerData(i,lc*3+1) > z1 || MarkerData(i, lc*3+1) < z2 || MarkerData(i, lt *3+1) >z1 || MarkerData(i, lt*3+1) < z2 || MarkerData(i, lmal*3-1) > x1 || MarkerData(i, lmal*3-1) < x2 || MarkerData(i, lmt5*3-1) > x1 || MarkerData(i, lmt5*3 -1) < x2
        lf{c} = [lf{c} i]
        b = 0
      endif
    endfor
  endfor
  
  for c = 1: length(ForcePlateNum)
    a = 0;
    b = 0;
    if c == 1
      col1 = 2
      col2 = 10
    endif
    if c == 2 
      col1 = 11
      col2 = 19
    endif
    if c == 3 
      col1 = 20
      col2 = 28
    endif
    for i = 1:2:length(fp{c})
      for j = 1:2:length(rf{c})
        if rf{c}(j) * 10 - 1 < fp{c}(i) && rf{c}(j+1) * 10 - 1 > fp(i)
          sgrf(fp(i):fp(i+1), 2:10) = grf(i:i+1, col1:col2)
          a = 1;
        endif
        endfor
        if lf{c}(j) * 10 - 1 < fp{c}(i) && lf{c}(j) * 10 - 1 < fp{c}(i)
          sgrf(fp(i):fp(i+1), 11:19) = grf(fp(i):fp(i+1), col1:col2);
          b = 1
          endfor
        endif
        if a == 1 && b == 1
          if mean(MarkerData(fp(i):fp(i+1), rmal*3) < mean(MarkerData(fp(i):fp(i+1), lmal*3))
            sgrf(fp(i):fp(i+1), 11:19) = 0 
          endif
          if mean(Markerdata(fp(i):fp(i+1), lmal*3) < mean(MarkerData(fp(i):fp(i+1), rmal*3)
            sgrf(fp(i):fp(i+1), 2:10) = 0
          endif
        endif
  endfor
  endfor
  
  