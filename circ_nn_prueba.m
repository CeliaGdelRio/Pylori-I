Y=zeros(length(X(1,:)),16);
for i=1:length(X(1,:))
    Y(i,:)=reescalado_nn(xmin,xmax,ymin,ymax,W1,W2,b1,b2,X(:,i));
end