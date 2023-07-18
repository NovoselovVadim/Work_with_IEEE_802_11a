function [SigCFO,offset] = FineCFOEstimation(Sig,PacketStart,Off_ena,chanBW)


% Validate input signal
if isempty(Sig)
    return;
end

% Validate number of arguments
narginchk(1,4);
nargoutchk(1,2);

if nargin == 1
    PacketStart = 1;
    Off_ena = 'true';
    chanBW = 'CBW20';
elseif nargin == 2
    Off_ena = 'true';
    chanBW = 'CBW20';
elseif nargin == 3
    Off_ena = 'true';
    chanBW = 'CBW20';
elseif nargin == 4
    chanBW = 'CBW20';
end

% Validate Channel Bandwidth
Td = 0.8e-6; % Time period of a short training symbol for 20MHz
                
switch chanBW
    case {'CBW5', 'CBW10', 'CBW20'}
        symbolLength = Td/(1/20e6); % In samples
    case 'CBW40'
        symbolLength = Td/(1/40e6);
    case {'CBW80'}
        symbolLength = Td/(1/80e6);
    case {'CBW160'}
        symbolLength = Td/(1/160e6);
    otherwise % CBW320
        symbolLength = Td/(1/320e6);
end

% Fine CFO estimate
fs = wlan.internal.cbwStr2Num(chanBW)*1e6;

i = 1;
k = 1;
offset = 0;
SigCFO = Sig;

while (i <= length(Sig))
    if i == PacketStart(k) + 10*symbolLength
        x = Sig(i+32:i+32+8*symbolLength-1);

        cx = x(1:end-64);
        sx = x(64+1:end);

        R(:,k) = (cx)'*sx;

        offset(end+1) = angle(sum(R(:,k)))/(2*pi)*fs/64;

        startPkt = PacketStart(k);
        if k ~= length(PacketStart)
            endPkt = PacketStart(k+1) - 1;
        else
            endPkt = length(Sig);
        end

        if Off_ena
            SigCFO(startPkt:endPkt) = ...
                Sig(startPkt:endPkt).*exp(-1i*2*pi*offset(end)/fs*(startPkt:endPkt)');
        end

        i = endPkt + 1;
        k = k + 1;
    else
        i = i + 1;
    end
end
offset(1) = [];

end