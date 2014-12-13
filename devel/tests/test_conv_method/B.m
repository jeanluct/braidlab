classdef B < A

  methods
    function obj = B(b)
      obj = obj@A(b);
    end

    function a = A(b)
      disp('converting B to A.')
      a = A(b.dat);
    end

    function c = dostuff(obj)
      c = A(obj.dat);
    end
  end
end
