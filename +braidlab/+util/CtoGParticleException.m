%CTOGPARTICLEEXEPTION   Exception thrown by crossingsToGenerators

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2016  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

classdef CtoGParticleException < MException
  properties
    Particles;
  end

  methods
    function obj = CtoGParticleException( id,particles )
       obj = obj@MException( id, ['Caused by particles: ' ...
                                   mat2str(sort(particles(:))) ]);
       obj.Particles = particles;
    end

    function val = get.Particles(obj)
      val = obj.Particles;
    end

    function obj = set.Particles(obj,val)
      obj.Particles = sort(val);
    end
  end

end
