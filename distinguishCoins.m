function[wallet]=distinguishCoins(f,result,calZ)


coinsStandard=[16.25 18.75 21.25 19.75 22.25 24.25 23.25 25.75];
wallet=zeros(1,8);
stats = regionprops(result,'EquivDiameter','Centroid','PixelList');
diameter=zeros(1,size(stats,1));

% detection of multi-object image
if(size(calZ,2)>1)
    
if size(stats,1)~=1
    cal=calZ(1,1);
for i=1:size(stats,1)
diameter(i) = stats(i).EquivDiameter;
diameter(i) =diameter(i)*cal;
if(diameter(i)>=25)
    wallet(1,8)=wallet(1,8)+1;
else
    coinsDiff=abs(coinsStandard-diameter(i));
    [M,I]=min(coinsDiff(:));
    wallet(I)=wallet(I)+1;
end
end
end

% detection of solo-object image
if size(stats,1)==1
    cal=calZ(1,2);
for i=1:size(stats,1)
diameter(i) = stats(i).EquivDiameter;
diameter(i) =diameter(i)*cal;
if(diameter(i)>=25)
    wallet(1,8)=wallet(1,8)+1;
else
    coinsDiff=coinsStandard-diameter(i);
    [M,I]=min(coinsDiff(:));
    wallet(I)=wallet(I)+1;
end

end
end

else
    for i=1:size(stats,1)
diameter(i) = stats(i).EquivDiameter;
diameter(i) =diameter(i)*calZ;
if(diameter(i)>=25)
    wallet(1,8)=wallet(1,8)+1;
else
    coinsDiff=abs(coinsStandard-diameter(i));
    [M,I]=min(coinsDiff(:));
    wallet(I)=wallet(I)+1;
end

    end
end

