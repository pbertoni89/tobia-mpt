function [ x, Z_I, flag ] = lptobia( P, z, I )
%LPTOBIA Kernel of the P.O. model by Tobia.
%   P is a (TxJ) matrix of relative returns of J securities over T periods (or in T different scenarios, which is equivalent).
%	z is the minimum return desired by the decision maker
%	p is the probability with which the z fact will occurr, i.e., Pr( vopt >= z).
%	pdf is the probability distribution function of the T scenarios.

	[T, J] = size(P);
	pdf = (1/T) * ones(1, T);		% uniform scenario probability
	f =  - pdf * P;					% see row 228 of tobia.pdf
	% minus in f because we are maximizing

	Ifull = ones(1,T);
	Iactive = find(Ifull - I);
%fprintf('\nIactives are '), printarray(Iactive, 'd'), fprintf('\n')
	ineqs = length(Iactive);
	A = zeros(ineqs, J);
	rowA = 1;
	for i=1:T
		if(any(i==Iactive))			% see row 231 of tobia.pdf
			A(rowA,:) = - P(i,:);	% see row 231 of tobia.pdf
			rowA = rowA+1;
		end
		%i = i+1
		%t
	end
	b = - z * ones(ineqs, 1);		% see row 231 of tobia.pdf
	
	Aeq = ones(1, J);				% sum of shares = 1
	beq = 1;						% sum of shares = 1

	lb = zeros(1, J);
	ub = ones(1, J);
	
	displayOff = optimset('Display','off');	% avoid annoying outputs
	dumbX0 = zeros(size(f)); % must be used for call arguments compliance
	[x,Z_I,flag] = linprog(f,A,b,Aeq,beq,lb,ub,dumbX0,displayOff);
	
end