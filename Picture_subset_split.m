set(0,'defaulttextinterpreter','latex')
	addpath('D:\Work\Masters\DIC_Matlab\matlab2tikz-matlab2tikz-v1.1.0-0-g816f875\matlab2tikz-matlab2tikz-816f875\src')

x=[-11 22; -11 22; -11 22; -11 22]

y=[0 0; 11 11; 22 22; -11 -11]

xx=[0 11]
yy=[1 1; 2 2; 3 3; 4 4; 5 5; 6 6; 7 7; 8 8; 9 9; 10 10]% 11 11; 12 12; 13 13; 14 14; 15 15; 16 16; 17 17; 18 18; 19 19; 20 20]

m=0.8
d=6
c=3

f=@(x) m*(x-d)+c
fx=-11:0.1:22;
fy=f(fx);

mm=-1/m;
cc=5.5-5.5*mm;
g=@(x) mm*(x)+cc
gy=g(fx)

% y-x*m=c
c1=16.5-(-5.5)*m;
c2=5.5-(-5.5)*m;
c3=16.5-5.5*m;
x1=(c1-cc)/(mm-m);
x2=(c2-cc)/(mm-m);
x3=(c3-cc)/(mm-m);
y1=g(x1);
y2=g(x2);
y3=g(x3);

figure
plot(x(1,:),y(1,:),'k')
hold on
% plot([5.5 -5.5 -5.5 5.5 -5.5 5.5 16.5 16.5],[5.5 5.5 16.5 16.5 -5.5 -5.5 5.5 16.5],'om','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize',3)
plot([5.5 -5.5 -5.5 5.5 -5.5 5.5 16.5 16.5],[5.5 5.5 16.5 16.5 -5.5 -5.5 5.5 16.5],'ok','MarkerSize',3)
plot(xx,yy(1,:),'b')
xxx=[0 3 3 4 4 5 5 7 7 8 8 9 9 10 10 11 11 0]
yyy=[0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 11 11]
patch(xxx,yyy,'cyan')
alpha(0.3)

xxx2=[3 3 4 4 5 5 7 7 8 8 9 9 10 10 11 11]
yyy2=[0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 0]
patch(xxx2,yyy2,'yellow')
alpha(0.3)

% fplot(f,[-11 22],'r')
% fplot(g,[-11 22],'--r')
plot(fx,fy,'r')
plot(fx,gy,'--r')
arrow([x1 y1], [-5.5 16.5],'Length',3,'TipAngle',35,'BaseAngle',65,'EdgeColor','m','FaceColor','m')

	xlabel('x [pixels]','Interpreter','latex')
	ylabel('y [pixels]','Interpreter','latex')




plot(x(2,:),y(2,:),'k')
plot(x(3,:),y(3,:),'k')
plot(x(4,:),y(4,:),'k')

plot(y(1,:),x(1,:),'k')
plot(y(2,:),x(2,:),'k')
plot(y(3,:),x(3,:),'k')
plot(y(4,:),x(4,:),'k')


for i=2:10
	plot(xx,yy(i,:),'b')
end
for i=1:10
	plot(yy(i,:),xx,'b')
end


axis equal




arrow([-5.5 16.5],[x1 y1], 'Length',3,'TipAngle',35,'BaseAngle',65,'EdgeColor','m','FaceColor','m')

arrow([x2 y2], [-5.5 5.5],'Length',3,'TipAngle',35,'BaseAngle',65,'EdgeColor','m','FaceColor','m')
arrow([-5.5 5.5],[x2 y2], 'Length',3,'TipAngle',35,'BaseAngle',65,'EdgeColor','m','FaceColor','m')

arrow([x3 y3], [5.5 16.5],'Length',3,'TipAngle',35,'BaseAngle',65,'EdgeColor','m','FaceColor','m')
arrow([5.5 16.5],[x3 y3], 'Length',3,'TipAngle',35,'BaseAngle',65,'EdgeColor','m','FaceColor','m')


% arrow([-4.191 17.61], [-5.5 16.5],'Length',3,'TipAngle',35,'BaseAngle',65)
% arrow([-5.5 16.5],[-4.191 17.61], 'Length',3,'TipAngle',35,'BaseAngle',65)
xlim([-11 22])
ylim([-11 22])

set(gcf,'units','points','position',[10,10,500,500])
legend({'Subsets','Subset centre','Pixels','Pixel group 1','Pixel group 2','Splitting line','Temporary line','Distance to temporary line'},'Interpreter','latex','Location','southeast')