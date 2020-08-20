% Add btk library to MATLAB path  -> https://code.google.com/archive/p/b-tk/downloads
clear all
folder =[fileparts(mfilename('fullpath')) '\TestData\'];
fname = 'Functional_Slow.c3d';
q=1;
%% C3D file reading 
data = c3d_getdata([folder fname]);
%% Generate .Trc for Marker set
%%% Giving marker names 
Markerset=fieldnames(data.marker_data.Markers);
%%% Remove Extra Markers
Markerset=Markerset(strlength(Markerset)==4);
%%% Or any new lables. So you can change your lable based on your model. Make sure they are in the same order of C3d file marker's lable %%%
% Newmarkerlable={'LASI','RASI','LPSI','RPSI','LKNE','LTHI','LANK','LTIB','LTOE','LHEE','RKNE','RTHI','RANK','RTIB','RTOE','RHEE'};
%%% To convert C3D Vicon of REAL LAb axis to Opensim Axis XYZ -> ZXY 
MarkerData=data.marker_data.Time;
for i = 1:length(Markerset)
 
   MarkerData = [MarkerData data.marker_data.Markers.(Markerset{i})(:,2) data.marker_data.Markers.(Markerset{i})(:,3) data.marker_data.Markers.(Markerset{i})(:,1)];
  
end
generate_Marker_Trc(Markerset,MarkerData,data.marker_data.Info);
%% Generate GRF 
if strcmp(data.fp_data.Info(1).units.Moment_Mx1,'Nmm')
    p_sc = 1000;
%     data.fp_data.Info(:).units.Moment_Mx1 = 'Nm';
else
    p_sc = 1;
end
%%%  Change axis of data  XYZ -> ZXY Opensim Axis
fp_Number=[3,4];
GRFdata =data.fp_data.Time;
for i = 1:length(fp_Number)
  GRFdata =  [GRFdata [data.fp_data.GRF_data(fp_Number(i)).F(:,2) data.fp_data.GRF_data(fp_Number(i)).F(:,3) data.fp_data.GRF_data(fp_Number(i)).F(:,1)]];
  GRFdata =  [GRFdata [data.fp_data.GRF_data(fp_Number(i)).P(:,2) data.fp_data.GRF_data(fp_Number(i)).P(:,3) data.fp_data.GRF_data(fp_Number(i)).P(:,1)]/p_sc];
  GRFdata =  [GRFdata [data.fp_data.GRF_data(fp_Number(i)).M(:,2) data.fp_data.GRF_data(fp_Number(i)).M(:,3) data.fp_data.GRF_data(fp_Number(i)).M(:,1)]/p_sc];
end
%Separates ground reaction forces onto each foot
sGRFdata=SeparateGRF(MarkerData,GRFdata,Markerset);

% data.fp_data.GRF_data.Time= data.fp_data.Time; 
data.fp_data.Info(1).Filename=fname;  
data.fp_data.Info(2).Filename=folder;  
data.fp_data.Info(1).fp_Number=fp_Number;
generate_GRF_Mot(sGRFdata,data.fp_data.Info)

