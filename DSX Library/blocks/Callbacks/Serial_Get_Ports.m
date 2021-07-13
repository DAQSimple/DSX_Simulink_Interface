function [ports,numports] = Serial_Get_Ports()
    ports = serialportlist;
    numports= size(ports,2);
end