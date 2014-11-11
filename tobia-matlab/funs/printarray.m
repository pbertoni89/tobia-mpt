function [  ] = printarray( a, format )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
	if size(a,1) ~= 1
		if size(a,2) == 1
			a = a';
		else
			disp('ERROR IN SIZE OF a');
		end
	end

	if format=='d'
		for c=1:length(a)
			fprintf('\t%d', a(c))
		end
	else
		if format=='f'
			for c=1:length(a)
				fprintf('\t%f', a(c))
			end
		end
	end
end

