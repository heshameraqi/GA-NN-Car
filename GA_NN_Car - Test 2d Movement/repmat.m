function B = repmat(A,M,N)

m = length(A(:,1));

if (m == 1 && N == 1)
    B = A(ones(M, 1), :);
else
    B = A(:, ones(N, 1));
end

end
