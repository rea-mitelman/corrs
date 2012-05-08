function [evPos, flg]=returnEvPosition(events, targetNum, ev)

switch ev
    case 'cue'
        num=hex2dec('20')+targetNum-1;        
    case 'go'
        num=hex2dec('30')+targetNum-1;
    case 'to'
        num=16*targetNum+10;
    case 'ho'
        num=16*targetNum+11;
    case 'hof'
        num=16*targetNum+12;
    case 'tof'
        num=16*targetNum+13;
    case 'b2c'
        num=64;
    case 'back2center',
        num=hex2dec('40');
    otherwise
        error('inconsistent event name')
end
flg = 1;
evPos=find(events==num);
if isempty(evPos),
    flg =0;
end