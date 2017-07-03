clc; clear all; close all;

f = imread('dataset\IMG_20161120_155459.jpg');
figure;imshow(f,[]);

f_hsv = rgb2hsv(f);
figure; imshow(squeeze(f_hsv(:,:,1)),[]);
figure; imshow(squeeze(f_hsv(:,:,2)),[]);
figure; imshow(squeeze(f_hsv(:,:,3)),[]);


%% l'image avec 2 euros
f_test=(f_hsv(:,:,1));
threshold1=multithresh(f_test,6);
f_test=(f_test>threshold1(1,6));
figure;imshow(f_test);
f_test=imclose(f_test,strel('disk',2));
figure;imshow(f_test);
f_test=bwareaopen(f_test,800);
figure;imshow(f_test);
f_test= imclose(f_test,strel('disk',20));
figure;imshow(f_test);

f_l = (f_hsv(:,:,1)) ;
[counts,x] = imhist(f_l);
figure; bar(x,counts);
%threshold2=multithresh(f_l,4);
%f_bw=(f_l<threshold2(1,1));
f_bw  = im2bw(f_l,graythresh(f_l));
figure; imshow(f_bw,[]);
f_bw = imcomplement(f_bw);
f_bw=imclearborder(f_bw);
f_bw1 = imfill(f_bw,'holes');
figure;imshow(f_bw);
f_bw2= imclose(f_bw1,strel('disk',30));
figure;imshow(f_bw2);
f_bw3=imopen(f_bw2,strel('disk',5));
figure;imshow(f_bw3);
f_bw4 = imclearborder(f_bw3);
f_bw4 = imfill(f_bw4,'holes');%fill the hole of 1 euros
figure;imshow(f_bw4);

mask=im2bw(f_bw4-f_test);
mask=imfill(mask,'holes');
figure();imshow(mask);
mask=imopen(mask,strel('disk',50));
figure();imshow(mask);
mask=imclose(mask,strel('disk',15));

%% image san 2 euros
f_test2=f_hsv(:,:,2);
imshow(f_test2);
threshold1=multithresh(f_test2,1);
f_wb=(f_test2>threshold1(1,1));
imshow(f_wb);
f_wb1=imfill(f_wb,'holes');
imshow(f_wb1);
f_wb2=imopen(f_wb1,strel('disk',5));
imshow(f_wb2);

%% combination
rest=mask-f_wb2;
imshow(rest);
marquer=imopen(rest,strel('disk',50));
imshow(marquer);
marquer=im2bw(marquer);
euro2=imreconstruct(marquer,mask);
imshow(euro2);
result=euro2|f_wb2;
imshow(result);

%% resultat de segmentation
figure();imshow(result);
figure;imshow(result.*double(rgb2gray(f)),[]);
%%
f_label = bwlabel(f_bw4);
figure;imshow(f_label,[]);
figure;imshow(label2rgb(f_label),[]);