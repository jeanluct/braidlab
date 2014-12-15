classdef B < ns.A

  methods
    function obj = B(b)
      obj = obj@ns.A(b);
    end

    function a = A(obj)
      a = conv_to_A(obj);
    end

    function c = dostuff(obj)
      c = conv_to_A(obj);
    end
  end

  methods (Access = private)
    function a = conv_to_A(obj)
      disp('converting B to A.')
      a = ns.A(obj.dat);
    end
  end

end
