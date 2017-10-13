clear all, close all, clc

I = double(imread('moon_gray.png'));

% Filtro 3c - Laplaciano
fs=400;
v1=1/fs;
v2=1/fs;
x=[0:v1:1];
y=[0:v2:1];
[X,Y]=meshgrid(x,y); 

f0x=0.5;
f0y=0.5;
Xc = (X - f0x);Yc = (Y - f0y);

D0=fs/8;
K = 1;
%f_gaussiana = f_gaussiana./(1/(2*pi*sigma)*exp(-(0)/2*sigma^2));
% filtro paso bajo ideal con frecuencia de corte D0
f_filter = 1+K.*(Xc.^2+Yc.^2); %double(Xc.^2 + Yc.^2 <= D0/fs); 

f_filter_d = ifftshift(f_filter);
h_d = ifft2(f_filter_d);
h = fftshift(h_d);
if (sum(abs(imag(h(:)))) < exp(-10))
    h = real(h);
end    
cx = 1 + fs./2;
cy = 1 + fs./2;

w = 2;

filter_mask=h(cy-w:cy+w,cx-w:cx+w); 

[m,j] = min(filter_mask(:));
filter_mask = filter_mask./m; 
R = ceil(127./max(abs(filter_mask(:)))); 

% b�squeda de la versi�n entera que minimiza el MSE 
mse = Inf.*ones(1,R);
for j =1:R
    dif = (filter_mask - double(round(filter_mask.*j)./j)).^2;
    mse(j) = mean(dif(:));
end
[~,j]=find(mse==min(mse),1);
filter_mask = round(filter_mask.*j);

C = sum(filter_mask(:));
filter_mask=filter_mask./C;

h_f = zeros(size(h));
h_f(cy-w:cy+w,cx-w:cx+w) = filter_mask./C; 

h_f_d = fftshift(h_f);
f_filter_t_d = fft2(h_f_d);
f_filter_t = abs(ifftshift(f_filter_t_d));% s�lo el m�dulo 

M = max(max( f_filter_t ));

m = min(min( f_filter_t ));

f_filter_t = (f_filter_t - m)/(M-m);

% Aplicacion y estirado

IC = imfilter(I, filter_mask);
m = min(IC(:));
M = max(IC(:));
ICest = (IC-m)/(M-m)*255;

I = uint8(I);
hist = imhist(I);
I_res = histeq(uint8(ICest), hist);
diff = double((I-I_res).^2);
m = min(diff(:));
M = max(diff(:));
diff = (diff)/(M-m)*1.5;

subplot 221
imshow(I);
E = getEnergia(I);
title(sprintf('Imagen original, E=%g', E));
subplot 222
imshow(uint8(I_res));
E = getEnergia(I_res);
title(sprintf('Imagen combinada estirada, E=%g', E));
%subplot 223
%imshow(uint8(IF2));
%E = getEnergia(IF2);
%title(sprintf('Imagen detalle fino estirada, E=%g', E));
subplot 224
imshow((diff));
E = getEnergia(diff);
title(sprintf('Diferencia, E=%g', E));