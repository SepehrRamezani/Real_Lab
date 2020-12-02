clear all;
% close all;
clc;
 % Some times there is no need to import raw data because all data will
 % save in FinalDatafor first time. readflage=1 means import files again.
readflage= 0;
% folder=uigetdir(); % get Data directory 
folder='C:\MyCloud\OneDriveUcf\Real\Simulation\Source\T001\Data';
fname = 'P005_T001_RKnee_';
Terials1=["Ex","Fl"];
Terials2=["IsoK60","IsoK120","IsoK180","IsoK240","IsoM10","IsoM30","IsoM60","IsoM90"];
% Terials1=["Fl"];
% Terials2=["IsoK60"];
Fdata=[];
Gdata=[0];
k=0;
DStime=0.01; % desierd sampling time 
%
if readflage 
    for T1=1:length(Terials1)
        for T2=1:length(Terials2)
            
            Namedr=append(Terials1(T1),'_',Terials2(T2));
            Datadr=append(folder,"\",fname,Terials1(T1),"_",Terials2(T2),".csv");
            data=importdata(Datadr);
            for ii=2:2:length(data.textdata)
                kk=1;
                tflage=0;
                ww=0;
                for jj=1:length(data.data)%# of data points in a given trial
                    if ~isnan(data.data(jj,ii))&&data.data(jj,ii)~=0
                        kk=jj;  %finding zero data at the end of each chanel
                        tflage=1;                        
                    elseif tflage==0 
                        ww=jj;  %finding zero data at the begining 
                    end
                end

                if ii==2
                    ts=data.data(ww+1,1); % first time of first chanel to set as final time for every other channel.
                    te=data.data(kk,1); % final time of first chanel to set as final time for every other channel.
                end 
                y=interp1(data.data(ww+1:kk,ii-1),data.data(ww+1:kk,ii),[ts:DStime:te],'linear','extrap'); %Interpolates data to match sampling time to desierd sampling time 
                
                b=y';
%                 ends(ii)=length(b);
                if (size(Gdata(:,1)) == 1) %recombines data into a matrix padded with NaN
                    Gdata = [[data.data(ww+1,1):DStime:data.data(kk,1)]' b];
                else 
                    Gdata = [Gdata b];
                end
                
            end
            FinalData.(Namedr).data=Gdata;
            FinalData.(Namedr).colheaders=["time" data.textdata(2:2:end)];
            clear Gdata
            Gdata=[0];

        end
    end

save ([folder '\FinalData.mat'],'FinalData');

end
%%
load ([folder '\FinalData.mat']);
Dataheadermotion=['time\tpelvis_tilt\tpelvis_tx\tpelvis_ty\thip_flexion_r\tknee_angle_r\tankle_angle_r'];
Dataheaderforce=['time\treaction_force_vx\treaction_force_vy\treaction_force_vz\treaction_force_px\treaction_force_py\treaction_force_pz\treaction_torque_x\treaction_torque_y\treaction_torque_z'];
DataheaderEMG=['time\t'];
for T1=1:length(Terials1)
    for T2=1:length(Terials2)        
        Namedr=append(Terials1(T1),"_",Terials2(T2));
        Data=FinalData.(Namedr).data;
        HData=FinalData.(Namedr).colheaders;
        [rg,cg]=find(strncmp(HData,'Gn',2));
        %find Knee Goniometer
        [rk,ck]=find(strncmp(HData,'Gn K',4));
        %find Hip goniometer
        [rh,ch]=find(strncmp(HData,'Gn H',4));
        %find Biodex
        [rb,cb]=find(strncmp(HData,'Biodex',6));
        %find EMG
        [re,ce]=find(contains(HData,'EMG')&~contains(HData,'RMS'));
        [r,c]=size(Data);
%% Process on Motion Data
        Gon=Data(:,cg);
        CalGon=-0.0058.*Gon.^2-1.62.*Gon+1.14;  % Goniometer calibration, This equation would change base on ne calibration curve
        CalGon(CalGon<0)=0;
        Data(:,cg)=CalGon.*pi()./180;

%% Save Motion
            delimiterIn='\t';
            F_fnames=[fname,char(Namedr),'_Motion.mot'];
            Title='\nversion=1\nnRows=%d\nnColumns=%d\nInDegrees=no\nendheader\n';
            Datadata=[1,0,0.055,1.059,1,1,0].*ones(r,7);
            Datadata(:,[1,5,6])=[Data(:,1),Data(:,ch(2)),Data(:,ck(2))];
            Titledata=[r,length(Datadata(1,:))];
%             makefile(folder,F_fnames,Title,Titledata,Dataheadermotion,Datadata,5,delimiterIn);
%% Process Force
            A=[];
            x=1*Data(:,cb(1)); %data of a trial
            Mb=-1.*(141.81.*x-25.047);
%% Save Force
            F_fnames=[fname,char(Namedr),'_Torque.mot'];
            Datadata=[Data(:,1),zeros(r,8),Mb];
            Titledata=[r,length(Datadata(1,:))];
%             makefile(folder,F_fnames,Title,Titledata,Dataheaderforce,Datadata,5,delimiterIn);
           
%% Process on EMG
        EMGChecker(Data(:,ce(1)),HData(ce(1)));
        EMGfilt = EMGFilter(Data(:,ce),0.5,5,4,1/DStime);
%% Save EMG
         delimiterIn=',';
         F_fnames=[fname,char(Namedr),'_EMG.csv'];
         DataheaderEMG=['time' delimiterIn];
         for hh=1:length(ce)
             HD=char(HData(ce(hh)));
             switch HD([1:3])
                 case 'LLH'
                     HData(ce(hh))='RBICF';
                 case 'LRF'
                     HData(ce(hh))='RRECF';
                 case 'LVL'
                     HData(ce(hh))='RVASL';
                 case 'LVM'
                     HData(ce(hh))='RVASM';
                 case 'LMH'
                     HData(ce(hh))='RSEMT';
                 case 'LMG'
                     HData(ce(hh))='RMGAS';
             end
             DataheaderEMG=[DataheaderEMG char(HData(ce(hh))) delimiterIn];
         end
         Datadata=[Data(:,1),EMGfilt];
         Titledata=[r,length(Datadata(1,:))];
         makefile (folder,F_fnames,Title,Titledata,DataheaderEMG,Datadata,8,delimiterIn);
    end
end

