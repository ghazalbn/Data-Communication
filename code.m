%% Initialization
clear
close all
clc

alphabet_count = 10;


%% Section 1
fprintf("Section 1:\n\n");

%% Loading audio wav file

voice = 'my name.wav';
% Read the data back into MATLAB
[y, Fs] = audioread(voice);

% create audioplayer object for wav file
player = audioplayer(y, Fs);

%% Questions

%m = audioinfo(voice);
%fprintf("Symbols: %d \n", m.TotalSamples);

% Number of symbols
disp("Shape of audio file:");
disp(size(y));
n = size(y, 1);
ch = size(y, 2);
fprintf("Number of symbols: %d\n", n); %Total Samples
fprintf("Each symbol has %d channels.\n", ch);

% Symbol rate = Fs
fprintf("Symbol rate: %d [symbols/second]\n", Fs);

% Time of audio file
t = Fs \ n;
fprintf("Time: %d\n", t);
fprintf("---------------------------------------------\n");

ys = y(:, 1);

% middle symbol type and value
middle = ys(floor(n/2), 1);
fprintf("Middle symbol type: %s\n", class(middle));
fprintf("Middle symbol value: %f\n", middle);
fprintf("---------------------------------------------\n");

fprintf("Min symbol value: %f\n", min(ys)); % min symbol value
fprintf("Max symbol value: %f\n", max(ys)); % max symbol value
fprintf("---------------------------------------------\n\n");



%% Section 2
fprintf("Section 2:\n\n");

%% add White Noise

% Add white Gaussian noise to audio
SNR = 0;
yn0 = awgn(y, SNR, 'measured');
player1 = audioplayer(yn0, Fs);
audiowrite('my name noisy snr=0.wav', yn0, Fs);

SNR = 10;
yn10 = awgn(y, SNR, 'measured');
player2 = audioplayer(yn10, Fs);
audiowrite('my name noisy snr=10.wav', yn0, Fs);

%% filter

[b,a] = butter(1,1000/(Fs/2),'low');

% filter noisy audio with snr=0
filtered0 = filter(b,a,yn0);

% Remove noise - wiener
[a_wiener0, noise_out] = wiener2(yn0);
player3 = audioplayer(a_wiener0, Fs);
audiowrite('my name noisy snr=0 wiener filtered.wav', a_wiener0, Fs);

% filter noisy audio with snr=10
filtered10 = filter(b, a,yn10);

% Remove noise - wiener
[a_wiener10, noise_out] = wiener2(yn10);
player4 = audioplayer(a_wiener10, Fs);
audiowrite('my name noisy snr=10 wiener filtered.wav', a_wiener10, Fs);

% print SNRs
fprintf("noisy audio with snr=0 SNR: %.1f\n", snr(y, yn0-y));
fprintf("noisy audio with snr=0 filtered with filter function SNR: %.4f\n", snr(y, filtered0 - y));
fprintf("noisy audio with snr=0 filtered with wiener function SNR: %.4f\n\n", snr(y, a_wiener0 - y));

fprintf("noisy audio with snr=10  SNR: %.1f\n", snr(y, yn10-y));
fprintf("noisy audio with snr=10 filtered with filter function SNR: %.4f\n", snr(y, filtered10 - y));
fprintf("noisy audio with snr=10 filtered with wiener function SNR: %.4f\n\n", snr(y, a_wiener10 - y));
fprintf("this section has 2 figures and 5 voices.\nwait for all sections to complete to see them.\n");
fprintf("---------------------------------------------\n\n");



%% plot original and noisy, and filtered audios

% SNR = 0
f = figure(1)
f.Name = "SNR = 0";
subplot(4,1,1)
plot(y)
title('original audio')
subplot(4,1,2)
plot(yn0)
title('noisy audio with snr=0')
subplot(4,1,3)
plot(filtered0)
title('filtered noisy audio with snr=0')
subplot(4,1,4)
plot(a_wiener0)
title('wiener filtered noisy audio with snr=0')

% SNR = 10
f = figure(2)
f.Name = "SNR = 10";
subplot(4,1,1)
plot(y)
title('original audio')
subplot(4,1,2)
plot(yn10)
title('noisy audio with snr=10')
subplot(4,1,3)
plot(filtered10)
title('filtered noisy audio with snr=10')
subplot(4,1,4)
plot(a_wiener10)
title('wiener filtered noisy audio with snr=10')




%% Section 3
fprintf("---------------------------------------------\n\n");
fprintf("Section 3:\n\n");
fprintf("Wait for encoding to complete to see the result.\n");

%% Huffman encoding compress

[h, alphabet]= hist(y, unique(y));
p = h/sum(h);
[dict, len] = huffmandict(alphabet, p); 
encoded = huffmanenco(y, dict);

% Save
audiowrite('my name compressed.wav', encoded, Fs);

% Compare
File = dir(voice);
fprintf("Original file size: %d\n", 8 * File.bytes);
fprintf("Compressed file size: %d\n", length(encoded));



%% play audios of Section 1 and 2

%original audio
playblocking(player);
% noisy audio with snr=0
playblocking(player1);
% wiener filtered noisy audio with snr=0
playblocking(player3);
% noisy audio with snr=10
playblocking(player2);
% wiener filtered noisy audio with snr=10
playblocking(player4);


