function makefile (folder,F_fnames,Title,Titledata,Dataheader,Datadata,Resulotion,delimiterIn)
% Resulotion number of digit after zero
           fid=fopen(fullfile(folder,F_fnames), "w");
            if fid < 0
                fprintf('\nERROR: %s could not be opened for writing...\n\n', F_fnames);
            return
            end
            [r,c]=size(Datadata);
            ft=[];
            for f=1:c
                ft=[ft '%.' num2str(Resulotion) 'f' delimiterIn];
            end
            fprintf(fid,[char(F_fnames) Title],Titledata);
            fprintf(fid, '\n');
            for k=1:length(Dataheader)
            fprintf(fid,[char(Dataheader(k)) delimiterIn]);
            end
            fprintf(fid, '\n');
                for i = 1:r
                    fprintf(fid,ft,Datadata(i,:));
                    fprintf(fid, '\n');
                end
            fclose(fid);
            fprintf('Saved %s\n', fullfile(folder,F_fnames))
end