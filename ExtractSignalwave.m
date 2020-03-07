function signal_fft = ExtractSignalwave( minFreq ,maxFreq, signal ,sampling_freq)
%gets signal and returns amplitude after fft+hilbert transform

n = length(signal);
startIndex = round(n * minFreq/sampling_freq);

endFreq = maxFreq;
endIndex = round(n * endFreq  / sampling_freq);

signal_fft = fft(signal);
signal_fft(1:startIndex - 1) = 0;
signal_fft(endIndex+1:length(signal)-endIndex)=0;
signal_fft(length(signal)-startIndex + 1:length(signal_fft))=0;
signal_fft = real(ifft(signal_fft));
 
end