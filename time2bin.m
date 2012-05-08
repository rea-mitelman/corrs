function binString=time2bin(t,duration)

% time2bin gets a vector t of rounded times (msec) and outputs a binary {01} vector
%of length=duration with ones in indexes given by t and zeros elsewhere.

if nargin==1
    maxTime=max(t);
    binString(1:maxTime)=logical(zeros);
    binString(t)=logical(ones);
elseif nargin==2
    binString(1:duration)=logical(zeros);
    binString(round(t))=logical(ones);
    binString=binString(1:duration);
end