function [SigAGC,Ku] = AGC(Sig,coef,PacketStart,chanBW)

% Validate input signal
if isempty(Sig)
    return;
end

% Validate number of arguments
narginchk(1,4);
nargoutchk(1,2);

% Validate Channel Bandwidth
if nargin == 2
    PacketStart = 1;
    chanBW = 'CBW20';
elseif nargin == 3
    chanBW = 'CBW20';
end
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

% Validate input signal
if isempty(PacketStart)
    return;
end

% AGC
E_nom = sum(abs(coef(1:3*symbolLength)).^2);
Ku = 1;

i = 1;
k = 1;
while (i < length(Sig))
    if i < PacketStart(1)
        E_noise = sum(abs(Sig(i:i+3*symbolLength-1)).^2);
        Ku = E_nom/E_noise/16;
        SigAGC(i,1) = sqrt(Ku)*Sig(i,1);
        i = i + 1;
    else
        if i == PacketStart(k) + 2*symbolLength
            E_rx = sum(abs(Sig(i:i+3*symbolLength-1)).^2);
            Ku(end+1) = E_nom/E_rx(end);

            startPkt = PacketStart(k);
            if k ~= length(PacketStart)
                endPkt = PacketStart(k+1) - 1;
                k = k + 1;
            else
                endPkt = length(Sig);
            end

            SigAGC(startPkt:endPkt,1) = sqrt(Ku(end))*Sig(startPkt:endPkt,1);

            i = endPkt + 1;
        else
            i = i + 1;
        end
    end
end

end