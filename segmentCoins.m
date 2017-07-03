function result=segmentCoins(f)
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
% figure, imshow(shadow_ratio, []); colormap(jet); colorbar;
shadow_mask = shadow_ratio>0.04;
shadow_mask = bwareaopen(shadow_mask, 150);
% figure, imshow(shadow_mask, []);
shadow_mask1=imclose(shadow_mask,strel('disk',10));
% figure, imshow(shadow_mask1, []);

% detect coins by the method of gradient
f_test=(f_hsv(:,:,3));
[gmax1,gh,gv]=tse_imgrad(f_test,'sobel');
g1=sqrt(gh.^2+gv.^2);
% figure(2);imshow(g1,[]);

[fs,h]=tse_imhysthreshold(g1);
fs=imfill(fs,'holes');
% figure;imshow(fs,[]),title(sprintf('hight=%g',h));


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
% figure();imshow(mask);

%delete the shadows 
result2euros=mask-shadow_mask1;
% figure(),imshow(result2euros);
result2euros=imfill(result2euros,'holes');
result2euros1=bwareaopen(result2euros, 200);
% figure(),imshow(result2euros1);

%% 3 detect the part of coins (without 2 euros.)
% we find that using threshold to the second dimension of the image hsv can
% perfectly get segments of all the coins except 2 euros.


f_test2=f_hsv(:,:,2);
% imshow(f_test2);
threshold1=multithresh(f_test2,1);
f_wb=(f_test2>threshold1(1,1));
% imshow(f_wb);
f_wb1=imfill(f_wb,'holes');
% imshow(f_wb1);
f_wb2=imopen(f_wb1,strel('disk',5));
% imshow(f_wb2);

%% 4 Combination
% just like what we said at the third step (detect all the coins (2 euro
% included)),the main goal of that step is to get the segments of 2 euros.
% now we ajoute the segments of 2 euros in the image we got at the third 
% step.In the end,the combination of images at the step 2 and 3 is the
% final result

rest=result2euros1-f_wb2;
% imshow(rest);
marquer=imopen(rest,strel('disk',50));
% imshow(marquer);
marquer=im2bw(marquer);
euro2=imreconstruct(marquer,result2euros1);
% imshow(euro2);
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

