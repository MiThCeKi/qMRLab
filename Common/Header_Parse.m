%MATLAB header parser function
%----------------------------------------------------------------
%Written by: Gabriel BErestovoy
%----------------------------------------------------------------
% classdef Header_Parse
%     properties
%         assumption = '';
%         input = '';
%         output = '';
%         protocol = '';
%         option = '';
%         usage = '';
%         author = '';
%         references = '';
%         head = '';
%     end
% end

function Header_Parse(file)
    cdmfile(file)
    fields = {'Assumptions','Inputs','Outputs','Protocol','Option','Command line usage','Author','Reference'};
    reading = '';

    filepath = which(file);
    fID = fopen(filepath);
    line = fgets(fID);

    assumption = strings;
    input =strings;
    output = strings;
    protocol = strings;
    option = strings;
    usage = strings;
    author = strings;
    references = strings;
    head = strings;

    k = 1;
    cat = 0;
    finished = 0;
    while ~feof(fID) & ~finished
        if strcmp(reading,fields(8)) & isempty(strfind(line,'%'))
            finished = 1;
        end
        if strcmp(line(1), '%') & ~strcmp(strrep(strrep(line,char(10),''),char(13),''),'%')
            line = strrep(line,'%','');
            for i = 1:length(fields)
                finds = strfind(line,fields(i))
                if length(finds) ~= 0
                    if finds(1)== 2
                        reading = fields(i);
                        k=1;
                        cat=0;
                    end
                end
            end
            if strcmp(reading, '')
                head(k,1) = strip(line);
                k= k + 1
            elseif strcmp(reading,fields(1))
                %Get the Assumptions
                if strfind(line, fields(1)) & startsWith(strip(line,' '),fields(1))
                      ;
                elseif line(4) ~= ' '
                    assumption(k) = line;
                    k = k + 1;
                elseif line(6) ~= ' '
                    assumption(k-1)= assumption(k-1)+line;
                end    
            elseif strcmp(reading,fields(2))
                %Get the inputs
                if strfind(line, fields(2)) & startsWith(strip(line,' '),fields(2))
                    ;
                elseif line(4) ~= ' '
                    input(k,1) = strip(extractBetween(line,4,23),' ');
                    if length(line) > 23
                        input(k,2) = strip(extractAfter(line,23),' ');
                    end
                    k = k + 1;
                elseif line(24) ~= ' '
                    input(k-1,2) = input(k-1,2) + strip(line, ' ');
                end  
            elseif strcmp(reading, fields(3))
                %Get the outputs 
                if strfind(line, fields(3)) & startsWith(strip(line,' '),fields(3))
                    ;
                elseif line(4) ~= ' '
                    output(k,1) = strip(extractBetween(line,4,23),' ');
                    if length(line) > 23
                        output(k,2) = strip(extractAfter(line,23),' ');
                    end
                    k = k + 1;
                elseif line(26) ~= ' '
                    output(k-1,2) = output(k-1,2) + strip(line, ' ');
                end  
            elseif strcmp(reading,fields(4))
                %Get the protocols
                if strfind(line, fields(4)) & startsWith(strip(line,' '),fields(4))
                    ;
                elseif line(4) ~= ' '
                    protocol(k,1) = strip(extractBetween(line,4,23), ' ');
                    if length(line) > 23
                        protocol(k,2) = strip(extractAfter(line,23), ' ');
                    end
                    k = k + 1;
                    cat = 1;
                elseif line(6) ~= ' '
                    protocol(k,3) = strip(extractBetween(line,6,23), ' ');
                    if length(line) > 23
                        protocol(k,4) = strip(extractAfter(line,23), ' ');
                    end
                    k = k + 1;
                    cat = 0;
                elseif line(26) ~= ' ' & cat == 1
                    protocol(k-1,2) = protocol(k-1,2) + strip(line, ' ');
                elseif line(26) ~= ' ' & cat == 0
                    protocol(k-1,4) = protocol(k-1,4) + strip(line, ' ');
                end
            elseif strcmp(reading,fields(5))
                %Get the options
                if strfind(line, fields(5)) & startsWith(strip(line,' '),fields(5))
                    ;
                elseif line(4) ~= ' '
                    len = length(line)
                    if len > 22
                        option(k,1) = strip(extractBetween(line,4,24), ' ');
                    else
                        option(k,1) = strip(line);
                    end
                    if length(line) > 23
                        option(k,2) = strip(extractAfter(line,24), ' ');
                    end
                    k = k + 1;
                    cat = 1;
                elseif line(6) ~= ' '
                    option(k,3) = strip(extractBetween(line,6,26), ' ');
                    if length(line) > 23
                        option(k,4) = strip(extractAfter(line,26), ' ');
                    end
                    k = k + 1;
                    cat = 0;
                elseif (line(29) ~= ' ' || line(30))& cat == 1
                    option(k-1,2) = option(k-1,2) + strip(line, ' ');
                elseif (line(29) ~= ' ' || line(30)) & cat == 0
                    option(k-1,4) = option(k-1,4) + strip(line, ' ');
                end
            elseif strcmp(reading,fields(6))
                %Get the usage
                if strfind(line, fields(6)) & startsWith(strip(line,' '),fields(6))
                else
                    usage(k,1)=strip(line);
                    k = k + 1;
                end
            elseif strcmp(reading,fields(7))
                %Get the author
                author(k,1)=strip(line);
                k = k + 1;
            elseif strcmp(reading,fields(8))
                %Get the references
                if strfind(line, fields(8)) & startsWith(strip(line,' '),fields(6))
                else
                    references(k,1) = strip(line);
                    k = k + 1;
                end
            end
        end
        line = fgets(fID);
    end
end