function [index,pingOut] = inBuffer(sBuffer, id, loc)
% tic;

index = 0;
pingOut = '0';
if size(sBuffer,1)>0
    for i = 1:size(sBuffer,1)
        if sBuffer(i,1:2) == id
            if sBuffer(i,3:4) == loc
                index = i;
                pingOut = sBuffer(i,:);
                break;
            end
        end      
    end
end

% t = toc;
% assignin('base','inBufferTime', t); 
    
