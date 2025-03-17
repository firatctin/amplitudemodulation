clc; clear vars; close all;
fm = 1000;
fc = 1e5;
%Large Carrier
Fs = 3e5;%to prevent aliasing we must choose at least 2* maximum freq component

%

t = 0:1/Fs:0.01;
m_t = cos(2*pi*fm*t);
A = abs(min(m_t));%for maximum efficiency we must choose m(t)min
c_t = cos(2*pi*fc*t);

mod_m = m_t.*c_t + A*c_t;

%Applying fourier transform to see spectrums
%we must choose the step size with no leakage
%k*Fs/N = fc+fm but we know that fft algorithms work on powers of 2
%so we should increase the stepsize as we can
N = power(2,10);
m_f = fft(m_t,N);
c_f = fft(c_t,N);
MOD_m = fft(mod_m,N);
%plotting time axis

figure (1);
subplot 311
plot(t,m_t);
title('m(t)');
xlabel('time')
ylabel('m(t)')
subplot 312
plot(t,c_t)
title('c(t)');

xlabel('time')
ylabel('c(t)')
subplot 313
plot(t,mod_m)
title('m(t) Modulated');
xlabel('time')
ylabel('m(t) mod')
%Plotting frequency axis
f_axis = linspace(-Fs/2,Fs/2,N);
figure (2);
subplot 311
plot(f_axis,abs(m_f));
title('M(f)');
xlabel('Frequency(Hz)')
ylabel('M(f)')
subplot 312
plot(f_axis,abs(c_f))
title('C(f)');
xlabel('Frequency(Hz)')
ylabel('C(f)')
subplot 313
plot(f_axis,abs(MOD_m))
title('M(f) Modulated');
xlabel('Frequency(Hz)')
ylabel('M(f) mod')

%Suppressed Carrier

DSB_sc= m_t.*c_t;
%plotting time axis
DSB_sc_spec = fft(DSB_sc,N);
figure (3);
subplot 311
plot(t,m_t);
title('m(t)');
xlabel('time')
ylabel('m(t)')
subplot 312
plot(t,c_t)
title('c(t)');

xlabel('time')
ylabel('c(t)')
subplot 313
plot(t,DSB_sc)
title('m(t) Modulated');
xlabel('time')
ylabel('m(t) mod')
%Plotting frequency axis
f_axis = linspace(-Fs/2,Fs/2,N);
figure (4);
subplot 311
plot(f_axis,abs(m_f));
title('M(f)');
xlabel('Frequency(Hz)')
ylabel('M(f)')
subplot 312
plot(f_axis,abs(c_f))
title('C(f)');
xlabel('Frequency(Hz)')
ylabel('C(f)')
subplot 313
plot(f_axis,abs(DSB_sc_spec))
title('M(f) Modulated');
xlabel('Frequency(Hz)')
ylabel('M(f) mod')

%Demodulation with envelope detector

%Demodution with envelope detection
%to prevent the hilbert transform's boundary effect perform zero padding
padded_mod_m = [zeros(1,100),mod_m,zeros(1,100)];

demod_sig1 = envelope(padded_mod_m);
demod_sig1 = demod_sig1(101:end-100);
demod_sig1 = demod_sig1 -1;%getting rid of dc offset(capacitor)
%Synchoronous demodulation
%defining fc=1.5 kHz lowpass filter
Hd=lowpass1500;
b = Hd.Numerator;
demod_sig2 = 2*filter(b,1,DSB_sc.*c_t);

sig1_f = fft(demod_sig1,N);
sig2_f = fft(demod_sig2,N);

%Plotting in time domain
%for envelope detection
figure (5)
subplot 311
plot(t,m_t);
title('m(t)')
subplot 312
plot(t,mod_m)
title('Modulated m(t)')
subplot 313
plot(t,demod_sig1)
title('Demodded with envelope detection');

%synchronous
figure (6)
subplot 311
plot(t,m_t);
title('m(t)')
subplot 312
plot(t,DSB_sc)
title('Modulated m(t)')
subplot 313
plot(t,demod_sig2)
title('Demodded sycnhronously');

%plotting in freq domain
%envelope detection
figure (7)
subplot 211
plot(f_axis,abs(MOD_m))
title('Modulated M(f)')
subplot 212
plot(f_axis,abs(sig1_f))
title('Demodulated with Envelope Detection');

%synchronous
figure (8)
subplot 211
plot(f_axis, abs(DSB_sc_spec))
title('Modulated M(f)')
subplot 212
plot(f_axis, abs(sig2_f))
title('Synchronous Demod');