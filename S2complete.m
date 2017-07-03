clc; clear all; close all;
%% 1 load the original image
f = imread('dataset/IMG_20161120_161238.jpg');
f_hsv = rgb2hsv(f);
r = medfilt2(double(f(:,:,1)), [3,3]); 
g = medfilt2(double(f(:,:,2)), [3,3]);
b = medfilt2(double(f(:,:,3)), [3,3]);

%% 2 detect all the coins (2 euro included)
% the method gradient and threshold could easily get segments of all the 
% coins,but its drawback is that segments of coins include shadows.
% So we should also detect these shadows and delete them on the segmemts of
% shadows.
% in fact,the real goal of this step is to get the segments of 2 euros 


% detection of shadows
shadow_ratio = ((4/pi).*atan(((b-g))./(b+g)));
figure, imshow(shadow_ratio, []); colormap(jet); colorbar;
shadow_mask = shadow_ratio>0.04;
shadow_mask = bwareaopen(shadow_mask, 150);
figure, imshow(shadow_mask, []);
shadow_mask1=imclose(shadow_mask,strel('disk',10));
figure, imshow(shadow_mask1, []);

% detect coins by the method of gradient
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

%delete the shadows 
result2euros=mask-shadow_mask1;
figure(),imshow(result2euros);
result2euros=imfill(result2euros,'holes');
result2euros1=bwareaopen(result2euros, 200);
figure(),imshow(result2euros1);

%% 3 detect the part of coins (without 2 euros.)
% we find that using threshold to the second dimension of the image hsv can
% perfectly get segments of all the coins except 2 euros.


f_test2=f_hsv(:,:,2);
imshow(f_test2);
threshold1=multithresh(f_test2,1);
f_wb=(f_test2>threshold1(1,1));
imshow(f_wb);
f_wb1=imfill(f_wb,'holes');
imshow(f_wb1);
f_wb2=imopen(f_wb1,strel('disk',5));
imshow(f_wb2);

%% 4 Combination
% just like what we said at the third step (detect all the coins (2 euro
% included)),the main goal of that step is to get the segments of 2 euros.
% now we ajoute the segments of 2 euros in the image we got at the third 
% step.In the end,the combination of images at the step 2 and 3 is the
% final result

rest=result2euros1-f_wb2;
imshow(rest);
marquer=imopen(rest,strel('disk',50));
imshow(marquer);
marquer=im2bw(marquer);
euro2=imreconstruct(marquer,result2euros1);
imshow(euro2);
result=euro2|f_wb2;

%% smooth the boundary
[centersBright, radiiBright] = imfindcircles(result,[200 300],'Sensitivity',0.98);
I=zeros(size(result,1),size(result,2));
for i=1:size(radiiBright,1)
I1=drawCircle(centersBright(i,1),centersBright(i,2),radiiBright(i,1),result);
I=I|I1;
end
imshow(I);
%for i=1:size(radiiBright,1);


%% resultat de segmentation
figure();imtool(result);
figure;imshow(result.*double(rgb2gray(f)),[]);

%% label
[f_label,n] = bwlabel(result);
figure;imshow(f_label,[]);
figure;imshow(label2rgb(f_label),[]);

%% diameter
wallet=zeros(1,8);
stats = regionprops(result,'EquivDiameter','Centroid','PixelList');
diameter=zeros(1,size(stats,1));
for i=1:size(stats,1)
diameter(i) = stats(i).EquivDiameter;
% 1cent
if 415<=diameter(i)&&diameter(i)<=445
   wallet(1,1)=wallet(1,1)+1;
end

%
if 515<=diameter(i)&&diameter(i)<=540
    g=0;
    fd=double(imread('dataset/IMG_20161120_161320.jpg'));
    for k=1:size(stats(i).PixelList,1)
        g=g+fd(stats(i).PixelList(k,1),stats(i).PixelList(k,2),2);
    end
    g=g/k;

    h=zeros(size(f));
    for k=1:size(stats(i).PixelList,1)
         h(stats(i).PixelList(k,1),stats(i).PixelList(k,2),2)=f(stats(i).PixelList(k,1),stats(i).PixelList(k,2),2);
    end
    t=sum(sum(h(:,:,2)))/size(stats(i).PixelList,1);
end
% % 2cent
% if 524<=diameter(i)&&diameter(i)<=540
%    wallet(1,2)=wallet(1,2)+1;
% end
% 
% % 5cent
% if 560<=diameter(i)&&diameter(i)<=575
%    wallet(1,3)=wallet(1,3)+1;
% end
% 
% % 10cent
% if 510<=diameter(i)&&diameter(i)<=523
%    wallet(1,4)=wallet(1,4)+1;
% end

% 20cent
if 576<=diameter(i)&&diameter(i)<=595
   wallet(1,5)=wallet(1,5)+1;
end

% 50cent
if 625<=diameter(i)&&diameter(i)<=655
   wallet(1,6)=wallet(1,6)+1;
end

% 1euro
if 600<=diameter(i)&&diameter(i)<=620
   wallet(1,7)=wallet(1,7)+1;
end

% 2euro
if 690<=diameter(i)&&diameter(i)<=720
   wallet(1,8)=wallet(1,8)+1;
end

end

sum=wallet(1,1)*0.01+wallet(1,2)*0.02+wallet(1,3)*0.05+...
    wallet(1,4)*0.1+wallet(1,5)*0.2+wallet(1,6)*0.5...
    +wallet(1,7)*1+wallet(1,8)*2;

% dis_g=
