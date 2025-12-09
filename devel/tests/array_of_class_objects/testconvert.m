n = 60000; k = 20;
l = zeros(n,k);

% Convert to a cell array of Aclass objects,
tic
sz = size(l,1);
l2 = mat2cell(l,ones(1,sz),k);
l2 = reshape(cellfun(@Aclass,l2,'UniformOutput',0),[sz 1]);
toc

% Convert to a vector of Aclass objects,
tic
l3 = Aclass(l);
toc
