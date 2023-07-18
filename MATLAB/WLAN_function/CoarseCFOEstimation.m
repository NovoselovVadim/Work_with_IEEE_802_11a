function [SigCFO,offset] = CoarseCFOEstimation(Sig,coef,PacketStart,cfgCorr,Off_ena,chanBW)

% Validate input signal
if isempty(Sig)
    return;
end

% Validate number of arguments
narginchk(1,6);
nargoutchk(1,2);

if nargin == 2
    PacketStart = 1;
    cfgCorr.minCFO = -400e3;
    cfgCorr.maxCFO = 400e3;
    cfgCorr.numCorr = 33;
    Off_ena = 'true';
    chanBW = 'CBW20';
elseif nargin == 3
    cfgCorr.minCFO = -400e3;
    cfgCorr.maxCFO = 400e3;
    cfgCorr.numCorr = 33;
    Off_ena = 'true';
    chanBW = 'CBW20';
elseif nargin == 4
    Off_ena = 'true';
    chanBW = 'CBW20';
elseif nargin == 5
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

% Coarse CFO estimate
fs = wlan.internal.cbwStr2Num(chanBW)*1e6;
Fk(:,1) = linspace(cfgCorr.minCFO,cfgCorr.maxCFO,cfgCorr.numCorr);
Wk = 2*pi*Fk/fs;

i = 1;
k = 1;
offset = 0;
SigCFO = Sig;
% R(correlator,packet)
while (i <= length(Sig))
    if i == PacketStart(k) + 2*symbolLength
        for j = 1:cfgCorr.numCorr
            coefWithOffset = coef(2*symbolLength+1:10*symbolLength).*...
                             exp(1i*Wk(j)*(2*symbolLength+1:10*symbolLength)');
            R(j,k) = sum(conj(Sig(i:i+8*symbolLength-1)).*coefWithOffset);
        end

        [~,indW(k)] = max(R(:,k));

        startPkt = PacketStart(k);
        if k ~= length(PacketStart)
            endPkt = PacketStart(k+1) - 1;
        else
            endPkt = length(Sig);
        end

        offset(end+1) = Fk(indW(k));

        if Off_ena
            SigCFO(startPkt:endPkt) = Sig(startPkt:endPkt).*exp(-1i*Wk(indW(k))*(startPkt:endPkt)');
        end

        i = endPkt + 1;
        k = k + 1;
    else
        i = i + 1;
    end
end
offset(1) = [];

end