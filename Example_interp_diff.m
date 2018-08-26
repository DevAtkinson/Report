	% Declare the necessary variables symbolically
	a = sym('a_%d', [4 4]) % The coefficients of the interpolation equation
	P = sym('p_%d', [6,1]) % The warp function parameters
	syms dx dy x0 y0; % dx = delta x, dy = delta y and (x0,y0) is the centre of the subset

	% Use the warp function to determine the warped coordinates (query points)
	x_q=P(1)+P(3).*dy+dx.*(P(2)+1.0)+x0;
	y_q=P(4)+P(5).*dx+dy.*(P(6)+1.0)+y0;
	% Determine the fractional part of the query points
	x_fq=x_q-floor(x_q);
	y_fq=y_q-floor(y_q);
	% Create the function for interpolating the query points - this equation is a function of the warp function parameters, the interpolation coefficients, subset centre and pixel position
	G_interp=[1, x_fq, x_fq^2, x_fq^3]*a*[1; y_fq; y_fq^2; y_fq^3];
	% Calculate the Jacobian and Hessian of the interpolation equation
	J_G=jacobian(G_interp,P);
	H_G=hessian(G_interp,P);
	% Convert these symbolic expressions of the Jacobian and Hessian into matlab functions which are dependent on the necessary variables.
	matlabFunction(J_G,'File','JacobianFunction','Optimize',true,'Vars',{a,P,dx,dy,x0,y0});
	matlabFunction(H_G,'File','HessianFunction','Optimize',true,'Vars',{a,P,dx,dy,x0,y0});