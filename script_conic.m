function script
	close all
	pointA = [0,100,0];
pointB = [0,100,50];
pointC = [50,100,50];
pointD = [50,100,0];
points=[pointA' pointB' pointC' pointD'] % using the data given in the question
fill3(points(1,:),points(2,:),points(3,:),'r')
grid on
hold on
alpha(0.3)
xlabel('x')
ylabel('y')

r=10
teta=-pi:0.01:pi;
x=r*cos(teta)+25;
z=r*sin(teta)+25;
plot3(x,100.*ones(1,numel(x)),z,'--k')

pointE = [0,40,0];
pointF = [0,40,30];
pointG = [30,30,30];
pointH = [30,30,0];
points2=[pointE' pointF' pointG' pointH'] % using the data given in the question
fill3(points2(1,:),points2(2,:),points2(3,:),'c')
alpha(1)

plot3(0,0,0,'ok')
xx=[15 0]
yy=[100 0]
zz=[25 0]
plot3(xx,yy,zz)
end