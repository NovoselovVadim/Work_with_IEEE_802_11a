if 0
    fname = '/home_osuse/alex/Documents/work/mtlab/ofdm/ex1/File1_fd20_1_ofdm_only.pcm';
    samp = read_complex_pcm(fname, 15, 1e6);

    len = length(samp);
    Neng = 64;
    for ii=1:len-1-Neng
        E(ii)=sum(abs(samp(ii:ii+Neng-1)).^2);
    end
    plot(E,'.')
    xxx = 0;
end
% Joint Sampling Rate and Carrier Frequency Offset Tracking

clear

numRx = 1;                  % Number of receive antennas
numTx = 1;
cbw = 'CBW20';
numTxPkt = 8;               % Number of transmitted packets
cfo = 100e3;                    % Carrier frequency offset (Hz)
delayProfile = 'Model-A';   % TGac channel delay profile
idleTime = 0; %0; %20e-6;   % Idle time before and after each packet

cfgVHTTx = wlanVHTConfig( ...
    'ChannelBandwidth',    cbw, ...
    'NumTransmitAntennas', numTx, ...
    'NumSpaceTimeStreams', 1, ...
    'SpatialMapping',      'Direct', ...
    'STBC',                false, ...
    'MCS',                 2, ...
    'GuardInterval',       'Long', ...
    'APEPLength',          1024);

fs = wlanSampleRate(cfgVHTTx);

txPSDU = randi([0 1],cfgVHTTx.PSDULength*numTxPkt,1);
txSig = wlanWaveformGenerator(txPSDU,cfgVHTTx);
plot(abs(txSig).^2), grid minor;

tgacChan = wlanTGacChannel('SampleRate',fs,'ChannelBandwidth',cbw, ...
    'NumTransmitAntennas',numTx,'NumReceiveAntennas',numRx,'DelayProfile',delayProfile);

pfOffset = comm.PhaseFrequencyOffset('SampleRate',fs,'FrequencyOffsetSource','Input port');

rxSigNoNoise = tgacChan([zeros(round(idleTime*fs),cfgVHTTx.NumTransmitAntennas); txSig]);
rxSig = awgn(rxSigNoNoise,40);

rxSigFreqOffset = pfOffset(rxSig,cfo);

ind = wlanFieldIndices(cfgVHTTx);

% Packet detection
[tOff,rc] = wlanPacketDetect(rxSigFreqOffset,cfgVHTTx.ChannelBandwidth);

% Coarse frequency offset correction
rxLSTF = rxSigFreqOffset(tOff+(ind.LSTF(1):ind.LSTF(2)),:);

foffset1 = wlanCoarseCFOEstimate(rxLSTF,cbw);
rxSig1 = pfOffset(rxSigFreqOffset,-foffset1);
% rxSigOff = rxSigFreqOffset.*exp(-1i*2*pi*foffset1/fs*(0:length(rxSigFreqOffset)-1)');

% Symbol timing synchronization
nonhtPreamble = rxSigFreqOffset(tOff+(ind.LSTF(1):ind.LSIG(2)),:);
symOff = wlanSymbolTimingEstimate(nonhtPreamble,cfgVHTTx.ChannelBandwidth);
tOff = tOff+symOff;
% tOff = tOff - 9;

% Extract the L-LTF from the corrected signal. Estimate and correct for the residual frequency offset.
rxLLTF = rxSig1(ind.LLTF(1):ind.LLTF(2),:);%rxSig1(tOff+(ind.LLTF(1):ind.LLTF(2)),:);
foffset2 = wlanFineCFOEstimate(rxLLTF,cbw);
% [~,foffset21] = FineCFOEstimation(rxSig1);
rxSig2 = pfOffset(rxSig1,-foffset2);

% Extract and demodulate the VHT-LTF. Estimate the channel coefficients.
rxVHTLTF = rxSig2(tOff+(ind.VHTLTF(1):ind.VHTLTF(2)),:);
demodVHTLTF = wlanVHTLTFDemodulate(rxVHTLTF,cfgVHTTx);
chEst = wlanVHTLTFChannelEstimate(demodVHTLTF,cfgVHTTx);

% Extract the VHT data field from the received and frequency-corrected PPDU. Recover the data field.
rxData = rxSig2(tOff+(ind.VHTData(1):ind.VHTData(2)),:);

% Calculate the noise variance for a receiver with a 9 dB noise figure. Pass the transmitted waveform through the noisy TGac channel.
nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);
rxPSDU = wlanVHTDataRecover(rxData,chEst,nVar,cfgVHTTx);
% Calculate the number of bit errors in the received packet.

numErr = biterr(txPSDU,rxPSDU(1:length(txPSDU)))

% % Packet Recovery
% cfgVHTRx = wlanVHTConfig('ChannelBandwidth', cfgVHTTx.ChannelBandwidth);
% idxLSTF = wlanFieldIndices(cfgVHTRx, 'L-STF'); 
% idxLLTF = wlanFieldIndices(cfgVHTRx, 'L-LTF'); 
% idxLSIG = wlanFieldIndices(cfgVHTRx, 'L-SIG'); 
% idxSIGA = wlanFieldIndices(cfgVHTRx, 'VHT-SIG-A'); 