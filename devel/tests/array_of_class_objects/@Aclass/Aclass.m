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

  function value = getw(obj)
    value = vertcat(obj.w);
  end

  function disp(obj)
    for i = 1:length(obj)
      disp(['(( ' num2str(obj(i).w) ' ))']);
    end
  end
end
