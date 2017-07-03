clc; clear all; close all;
%% 1 load the original image
f = imread('dataset/IMG_20161120_161320.jpg');
imshow(f);
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
% [centersBright, radiiBright] = imfindcircles(result,[200 300],'Sensitivity',0.98);
% I=zeros(size(result,1),size(result,2));
% for i=1:size(radiiBright,1)
% I1=drawCircle(centersBright(i,1),centersBright(i,2),radiiBright(i,1),result);
% I=I|I1;
% end
% imshow(I);
%for i=1:size(radiiBright,1);


%% resultat de segmentation
result=imclearborder(result);
result1=imerode(result,strel('disk',100));
result=imreconstruct(result1,result);
%figure();imtool(result);
figure;imshow(result.*double(rgb2gray(f)),[]);

%% label
[f_label,n] = bwlabel(result);
figure;imshow(f_label,[]);
figure;imshow(label2rgb(f_label),[]);

%% distinguish coins by the diameter
% use commandes imopen and imclose to make the color of coin more stable
% and this will helpful for distinction of coins by the color later.
Ie=imopen(f,strel('disk',10));
Ies=imclose(Ie,strel('disk',10));
% imshow(Ies);

wallet=zeros(1,8);
stats = regionprops(result,'EquivDiameter','Centroid','PixelList');
diameter=zeros(1,size(stats,1));
type=cell(1,size(stats,1));
% detection of multi-object image
if size(stats,1)~=1

for i=1:size(stats,1)
diameter(i) = stats(i).EquivDiameter;
% 1 cent
if 415<=diameter(i)&&diameter(i)<=445
   wallet(1,1)=wallet(1,1)+1;
   type(i)={'1C'};
end

% distinguish 2 cent and 10 cent
% we find that the diffrence between the valeur of red division and the
% valeur of blue divsion is the key to distinguish gold and copper.the
% difference of copper is more than that of gold.
if 485<=diameter(i)&&diameter(i)<=540
    cent=round(stats(i).Centroid);
    valPixelR=Ies(cent(1,2)-100:cent(1,2)+100,cent(1,1)-100:cent(1,1)+100,1);
    valPixelB=Ies(cent(1,2)-100:cent(1,2)+100,cent(1,1)-100:cent(1,1)+100,3);
    aveR=mean(valPixelR(:));
    aveB=mean(valPixelB(:));
    aveRB=aveR-aveB;
    if(aveRB<55)
        wallet(1,4)=wallet(1,4)+1;
        type(i)={'10C'};
    else
        wallet(1,2)=wallet(1,2)+1;
        type(i)={'2C'};
    end
end
% distinguish 5 cent and 10 cent
% we find that the diffrence between the valeur of red division and the
% valeur of blue divsion is the key to distinguish gold and copper.the
% difference of copper is more than that of gold.
if 550<=diameter(i)&&diameter(i)<=575 
    cent=round(stats(i).Centroid);
    valPixelR=Ies(cent(1,2)-100:cent(1,2)+100,cent(1,1)-100:cent(1,1)+100,1);
    valPixelB=Ies(cent(1,2)-100:cent(1,2)+100,cent(1,1)-100:cent(1,1)+100,3);
    aveR=mean(valPixelR(:));
    aveB=mean(valPixelB(:));
    aveRB=aveR-aveB;
    if(aveRB<60)
        wallet(1,4)=wallet(1,4)+1;
        type(i)={'10C'};
    else
        wallet(1,3)=wallet(1,3)+1;
        type(i)={'5C'};
    end
end

if 595<=diameter(i)&&diameter(i)<=600
    wallet(1,3)=wallet(1,3)+1;
    type(i)={'5C'};
end

% 20cent
if 576<=diameter(i)&&diameter(i)<=595
   wallet(1,5)=wallet(1,5)+1;
   type(i)={'20C'};
end

% 50cent
if 625<=diameter(i)&&diameter(i)<=655
   wallet(1,6)=wallet(1,6)+1;
   type(i)={'50C'};
end

% 1euro
if 601<=diameter(i)&&diameter(i)<=620
   wallet(1,7)=wallet(1,7)+1;
   type(i)={'1E'};
end

% 2euro
if 690<=diameter(i)&&diameter(i)<=720
   wallet(1,8)=wallet(1,8)+1;
   type(i)={'2E'};
end
end
end

% detection of solo-object image
if size(stats,1)==1

for i=1:size(stats,1)
diameter(i) = stats(i).EquivDiameter;
% 1 cent
if 440<=diameter(i)&&diameter(i)<=480
   wallet(1,1)=wallet(1,1)+1;
   type(i)={'1C'};
end

% 2 cent
if 515<=diameter(i)&&diameter(i)<=535
    wallet(1,2)=wallet(1,2)+1;
   type(i)={'2C'};
end

% 5 cent
if 590<=diameter(i)&&diameter(i)<=610
    wallet(1,3)=wallet(1,3)+1;
   type(i)={'5C'};
end

% 10cent
if 560<=diameter(i)&&diameter(i)<=580
    wallet(1,4)=wallet(1,4)+1;
   type(i)={'10C'};
end

% 20cent
if 635<=diameter(i)&&diameter(i)<=650
   wallet(1,5)=wallet(1,5)+1;
   type(i)={'20C'};
end

% 50cent
if 690<=diameter(i)&&diameter(i)<=720
   wallet(1,6)=wallet(1,6)+1;
   type(i)={'50C'};
end

% 1euro
if 660<=diameter(i)&&diameter(i)<=685
   wallet(1,7)=wallet(1,7)+1;
   type(i)={'1E'};
end

% 2euro
if 740<=diameter(i)&&diameter(i)<=770
   wallet(1,8)=wallet(1,8)+1;
   type(i)={'2E'};
end
end
end

%% count the value of coins
sum=wallet(1,1)*0.01+wallet(1,2)*0.02+wallet(1,3)*0.05+...
    wallet(1,4)*0.1+wallet(1,5)*0.2+wallet(1,6)*0.5...
    +wallet(1,7)*1+wallet(1,8)*2;
figure;imshow(f);hold on;
for i=1:size(stats,1)
    centroid = stats(i).Centroid;
    text(centroid(1),centroid(2),type(1,i),'FontSize',18,'FontWeight','bold');
end