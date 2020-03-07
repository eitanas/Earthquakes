function [ B ] = tri_up_to_symmetric_square( A )
%gets  a triangular matrix and returns a symmetric square matrix

[n,m]=size(A);
B=A'+A;
B(1:n+1:end)=diag(A);
%}

%B = (A+A') - eye(size(A,1)).*diag(A);

end

