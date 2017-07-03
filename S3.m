clc; clear all; close all; warning off;
%%
f = imread('ataset/IMG_20161120_161003.jpg');
figure;imshow(f,[]);
%%
f_l = f(:,:,1);
f_bw  = im2bw(f_l,graythresh(f_l));
figure; imshow(f_bw,[]);
f_bw = imcomplement(f_bw);
f_bw3 = imfill(f_bw,'holes');
figure;imshow(f_bw);
figure;imshow(f_bw3);
f_bw4 = imclose(f_bw3,strel('disk',10));
figure;imshow(f_bw4);
f_label = bwlabel(f_bw4);
figure;imshow(f_label,[]);
figure;imshow(label2rgb(f_label),[]);
%%
stats = regionprops(f_bw4,'EquivDiameter','Centroid','PixelList');
coinPxl = stats(2).PixelList;
f_c = median(impixel(f,coinPxl(:,1),coinPxl(:,2)));

figure;imshow(f,[]); hold on;
plot(stats(2).Centroid(1),stats(2).Centroid(2),'r*');
hold off;