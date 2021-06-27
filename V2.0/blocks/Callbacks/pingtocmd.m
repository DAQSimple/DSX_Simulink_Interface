function [id, loc, sign, val, ret] = pingtocmd(ping)
%{
Converts an input number or string or char or something, converts to char,
then outputs each value seperately.

%}
%% If it's not a char -> char
if  ~ischar(ping)
    ping = char(ping);
end 
%% P(arse)
id = ping(1:2);
loc = ping(3:4);
sign = ping(5);
val = ping(6:9);
ret = ping(10);   