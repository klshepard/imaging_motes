function [compressed] = logcompression(a,bmode)
%logcompression Ultrasound log compression of a signal
%   a= compression factor (scalar)
%   bmode = uncompressed b-mode signal
compressed=log10(1 +a*bmode) ./ log10(1 + a);
end

