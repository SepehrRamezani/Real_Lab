function Process_Data(fname,folder,ForceFlage,ForceComFlage,ForceplateNum)
% This function requires the installation of the BTK (Biomechanical
% Toolkit) Matlab wrapper which must be added to the Matlab path. Please
% ensure you install the correct wrapper for your operating platform (ie.
% Windows, Mac etc) - please see http://code.google.com/p/b-tk/ for more
% information and cite appropriately - 
% further info at http://b-tk.googlecode.com/svn/doc/Matlab/0.1/index.html
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
Markerset=Markerset(~contains(Markerset,'C_'));
%%% Or any new lables. So you can change your lable based on your model. Make sure they are in the same order of C3d file marker's lable %%%
% Newmarkerlable={'LASI','RASI','LPSI','RPSI','LKNE','LTHI','LANK','LTIB','LTOE','LHEE','RKNE','RTHI','RANK','RTIB','RTOE','RHEE'};
MarkerData=data.marker_data.Time;
for i = 1:length(Markerset)
    MarkerData =[MarkerData data.marker_data.Markers.(Markerset{i})*RMatrix];
end
generate_Marker_Trc(Markerset,MarkerData,data.marker_data.Info);
%% Generate GRF 
%%% Getting Force plate information
for i=1:length(ForceplateNum)
%%% ForcePlate will nclude 4 corners of each force plate, First point is top left and it goes CW. 
ForcePlate{i}=data.fp_data.FP_data(ForceplateNum(i)).corners'*RMatrix;
end
%%%
if ~ForceFlage
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
switch ForceComFlage
    case 2
        sGRFdata=TM_SeparateGRF(MarkerData,GRFdata,Markerset);
        data.fp_data.Info(1).fp_Number=[4,5];
    case 1
        sGRFdata=OG_SeparateGRF(MarkerData,GRFdata,Markerset,ForceplateNum,ForcePlate);
        data.fp_data.Info(1).fp_Number=[1,2];
    case 0
        sGRFdata=GRFdata;
        data.fp_data.Info(1).fp_Number=fp_Number;
end
% data.fp_data.GRF_data.Time= data.fp_data.Time; 
data.fp_data.Info(1).Filename=fname;  
data.fp_data.Info(2).Filename=folder;  
generate_GRF_Mot(sGRFdata,data.fp_data.Info)
end
end

