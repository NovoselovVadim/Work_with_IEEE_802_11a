%% Global clear
clear, clc, close all

if 1
    load("Seed.mat"), rng(s);
else
    s = rng;
    save Seed.mat s
    rng(s);
end
%% Create transnission signal
cfgSig = 0;                              % 0 - File
                                         % 1 - wlanWaveformGenerator
numRx        =      1;                   % Number of receive antennas
numTx        =      1;
cbw          =      'CBW20';
numTxPkt     =      28;                   % Number of transmitted packets
cfo          =      35e3;                   % Carrier frequency offset (Hz)
delayProfile =      'Model-A';           % TGac channel delay profile
idleTime     =      0; %0, 20e-6     % Idle time before and after each packet
SNR          =      40;

"https://www.mathworks.com/help/releases/R2021b/wlan/gs/wlan-ppdu-structure.html";
cfgNonHT = wlanNonHTConfig( ...
    'ChannelBandwidth',    cbw, ...
    'NumTransmitAntennas', numTx, ...
    'Modulation',          'OFDM', ...
    'MCS',                 3);

fs = wlanSampleRate(cfgNonHT);

txSig = [];
txSigWithGain = [];

for i = 1:numTxPkt
    GainPkt(i) = randi([30 130])/100;
    txPSDU = randi([0 1],cfgNonHT.PSDULength*8,1,'int8');
    txPacket(:,i) = wlanWaveformGenerator(txPSDU,cfgNonHT);
    txSig = [txSig; txPacket(:,i); zeros(round(idleTime*fs),1)];
    txSigWithGain = [txSigWithGain; GainPkt(i)*txPacket(:,i); ...
                     zeros(round(idleTime*fs),1)];
end

if cfgSig
    ha(1) = subplot(3,1,1);
    plot(abs(txSig).^2), grid minor, title("Transmitted signal");
end
%% Create channel
tgacChan = wlanTGacChannel('SampleRate',fs,'ChannelBandwidth',cbw, ...
    'NumTransmitAntennas',numTx,'NumReceiveAntennas',numRx,'DelayProfile',delayProfile);

pfOffset = comm.PhaseFrequencyOffset('SampleRate',fs,'FrequencyOffsetSource','Input port');

rxSigNoNoise = tgacChan([zeros(round(idleTime*fs),cfgNonHT.NumTransmitAntennas); txSigWithGain]);
rxSig = awgn(rxSigNoNoise,SNR);

if cfgSig
    rxSigFreqOffset = pfOffset(rxSig,cfo);
else
    rxSigFreqOffset = readmatrix('D:\NIR\WIFI\Signals\File1_fd20_1_ofdm_only.dat');
%     rxSigFreqOffset = rxSigFreqOffset.*exp(1i*2*pi*75e3/fs*(0:length(rxSigFreqOffset)-1)');
end

if cfgSig == 1
    z = int16(2^13*rxSigFreqOffset);
else
    z = int16(rxSigFreqOffset);
end
ts = timeseries(z);
save 'D://NIR/WIFI/AGC/Simulink_model/Signals/rxSigFreqOffset.mat' ts -v7.3

ha(2) = subplot(3,1,2);
plot(abs(rxSigFreqOffset).^2), grid minor, title("Received signal");
%% Write rxSig to file for fpga
writematrix(real(z),'D:\NIR\WIFI\Signals\WIFI2fpgaI.dat');
writematrix(imag(z),'D:\NIR\WIFI\Signals\WIFI2fpgaQ.dat');
%% Detector
threshold = 0.6;

coef_stf = 2^13*readmatrix('D:\NIR\WIFI\Signals\STF_802_11a.dat');

[PacketStart,Mn] = STFPacketDetector(rxSigFreqOffset,coef_stf,threshold,cbw);

ha(3) = subplot(3,1,3);
plot(Mn), grid minor, title("Decision Statistics"), ylim([0 1.1]);
linkaxes(ha,'x');
%% AGC 
[rxSigAGC, Ku] = AGC(rxSigFreqOffset,coef_stf,PacketStart);

figure
ha1(1) = subplot(3,1,1);
plot(abs(rxSigFreqOffset).^2), grid minor, title("Received signal");
ha1(2) =  subplot(3,1,2);
plot(abs(rxSigAGC).^2), grid minor, title("AGC output");
if cfgSig
    ha1(3) = subplot(3,1,3);
    plot(abs(txSig).^2), grid minor, title("Transmitted signal");
end
linkaxes(ha1,'x');
%% Coarse frequency offset estimation
cfgCorr.minCFO = -400e3;
cfgCorr.maxCFO = 400e3;
cfgCorr.numCorr = 33;

[rxSigCCFO,CfreqOff(:,1)] = CoarseCFOEstimation(rxSigAGC,coef_stf,PacketStart,cfgCorr);

%% Fine frequency offset estimation
[rxSigFCFO,FfreqOff(:,1)] = FineCFOEstimation(rxSigCCFO,PacketStart);

figure
plot(abs(rxSigFCFO).^2), grid minor, title("Signal after frequency tuning");
%%
fpga = readmatrix('D:\NIR\WIFI\Signals\Norm_cross_from_fpga.dat');
figure
plot(fpga/2^11), title("Fpga")
figure
matlab = [zeros(16,1); Mn(1:length(fpga)-16)];
plot(matlab,'*-'), title("Matlab")
figure
plot(fpga/2^11 - matlab);
% clear strt_ind
% strt = readmatrix('D:\NiR\WiFi\Signals\Start_pckt_from_fpga.dat');
% strt_ind(:,1) = find(strt)-47;
% diff = PacketStart(1:length(strt_ind)) - strt_ind;