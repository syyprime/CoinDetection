clc; clear all; close all;


f = imread('C:\Users\ACER\Desktop\第三学期\traitementImg\projet\dataset\IMG_20161120_160148.jpg');
figure;imtool(f);
% figure;imshow(f(800:2400,600:2400,:));

%--Scaling Factor
% 1 cent  : 16.25/455.01=0.0357
% 2 cent:   18.75/520.05=0.0361
% 5 cent  : 21.25 / 599.09 = 0.0354
% 10 cent ;19.75/570.22=0.0346;
% 20 cent: 22.25/646.05=0.0344;
% 50 cent :24.25/692.52=0.0350
% 1 euro  : 23.25 / 668.6 =  0.0348
% 2 euros : 25.75 / 746.52 = 0.0349
SF =  0.0349;

%CopperReg = f(1110:1402,766:1238,:);
figure;CopperReg=imcrop(f);
CopR = round(mean2(CopperReg(:,:,1)));
CopG = round(mean2(CopperReg(:,:,2)));
CopB = round(mean2(CopperReg(:,:,3)));

SilverReg = f(1067:1377,1752:2166,:);
figure;imtool(SilverReg);
SilR = mean2(SilverReg(:,:,1));
SilG = mean2(SilverReg(:,:,2));
SilB = mean2(SilverReg(:,:,3));

WhiteReg = f(1100:1400,2400:2900,:);
figure;imtool(WhiteReg);
WhiR = mean2(WhiteReg(:,:,1));
WhiG = mean2(WhiteReg(:,:,2));
WhiB = mean2(WhiteReg(:,:,3));

GoldReg = f(1800:2000,1250:1700,:);
figure;imtool(GoldReg);
GolR = mean2(GoldReg(:,:,1));
GolG = mean2(GoldReg(:,:,2));
GolB = mean2(GoldReg(:,:,3));
