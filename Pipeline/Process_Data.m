function Process_Data(fname,folder,ForceFlage,ForceComFlage,ForceplateNum)
% Add btk directory to MATLAB path  -> https://code.google.com/archive/p/b-tk/downloads
%% C3D file reading 
data = c3d_getdata([folder fname]);
% for changing Vicon Axis to Opensim Axis NewAxis=OldeAxis*RMatrix, for
% example: having matrix of [0 1 0;0 0 1;1 0 0] converts xyz to ZXY
RMatrix=[0 0 1; ...
         1 0 0; ...
         0 1 0];
%% Generate .Trc for Marker set
%%% Giving marker names 
Markerset=fieldnames(data.marker_data.Markers);
%%% Remove Extra Markers
Markerset=Markerset(strlength(Markerset)==4);
%%% Or any new lables. So you can change your lable based on your model. Make sure they are in the same order of C3d file marker's lable %%%
% Newmarkerlable={'LASI','RASI','LPSI','RPSI','LKNE','LTHI','LANK','LTIB','LTOE','LHEE','RKNE','RTHI','RANK','RTIB','RTOE','RHEE'};
MarkerData=data.marker_data.Time;
for i = 1:length(Markerset)
    MarkerData =[MarkerData data.marker_data.Markers.(Markerset{i})*RMatrix];
end
generate_Marker_Trc(Markerset,MarkerData,data.marker_data.Info);
%% Generate GRF 
if ForceFlage
if strcmp(data.fp_data.Info(1).units.Moment_Mx1,'Nmm')
    p_sc = 1000;
%     data.fp_data.Info(:).units.Moment_Mx1 = 'Nm';
else
    p_sc = 1;
end

fp_Number=ForceplateNum;
GRFdata =data.fp_data.Time;
for i = 1:length(fp_Number)
  GRFdata =  [GRFdata [data.fp_data.GRF_data(fp_Number(i)).F*RMatrix]];
  GRFdata =  [GRFdata [data.fp_data.GRF_data(fp_Number(i)).P*RMatrix]/p_sc];
  GRFdata =  [GRFdata [data.fp_data.GRF_data(fp_Number(i)).M*RMatrix]/p_sc];
end
%Separates ground reaction forces onto each foot
    if ForceComFlage
        sGRFdata=SeparateGRF(MarkerData,GRFdata,Markerset);
    else
        sGRFdata=GRFdata;
    end
% data.fp_data.GRF_data.Time= data.fp_data.Time; 
data.fp_data.Info(1).Filename=fname;  
data.fp_data.Info(2).Filename=folder;  
data.fp_data.Info(1).fp_Number=fp_Number;
generate_GRF_Mot(sGRFdata,data.fp_data.Info)
end
end

