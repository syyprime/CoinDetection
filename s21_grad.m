clc; clear all; close all;
%% gradient
f = imread('dataset\IMG_20161120_155631.jpg');
f_hsv = rgb2hsv(f);
figure(1); imshow(squeeze(f_hsv(:,:,3)),[]);

f_test=(f_hsv(:,:,3));
[gmax1,gh,gv]=tse_imgrad(f_test,'sobel');
g1=sqrt(gh.^2+gv.^2);
figure(2);imshow(g1,[]);


[fs,h]=tse_imhysthreshold(g1);
fs=imfill(fs,'holes');
figure;imshow(fs,[]),title(sprintf('hight=%g',h));


mask=imopen(fs,strel('disk',1));
mask=imfill(mask,'holes');
mask=imopen(mask,strel('disk',2));
mask=imfill(mask,'holes');
mask=imopen(mask,strel('disk',3));
mask=imfill(mask,'holes');
mask=imopen(mask,strel('disk',4));
mask=imfill(mask,'holes');
mask=imopen(mask,strel('disk',5));
mask=imfill(mask,'holes');
figure();imshow(mask);

figure();imshow(mask);
figure;imshow(mask.*double(rgb2gray(f)),[]);
