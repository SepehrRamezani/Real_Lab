function generate_GRF_Mot(data ,Info)

FName = strrep(Info(1).Filename,'.c3d','_grf.mot');
force_header = 'time';
force_format = '%20.6f\t';
force_Header_format='%s\t';
data(logical(isnan(data))) = 0;
fid_2 = fopen([Info(2).Filename FName],'w');
[r,c]=size(data);
fprintf(fid_2,'%s\n',FName);
fprintf(fid_2,'version=%d\n',1);
fprintf(fid_2,'nRows=%d\n', r);  % total # of datacolumns
fprintf(fid_2,'nColumns=%d\n',c); % number of datarows
fprintf(fid_2,'inDegrees=%s\n','yes'); 
fprintf(fid_2,'endheader\n');

for i = 1:length(Info(1).fp_Number)
    
   force_header = [force_header [num2str(i)+"_ground_force_vx" ] [num2str(i)+"_ground_force_vy" ] [num2str(i)+"_ground_force_vz"]...
                  [num2str(i)+"_ground_force_px" ] [num2str(i)+"_ground_force_py" ] [num2str(i)+"_ground_force_pz" ...
       ] [num2str(i)+"_ground_torque_x" ] [num2str(i)+"_ground_torque_y" ] [num2str(i)+"_ground_torque_z"]];
   force_format = [force_format '%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t%20.6f\t'];
   force_Header_format=[force_Header_format '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t'];  
end

fprintf(fid_2,force_Header_format,force_header);
fprintf(fid_2,'\n');
fprintf(fid_2,[force_format '\n'],data');

fclose(fid_2);


