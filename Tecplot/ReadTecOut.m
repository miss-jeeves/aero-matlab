%function [title, info, data]=ReadTecOut(filename)
% This is a function to read data from an output file generated by tecplot.
% It is not to general, but can know I, J, K, and the number of variables,
% NV.

file = fopen('data1.tec','r');
%file = fopen(filename,'r');

%% Looking for TITLE
s = '';
while (isempty(strfind(s,'TITLE')))
    s = fgetl(file); % read a line from the text and assings it to s.
end
a = find(s=='"'); % looking for the presence of double quote char.
title = s((a(1)+1):(a(2)-1));

%% Looking for number of VARIABLES
s = '';
while (isempty(strfind(s,'VARIABLES')))
    s = fgetl(file); % read a line from the text and assings it to s.
end
a = find(s=='"'); % looking for the presence of double quote char.
NV = length(a)/2; % NV contains the number of variables found since each 
                  % variable name is within quotes (e.g. "x"), number of
                  % variables = number of quotes/2

%% Looking for ZONE variables
a=[];
while (isempty(strfind(s,'ZONE')))
    NV=NV+length(a)/2;
    s = fgetl(file);
    a = find(s == '"');
end

%% Find the I, J, K values
s = fgetl(file); % next line

% I
a = strfind(s,'I =');
sl=''; c=''; i=a+2;
while (c~=',')
    c = s(i);
    sl = strcat(sl,c);
    i = i+1;
end
I = str2num(sl);

% J
a = strfind(s,'J =');
sl=''; c=''; i=a+2;
while (c~=',')
    c = s(i);
    sl = strcat(sl,c);
    i = i+1;
end
J = str2num(sl);

% K
a = strfind(s,'K =');
sl=''; c=''; i=a+2;
while (c~=',')
    c = s(i);
    sl = strcat(sl,c);
    i = i+1;
end
K = str2num(sl);

% K
a = strfind(s,'F =');
F = s((a+4):(a+10));

if (strcmp(F,'BLOCK')) % if F = BLOCK
    disp('No facility yet to process block format.');
    return;
end

info = [I J K F];

s = fgetl(f); %skipping the line that cotains DT=(single,single)

%% Read Data
LineNo = 0;     % Line counter
while (~feof(file))
    s = fgetl(file);
    LineNo = LineNo + 1;
    a = find(s==' '); % finding blanks
    L = length(a);
    b = a(find((a(2:L)-a(1:(L-1)))>1)+1);
    % finds only non-consecutive blank locations which gives only the
    % actual separators
    L = length(b);
    if L>0
        b = [1 b length(s)];
        for i = 1:(L+1)
            N(LineNo,i)=str2num( s(b(i):b(i+1)) );
        end
    end
end

% Now all the data is in 'N'

data = zeros(NV,I,J,K);
LineNo=0;
for k = 1:K
    for j = 1:J
        for i = 1:I
            LineNo = LineNo+1;
            for v = 1:NV
                data(v,i,j,k) = N(LineNo,v);
            end
        end
    end
end

% Data is now trasnfered to 'data'
    