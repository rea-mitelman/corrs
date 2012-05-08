function targetNum=returnTarget(events)

% i=find(ismember(events,hex2dec(['20';'21';'22';'23';'24';'25';'26';'27'])));
% targetNum=events(i)-31;

ii=ismember(events,hex2dec(['20';'21';'22';'23';'24';'25';'26';'27']));
targetNum=events(ii)-31;