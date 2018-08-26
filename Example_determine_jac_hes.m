% Here F is the reference subset light intensity values and G is the interpolated values of the deformed subset
Fmean=mean(mean(F)); 
Gmean=mean(mean(G));
Fsqrt=sqrt(sum(sum((F-Fmean).^2)));
Gsqrt=sqrt(sum(sum((G-Gmean).^2)));
% initialise Jacobian and Hessian
J=zeros([numP,1]);
H=zeros([numP,numP]);
for i=1:n % summation over whole subset (n=number of pixels)
	% determine derivatives of light intensity values
	J_G=(JacobianFunction(coef{i},P',dx(i),dy(i),X,Y));
	H_G=(HessianFunction(coef{i},P',dx(i),dy(i),X,Y));
	% use derivatives to compute Jacobian and Hessian
	J=J+((F(i)-Fmean)/Fsqrt-(G(i)-Gmean)/Gsqrt).*((-J_G')./Gsqrt);
	H=H+(-J_G'./Gsqrt)*(-J_G./Gsqrt) + ((F(i)-Fmean)/Fsqrt-(G(i)-Gmean)/Gsqrt).*(-H_G)./Gsqrt; %if transpose jacky outside of brackets it doesn't work
end
J=2*J;
H=2*H;