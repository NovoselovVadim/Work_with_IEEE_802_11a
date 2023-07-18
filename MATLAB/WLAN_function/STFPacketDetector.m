function [PacketStart,Mn] = STFPacketDetector(Sig,coef,threshold,chanBW)

% Validate input signal
if isempty(Sig)
    return;
end

% Validate number of arguments
narginchk(2,4);
nargoutchk(1,2);

if nargin == 2
    threshold = 0.5;
    chanBW = 'CBW20';
elseif nargin == 3
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

% Cross-Correlation
N = symbolLength; % Window width
c = zeros(length(Sig),1);
p = zeros(length(Sig),1);
Mn = zeros(length(Sig),1);

for k=1:length(Sig)-N
    r_nk = Sig(k:k+N-1);

    c(k) = sum(conj(r_nk).*coef(1:symbolLength));
    p(k) = sum(abs(r_nk).^2)*sum(abs(coef(1:symbolLength)).^2);
    Mn(k) = abs(c(k))^2/p(k);
end

% Search packet start
PacketStart = [];
distance = zeros(3,1);
PeakCount = 0;

i = 1;
while (i <= length(Mn))
    if Mn(i) > threshold
        distance = [distance(end-1:end); i];
        PeakCount = PeakCount + 1;
    end

    if (PeakCount > 0) && (i-distance(3)>10*symbolLength)
        PeakCount = 0;
    end

    if (PeakCount == 3) && (distance(2)-distance(1)>10)  && (distance(3)-distance(2)>10) 
        PeakCount = 0;
        PacketStart = [PacketStart; distance(1)];
        i = i + 8*symbolLength;
    else
        i = i + 1;
    end
end

end