%MATLAB header parser class
%
%This class generates a header object from the class header containing
%every information in the header of a file that respects the convention.
%
% Properties
%   assumption          Assumptions of the model
%   input               Input arguments of the model
%   output              Ouput of the functions of the model
%   protocol            Protocol used in the model
%   option              Options that can be changed in the model
%   usage               Usage examples for the model
%   author              Author for the model
%   references          References of the model
%   head                First of the model
%
% Methods
%   header              Constructor of the class header
%   header_parse        Header parser that takes the file name as an
%                         argument and separates every secton of the file 
%                         and saves the different informations 
%
% Author: Gabriel Berestovoy
% References: see other

classdef header
    properties
        assumption = strings;
        input = strings;
        output = strings;
        protocol = strings;
        option = strings;
        usage = strings;
        author = strings;
        references = strings;
        head = strings;
    end
    methods (Static)
        function obj = header(head,ass,in,out,prot,opt,us,aut,ref)
            obj.head = head;
            obj.assumption = ass;
            obj.input = in;
            obj.output = out;
            obj.protocol = prot;
            obj.option = opt;
            obj.usage = us;
            obj.author = aut;
            obj.references = ref;
        end
        function h = header_parse(file)
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
            while ~feof(fID) && ~finished
                if strcmpi(reading,fields(8)) && length(strfind(line,'%')) == 0
                    finished = 1;
                end
                if strcmpi(line(1), '%') && ~strcmpi(strrep(strrep(line,char(10),''),char(13),''),'%')
                    line = strrep(line,'%','');
                    for i = 1:length(fields)
                        finds = strfind(lower(line),lower(fields(i)));
                        if length(finds) ~= 0
                            if finds(1)<= 13
                                reading = fields(i);
                                k=1;
                                cat=0;
                            end
                        end
                    end
                    if strcmpi(reading, '')
                        head(k,1) = strtrim(line);
                        k = k + 1;
                    elseif strcmpi(reading,fields(1))
                        %Get the Assumptions
                        if length(strfind(lower(line), lower(fields(1)))) ~= 0 && strncmpi(strtrim(line),fields(1),length(fields(1)));
                        elseif line(4) ~= ' '
                            assumption(k,1) = line;
                            k = k + 1;
                        elseif line(6) ~= ' '
                            assumption(k-1)= assumption(k-1)+line;
                        end    
                    elseif strcmpi(reading,fields(2))
                        %Get the inputs
                        if length(strfind(line, fields(2))) ~= 0 && strncmpi(strtrim(line),fields(2),length(fields(2)));
                        elseif line(4) ~= ' '
                            input(k,1) = strtrim(extractBetween(line,4,23));
                            if length(line) > 23
                                input(k,2) = strtrim(extractAfter(line,23));
                            end
                            k = k + 1;
                        elseif line(24) ~= ' '
                            input(k-1,2) = input(k-1,2) + strtrim(line);
                        end  
                    elseif strcmpi(reading, fields(3))
                        %Get the outputs 
                        if length(strfind(line, fields(3))) ~= 0 && strncmpi(strtrim(line),fields(3),length(fields(3)));
                        elseif line(4) ~= ' '
                            output(k,1) = strtrim(extractBetween(line,4,23));
                            if length(line) > 23
                                output(k,2) = strtrim(extractAfter(line,23));
                            end
                            k = k + 1;
                        elseif line(26) ~= ' '
                            output(k-1,2) = output(k-1,2) + strtrim(line);
                        end  
                    elseif strcmpi(reading,fields(4))
                        %Get the protocols
                        [startindex endindex] = regexp(line,' ');
                        index = 1;
                        i = 1;
                        %Check the index at which the description starts
                        while i <= length(endindex) && index == 1
                            if endindex(i) >= 20
                                index = endindex(i);
                            end
                            i = i + 1;
                        end
                        if index == 1
                            index = 23;
                        end
                        %
                        if length(strfind(line, fields(4))) ~= 0 && strncmpi(strtrim(line),fields(4),length(fields(4)));
                        elseif line(4) ~= ' '
                            if length(line) >= 23
                                protocol(k,1) = strtrim(extractBetween(line,4,index));
                            else
                                protocol(k,1) = strtrim(line);
                            end
                            if length(line) > 23
                                protocol(k,2) = strtrim(extractAfter(line,index));
                            end
                            k = k + 1;
                            cat = 1;
                        elseif line(6) ~= ' '
                            protocol(k,3) = strtrim(extractBetween(line,6,index));
                            if length(line) > 23
                                protocol(k,4) = strtrim(extractAfter(line,index));
                            end
                            k = k + 1;
                            cat = 0;
                        elseif line(26) ~= ' ' && cat == 1
                            protocol(k-1,2) = protocol(k-1,2) +char(10)+char(13)+ strtrim(line);
                        elseif line(26) ~= ' ' && cat == 0
                            protocol(k-1,4) = protocol(k-1,4) +char(10)+char(13)+ strtrim(line);
                        end
                    elseif strcmpi(reading,fields(5))
                        %Get the options
                        [startindex endindex] = regexp(line,' ');
                        index = 1;
                        i = 1;
                        %Check the index at which the description starts
                        while i <= length(endindex) && index == 1
                            if endindex(i) >= 20
                                index = endindex(i);
                            end
                            i = i + 1;
                        end
                        if index == 1
                            index = 23;
                        end
                        %
                        if length(strfind(line, fields(5))) ~= 0 && strncmpi(strtrim(line),fields(5),length(fields(5)));
                        elseif line(4) ~= ' '
                            len = length(line);
                            if len > 20
                                option(k,1) = strtrim(extractBetween(line,4,index));
                            else
                                option(k,1) = strtrim(line);
                            end
                            if length(line) > 21
                                option(k,2) = strtrim(extractAfter(line,index));
                            end
                            k = k + 1;
                            cat = 1;
                        elseif line(6) ~= ' '
                            option(k,3) = strtrim(extractBetween(line,6,index));
                            if length(line) > 23
                                option(k,4) = strtrim(extractAfter(line,index));
                            end
                            k = k + 1;
                            cat = 0;
                        elseif (line(29) ~= ' ' || line(30)) && cat == 1
                            option(k-1,2) = option(k-1,2) +char(10)+char(13)+ strtrim(line);
                        elseif (line(29) ~= ' ' || line(30)) && cat == 0
                            option(k-1,4) = option(k-1,4) +char(10)+char(13)+ strtrim(line);
                        end
                    elseif strcmpi(reading,fields(6))
                        %Get the usage
                        if length(strfind(line, fields(6))) ~= 0 && strncmpi(strtrim(line),fields(6),length(fields(6)));
                        else
                            usage(k,1)=strtrim(line);
                            k = k + 1;
                        end
                    elseif strcmpi(reading,fields(7))
                        %Get the author
                        author(k,1)=strtrim(line);
                        k = k + 1;
                    elseif strcmpi(reading,fields(8))
                        %Get the references
                        if length(strfind(line, fields(8))) ~= 0 && strncmpi(strtrim(line),fields(6),length(fields(6)));
                        else
                            references(k,1) = strtrim(line);
                            k = k + 1;
                        end
                    end
                end
                line = fgets(fID);
            end
            h = header(head,assumption,input,output,protocol,option,usage,author,references);
        end
    end
end

