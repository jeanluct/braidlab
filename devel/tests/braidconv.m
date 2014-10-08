% Test class: braid with user-defined convention for left-right and
% clockwise/anticlockwise.

classdef braidconv
  properties (Dependent)
    word
  end
  properties %(Access=private)
    lr = 1;    % 1 for left-to-right, -1 for right-to-left.
    cw = 1;    % 1 for clockwise, -1 for counterclockwise.
               % Maybe this should only be in 'loop'?
               % Or only used in braid.mtimes?
    pword
  end

  methods

    function obj = braidconv(w)
      obj.word = w;
    end

    function obj = set.word(obj,value)
      if obj.lr == 1
        obj.pword = obj.cw*value;
      else
        obj.pword = flip(obj.cw*value);
      end
    end

    function value = get.word(obj)
      if obj.lr == 1
        value = obj.cw*obj.pword;
      else
        value = flip(obj.cw*obj.pword);
      end
    end
  end % methods
end % classdef
