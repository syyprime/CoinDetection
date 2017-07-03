function I=drawCircle(x0,y0,r,I)               
for i=1:size(I,1)
        for j=1:size(I,2)
            distance=sqrt((i-x0).^2+(j-y0).^2);
                if(distance<r)
                    I(i,j)=1;
                else
                    I(i,j)=0;
                end
        end
end