% 读取图片并显示
im = imread('satellite_degraded.tiff');
figure;
imshow(im);
%图像是500*500的，其他尺寸需要改变以下的两个500
%构造退化函数，高斯或者类似高斯，exp中的第一个是参数
H = zeros(500,500);
for i= 1:500
    for j = 1:500
%         H(i,j) = exp(-1/(2*sigma^2)*((i-250)^2+(j-250)^2));
%           H(i,j) = exp(-0.005*((i-250)^2+(j-250)^2)^(5/6));
          H(i,j) = exp(-0.0025*((i-250)^2+(j-250)^2));
    end
end
%对原始信号归一化后傅里叶变换并通过fftshift重构，将低频移至中心，高频移至四个角
signal_1 = im;
signal_1 = im2double(signal_1);
F_signal_1 = fft2(signal_1);
F_last_signal = fftshift(F_signal_1);
%选择逆滤波的范围，大于threshold的值不做处理，否则除以构造的退化函数
threshold = 50;
for i= 1:500
    for j = 1:500
        if (sqrt((i-250).^2+(j-250).^2)<threshold)
            F_last_signal(i,j) = F_last_signal(i,j)./(H(i,j)+eps);
        end
    end
end
%反变换
F_last_signal = ifftshift(F_last_signal);
last_signal = ifft2(F_last_signal);
last_signal = abs(last_signal);
m = max(max(last_signal));
%归一化以后再还原成色度值
last_signal = last_signal/m;
last_figure = uint16(last_signal*65535);
figure;
imshow(last_figure);