%script for checking each EMG .csv file individually

%Select file and import data
[file,path] = uigetfile('*.csv');
wholefile = fullfile(path,file);
EMG=importdata(wholefile,',');

Data=EMG.data;
HData=EMG.colheaders;
[rg,cg]=find(strncmp(HData,'Gn A',4));
%find Knee Goniometer
[rk,ck]=find(strncmp(HData,'Gn K',4));
%find Hip goniometer
[rh,ch]=find(strncmp(HData,'Gn H',4));
%find Biodex
[rb,cb]=find(strncmp(HData,'Biodex',6));
%find EMG
[re,ce]=find(contains(HData,'EMG')&~contains(HData,'RMS'));
er={};
if ~(sum(rg)&sum(rk)&sum(rh)&sum(rb)&sum(re))
er=[er; 'Data is incomplete'];
end

DStime=Data(2,ce(1)-1)-Data(1,ce(1)-1); % desired sampling time
Namedr='placeholder';

for i=1:length(ce)
    g=EMGChecker(Data(:,ce(i)),Namedr,HData{ce(i)},DStime);
    if g==1
        er=[er; 'SNR ' Namedr HData{ce(i)}];
    elseif g==2
        er=[er; 'MA  ' Namedr HData{ce(i)}];
    end
end
disp(er)