classdef Aclass
  properties
    w
  end

  methods

  function a = Aclass(b)
      if nargin > 0
	a(size(b,1)) = Aclass;
	for k = 1:size(b,1)
	  a(k).w = b(k,:);
	end
      end
    end
  end
end
