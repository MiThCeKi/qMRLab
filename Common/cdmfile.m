%cdmfile
%
%Move the user in the correct folder to run without bugs the script in the
%Matlab file
%------------------------------------------------------------------------
%Written by: Gabriel Berestovoy
%------------------------------------------------------------------------

function cdmfile(file)
    [pathstr,fname,ext]=fileparts(which(file));
    cd (pathstr);
end