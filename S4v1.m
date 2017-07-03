clc; clear all; close all;
%% 1 load the original image

f = imread('dataset/IMG_20161120_161003.jpg');
r=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
f=imnoise(im2double(f)/r(1,10),'gaussian');
imshow(f);
calC=[100 90 61;120 112 103;67 58 190];

%% 2 Segmentation of coins
result=segmentCoins(f);
figure;imshow(result.*double(rgb2gray(f)),[]);

%% 3  label
[f_label,n] = bwlabel(result);
figure;imshow(f_label,[]);
figure;imshow(label2rgb(f_label),[]);

stats = regionprops(result,'EquivDiameter','Centroid','PixelList');

%% distuiguish coins by the diameter
wallet=distinguishCoins(f,result,0.038);

