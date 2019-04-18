clear;
clc;
Ts = 1;
t = 1:1:1000;
t_50 = zeros(50,length(t));

for i = 1:1:50				%产生50个随机样本
    t_50(i,1:length(t))= t(1:end);
end
sita = random('unif',0,1,50,2)*2*pi;  %生成两个0-2pi的随机相位
e = randn(50,length(t));  %产生功率为1W的的噪声
e_fft = fft(e)*10^(-1);  %转到频域进行功率调整
e = ifft(e_fft);  %从频域转回时域
w = [0.34*pi 0.36*pi]; %产生两个频率
A = [10 5];   %产生两个信号的幅度
x = A(1)*sin(w(1)*t_50+sita(1)) + A(2)*sin(w(2)*t_50+sita(2))+e;
figure;       %画一个生成的随机样本
plot(t,x(1,:));
title("随机过程的一次样本实现");
xlabel("t(s)");
ylabel("幅度");

Sx = (abs(fft(x',2000)).^2)/length(t); %得到Sx
fs = 2000;     %fft的采样个数
f = ((0:999)/2000);  %生成频率坐标
sx = Sx';    %Sx是一列为一个样本的fft，因此转置一下方便处理
figure;     %画Sx，序列长=64，周期图方法，噪声功率=1W
hold on;    %画在同一张图上
xlabel("f(Hz)");
ylabel("dB");
title("Sx(w),序列长=64，周期图方法，噪声功率=0.0001W");
for i = 1:1:50
    plot(f,10*log10(sx(i,1:fs/2)));
end

figure;hold on;
title("Sx(w),序列长=64，MUSIC方法，噪声功率=0.0001W");
xlabel("f(Hz)");
ylabel("dB");
for i = 1:1:50
test = x(i,:)';
[s_width,s_length] = size(test);
Rx = test*test';
[V,D] = eig(Rx);
D = diag(D);
[D,pin]=sort(D,'descend');
Vn = V(:,pin(6:s_width,1));
w = 0.1:0.0001:0.2;
len = [0:length(t)-1]';
A_theta = exp(-1j*len*2*pi*w);
p_all = diag(A_theta'*A_theta)./diag(A_theta'*Vn*Vn'*A_theta);
p(i,:)=p_all;
plot(w,abs(p_all));
end

figure;     %下面的操作是将周期图方法和MUSIC方法
subplot(2,1,1),hold on;  %画在同一张图中(subplot)
xlabel("f(Hz)");
ylabel("dB");
title("Sx(w),序列长=1000，周期图方法，幅度比为2，噪声功率为0.01W");
% title("Sx(w),序列长=64，周期图方法，噪声功率为0.0001W");
for i = 1:1:50
    plot(f,10*log10(sx(i,1:fs/2)));
end

%将MUSIC方法画在第二张图上
subplot(2,1,2),hold on;
xlabel("f(Hz)");
ylabel("dB");
title("Sx(w),序列长=1000，MUSIC方法，幅度比为2，噪声功率为0.01W");
% title("Sx(w),序列长=64，MUSIC方法，噪声功率为0.0001W");
for i = 1:1:50
    plot(w,abs(p(i,:)));
end








