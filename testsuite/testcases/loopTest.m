% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   https://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2026  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic          <mbudisic@gmail.com>
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
%   along with Braidlab.  If not, see <https://www.gnu.org/licenses/>.
% LICENSE>

classdef loopTest < matlab.unittest.TestCase

  properties
    l1       % Simple loop.
    l2       % Two loops (column vector).
    l2b      % Two loops with basepoint.
    b        % A braid for testing.
  end

  methods (TestMethodSetup)
    function createLoop(testCase)
      import braidlab.braid
      import braidlab.loop

      testCase.l1 = loop([1 -1 2 3]);
      testCase.l2 = loop([1 -1 2 3; 2 3 -1 2]);  % Two loops.
      testCase.l2b = loop([1 -1 2 3; 2 3 -1 2],'bp');  % Loops with basepoint.
      testCase.b = braid([1 -2 1 -2 1 -2]);
    end
  end

  methods (Test)

    %% Constructor tests

    function test_constructor_simple(testCase)
      % Test basic loop constructor from coordinates.
      l = testCase.l1;
      testCase.verifyEqual(l.coords,[1 -1 2 3]);
      testCase.verifyEqual(l.a,[1 -1]);
      testCase.verifyEqual(l.b,[2 3]);
      [a,b] = l.ab; %#ok<*PROP>
      testCase.verifyEqual(a,[1 -1]);
      testCase.verifyEqual(b,[2 3]);
    end

    function test_constructor_column_vector_transposes(testCase)
      % Test that column vector input is transposed.
      l = braidlab.loop(testCase.l1.coords.');
      testCase.verifyEqual(l.coords,[1 -1 2 3]);
    end

    function test_constructor_loop_vector(testCase)
      % Test column vector of loops.
      l = testCase.l2;
      c12 = l.coords;
      global BRAIDLAB_braid_nomex %#ok<*GVMIS>
      if ~isempty(BRAIDLAB_braid_nomex) && BRAIDLAB_braid_nomex
        testCase.verifyEqual(c12(1,:),[1 -1 2 3]);
      end
      testCase.verifyEqual(c12(2,:),[2 3 -1 2]);
      % All loops same dimension, so only one puncture size.
      testCase.verifyEqual(l.n,4);
      testCase.verifyEqual(l(2).n,4);
    end

    function test_constructor_loop_vector_with_basepoint(testCase)
      % Test column vector of loops with basepoint.
      l = testCase.l2b;
      c12 = l.coords;
      testCase.verifyEqual(c12(1,:),[1 -1 2 3]);
      testCase.verifyEqual(c12(2,:),[2 3 -1 2]);
      % With basepoint, # of moving punctures is n-1.
      testCase.verifyEqual(l.n,3);
      testCase.verifyEqual(l(2).n,3);
      testCase.verifyEqual(l.totaln,4);
      testCase.verifyEqual(l(2).totaln,4);
    end

    function test_constructor_canonical_with_basepoint(testCase)
      % Test canonical generating set of loops with basepoint.
      l = braidlab.loop(4,'bp');
      testCase.verifyEqual(l.coords,[0 0 0 -1 -1 -1]);
      % Try with different type.
      l = braidlab.loop(4,@int32,'bp');
      testCase.verifyEqual(l.coords,int32([0 0 0 -1 -1 -1]));
    end

    function test_constructor_canonical_no_basepoint(testCase)
      % Test canonical set of loops without basepoint.
      l = braidlab.loop(4,'nobasepoint');
      testCase.verifyEqual(l.coords,[0 0 -1 -1]);
      % Try with different type.
      l = braidlab.loop(4,'nobasepoint',@single);
      testCase.verifyEqual(l.coords,single([0 0 -1 -1]));
    end

    function test_constructor_canonical_vector(testCase)
      % Test vector of canonical loops.
      l = braidlab.loop(4,5,'bp');
      testCase.verifyEqual(l.coords,repmat([0 0 0 -1 -1 -1],5,1));

      % Vector of canonical loops without basepoint.
      l = braidlab.loop(4,5,'nobase');
      testCase.verifyEqual(l.coords,repmat([0 0 -1 -1],5,1));
    end

    function test_constructor_canonical_vector_typed(testCase)
      % Test vector of canonical loops with explicit type.
      l = braidlab.loop(4,5,'nobase','int32');
      testCase.verifyEqual(l.coords,repmat(int32([0 0 -1 -1]),5,1));
      l = braidlab.loop(4,5,'int64','nobase');
      testCase.verifyEqual(l.coords,repmat(int64([0 0 -1 -1]),5,1));
    end

    function test_constructor_copy_with_type(testCase)
      % Test copying a loop and converting type.
      l = braidlab.loop([1 2 3 4]);
      l2 = braidlab.loop(l,'int32');
      testCase.verifyEqual(l2.coords,int32([1 2 3 4]));
      l2 = braidlab.loop(l,@int32);
      testCase.verifyEqual(l2.coords,int32([1 2 3 4]));
    end

    function test_constructor_basepoint_equivalence(testCase)
      % Test that n-loops with basepoint have same coords as (n+1)-loops.
      lb0 = braidlab.loop(6,'basepoint',0);
      lb1 = braidlab.loop(5,'basepoint');
      testCase.verifyEqual(numel(lb0.coords),numel(lb1.coords), ...
                           ['n-loops with a basepoint should have ' ...
                            'as many coordinates as (n+1)-loops)']);
    end

    function test_constructor_enumeration(testCase)
      % Test creating enumerations of loops.
      global BRAIDLAB_braid_nomex %#ok<*GVMIS>
      if ~(~isempty(BRAIDLAB_braid_nomex) && BRAIDLAB_braid_nomex)
        enum = [1 1;1 2;2 1;2 2];
        lenum = braidlab.loop('enum',3,1,2);
        testCase.verifyEqual(lenum.coords,enum);
        lenum = braidlab.loop('enum',[1 1],[2 2]);
        testCase.verifyEqual(lenum.coords,enum);
        lenum = braidlab.loop('enum',[1 1],[2 2],@int32);
        testCase.verifyEqual(lenum.coords,int32(enum));
      end
    end

    %% Constructor error tests

    function test_constructor_error_too_many_dims(testCase)
      % Test that 3D array errors.
      testCase.verifyError(@()braidlab.loop(zeros(3,3,3)), ...
                           'BRAIDLAB:loop:loop:badarg');
    end

    function test_constructor_error_too_many_args(testCase)
      % Test that too many arguments errors.
      testCase.verifyError(@() braidlab.loop(3,2,3), ...
                           'BRAIDLAB:loop:loop:badarg');
      testCase.verifyError(@() braidlab.loop(3,2,3,'int','nobasepoint'), ...
                           'BRAIDLAB:loop:loop:badarg');
      testCase.verifyError(@() braidlab.loop([1 3],[2 3],'nobasepoint'), ...
                           'BRAIDLAB:loop:loop:badarg');
    end

    function test_constructor_error_vector_after_scalar(testCase)
      % Test that vector following scalar errors.
      testCase.verifyError(@() braidlab.loop(3,[2 3],'nobasepoint'), ...
                           'BRAIDLAB:loop:loop:badarg');
    end

    function test_constructor_error_too_few_punctures(testCase)
      % Test that too few punctures errors.
      testCase.verifyError(@() braidlab.loop(1), ...
                           'BRAIDLAB:loop:loop:toofewpunc');
    end

    function test_constructor_error_empty_coords(testCase)
      % Test that empty coordinate matrix errors.
      testCase.verifyError(@() braidlab.loop([]), ...
                           'BRAIDLAB:loop:loop:emptycoord');
      testCase.verifyError(@() braidlab.loop(zeros(1,0)), ...
                           'BRAIDLAB:loop:loop:emptycoord');
      testCase.verifyError(@() braidlab.loop(zeros(0,2)), ...
                           'BRAIDLAB:loop:loop:emptycoord');
    end

    function test_constructor_error_odd_length(testCase)
      % Test that odd number of columns errors.
      testCase.verifyError(@()braidlab.loop([1 2 3]), ...
                           'BRAIDLAB:loop:loop:oddlength');
      testCase.verifyError(@()braidlab.loop([1 2 3; 4 5 6]), ...
                           'BRAIDLAB:loop:loop:oddlength');
    end

    function test_constructor_error_mixed_datatypes(testCase)
      % Test that mixed data types in column vector errors (pre-R2025a).
      if isMATLABReleaseOlderThan('R2025a')
        testCase.verifyError( @()[...
            braidlab.loop([1,2,3,4], @double) ; ...
            braidlab.loop([1,2,3,4], @int32) ], ...
                              'BRAIDLAB:loop:vertcat:mixeddatatypes');
      end
    end

    function test_constructor_error_mixed_puncture_count(testCase)
      % Test that different puncture counts in column vector errors.
      testCase.verifyError( @()[...
          braidlab.loop([1,2,3,4,5,6], @double) ; ...
          braidlab.loop([1,2,3,4], @double) ], ...
                            'BRAIDLAB:loop:vertcat:mixedpuncturecount');
    end

    function test_constructor_error_stacking_nonloops(testCase)
      % Test that stacking loop with non-loop errors.
      lb0 = braidlab.loop(6,'basepoint',0);
      lb1 = braidlab.loop(5,'basepoint');
      testCase.verifyError( @()[ lb0; lb1.coords ], ...
                            'BRAIDLAB:loop:vertcat:nonloops');
    end

    function test_constructor_error_mixed_basepoints(testCase)
      % Test that stacking loops with different basepoints errors.
      lb0 = braidlab.loop(6,'basepoint',0);
      lb1 = braidlab.loop(5,'basepoint');
      testCase.verifyError( @()[ lb0; lb1 ], ...
                            'BRAIDLAB:loop:vertcat:mixedbasepoints');
    end

    function test_constructor_error_row_vector(testCase)
      % Test that row vector of loops errors.
      testCase.verifyError( @()[...
          braidlab.loop(testCase.l2.coords(1,:)) , ...
          braidlab.loop(testCase.l2.coords(2,:))], ...
                            'BRAIDLAB:loop:noarrays');
    end

    %% Subscript and indexing tests

    function test_subscripts_assignment(testCase)
      % Test subscript assignment for loop vectors.
      l = braidlab.loop(zeros(2,4),'bp');
      l(2) = braidlab.loop(3,'bp');
      testCase.verifyEqual(l.coords(:),[0 0 0 0 0 -1 0 -1]');
      testCase.verifyEqual(l.n,3);
      testCase.verifyEqual(l(2).n,3);
      testCase.verifyEqual(l(2),braidlab.loop(3,'bp'));
    end

    function test_subscripts_create_by_index(testCase)
      % Test creating loops by accessing an index.
      l2(2) = braidlab.loop(3,'bp');
      l = braidlab.loop(zeros(2,4),'bp');
      l(2) = braidlab.loop(3,'bp');
      testCase.verifyEqual(l,l2);
    end

    function test_subscripts_assign_coords(testCase)
      % Test assigning coordinates directly.
      l2(2) = braidlab.loop(3,'bp');
      l2(2).coords = [1 2 3 4];
      testCase.verifyEqual(l2(2),braidlab.loop([1 2 3 4],'bp'));
    end

    function test_subscripts_grow_loop_vector(testCase)
      % Test growing loop vector by assigning to new index.
      l2(2) = braidlab.loop(3,'bp');
      l2(2).coords = [1 2 3 4];
      l2(3).coords = -[1 2 3 4];
      testCase.verifyEqual(l2(3),braidlab.loop(-[1 2 3 4],'bp'));
    end

    function test_subscripts_change_single_coord(testCase)
      % Test changing single coordinate.
      l2(2) = braidlab.loop(3,'bp');
      l2(3).coords = -[1 2 3 4];
      l2(3).coords(1) = 1;
      testCase.verifyEqual(l2(3),braidlab.loop(-[-1 2 3 4],'bp'));
    end

    function test_subscripts_change_range(testCase)
      % Test changing range of coordinates.
      l2(2) = braidlab.loop(3,'bp');
      l2(2).coords = [1 2 3 4];
      l2(2).coords(3:end) = [-6 -7];
      testCase.verifyEqual(l2(2),braidlab.loop([1 2 -6 -7],'bp'));
    end

    function test_subscripts_extend_by_another(testCase)
      % Test extending loop array by another loop array.
      l = braidlab.loop(4,3,'bp');
      l2 = braidlab.loop(4,2,'bp');
      l(4:5) = l2;  % l has 3 rows initially.
      testCase.verifyEqual(l,braidlab.loop(repmat([0 0 0 -1 -1 -1],5,1),'bp'));
    end

    %% Property access tests

    function test_property_n(testCase)
      % Test n property (number of moving punctures).
      l = braidlab.loop([1 2 3 4]);
      testCase.verifyEqual(l.n,4);

      l = braidlab.loop([1 2 3 4],'bp');
      testCase.verifyEqual(l.n,3);
    end

    function test_property_totaln(testCase)
      % Test totaln property (total punctures including basepoint).
      l = braidlab.loop([1 2 3 4]);
      testCase.verifyEqual(l.totaln,4);

      l = braidlab.loop([1 2 3 4],'bp');
      testCase.verifyEqual(l.totaln,4);
    end

    function test_property_a_and_b(testCase)
      % Test a and b coordinate properties.
      l = braidlab.loop([1 -1 2 3 4 5]);
      testCase.verifyEqual(l.a,[1 -1 2]);
      testCase.verifyEqual(l.b,[3 4 5]);
    end

    function test_property_ab(testCase)
      % Test ab method returning both a and b.
      l = braidlab.loop([1 -1 2 3 4 5]);
      [a,b] = l.ab;
      testCase.verifyEqual(a,[1 -1 2]);
      testCase.verifyEqual(b,[3 4 5]);
    end

    function test_property_basepoint(testCase)
      % Test basepoint property.
      l = braidlab.loop([1 2 3 4]);
      testCase.verifyEqual(l.basepoint,0);

      l = braidlab.loop([1 2 3 4],'bp');
      testCase.verifyEqual(l.basepoint,4);
    end

    %% minlength method tests

    function test_minlength_single(testCase)
      % Test minlength on single loop.
      testCase.verifyEqual(testCase.l1.minlength,22);
      testCase.verifyEqual(minlength(testCase.l1),22);
    end

    function test_minlength_vector(testCase)
      % Test minlength on loop vector.
      l = testCase.l2;
      testCase.verifyEqual(l.minlength,[22;24]);
      testCase.verifyEqual(l(1).minlength,22);
      testCase.verifyEqual(l(2).minlength,24);
      testCase.verifyEqual(minlength(l),[22;24]);
      testCase.verifyEqual(minlength(l(1)),22);
      testCase.verifyEqual(minlength(l(2)),24);
    end

    function test_minlength_with_basepoint(testCase)
      % Test minlength on loops with basepoint.
      l = testCase.l2b;
      testCase.verifyEqual(l.minlength,[22;24]);
      testCase.verifyEqual(l(1).minlength,22);
      testCase.verifyEqual(l(2).minlength,24);
      testCase.verifyEqual(minlength(l),[22;24]);
    end

    function test_minlength_canonical(testCase)
      % Test minlength on canonical loop.
      l = braidlab.loop(4);
      testCase.verifyEqual(minlength(l),6);
    end

    %% intaxis method tests

    function test_intaxis_single(testCase)
      % Test intaxis on single loop.
      testCase.verifyEqual(testCase.l1.intaxis,16);
      testCase.verifyEqual(intaxis(testCase.l1),16);
    end

    function test_intaxis_vector(testCase)
      % Test intaxis on loop vector.
      l = testCase.l2;
      testCase.verifyEqual(l.intaxis,[16;16]);
      testCase.verifyEqual(l(1).intaxis,16);
      testCase.verifyEqual(l(2).intaxis,16);
      testCase.verifyEqual(intaxis(l),[16;16]);
      testCase.verifyEqual(intaxis(l(1)),16);
      testCase.verifyEqual(intaxis(l(2)),16);
    end

    function test_intaxis_with_basepoint(testCase)
      % Test intaxis on loops with basepoint.
      l = testCase.l2b;
      testCase.verifyEqual(l.intaxis,[16;16]);
      testCase.verifyEqual(l(1).intaxis,16);
      testCase.verifyEqual(l(2).intaxis,16);
      testCase.verifyEqual(intaxis(l),[16;16]);
    end

    %% intersec method tests

    function test_intersec_single(testCase)
      % Test intersection numbers on single loop.
      l = testCase.l1;
      expected = [5 7 5 3 12 8 2];
      testCase.verifyEqual(intersec(l),expected);
      testCase.verifyEqual(l.intersec,expected);
    end

    function test_intersec_vector(testCase)
      % Test intersection numbers on loop vector.
      l = testCase.l2;
      inters = [5 7 5 3 12 8 2; 3 7 2 8 8 10 6];
      testCase.verifyEqual(intersec(l),inters);
      testCase.verifyEqual(l.intersec,inters);
      testCase.verifyEqual(l(1).intersec,inters(1,:));
      testCase.verifyEqual(l(2).intersec,inters(2,:));
      testCase.verifyEqual(intersec(l(1)),inters(1,:));
      testCase.verifyEqual(intersec(l(2)),inters(2,:));
    end

    function test_intersec_with_basepoint(testCase)
      % Test intersection numbers on loops with basepoint.
      l = testCase.l2b;
      inters = [5 7 5 3 12 8 2; 3 7 2 8 8 10 6];
      testCase.verifyEqual(intersec(l),inters);
      testCase.verifyEqual(l.intersec,inters);
      testCase.verifyEqual(l(1).intersec,inters(1,:));
      testCase.verifyEqual(l(2).intersec,inters(2,:));
    end

    %% nested method tests

    function test_nested_not_nested(testCase)
      % Test nested level of non-nested loop is 0.
      l = braidlab.loop([1 2 3 4]);
      testCase.verifyEqual(nested(l),0);
    end

    function test_nested_doubled(testCase)
      % Test nested level of doubled loop is 1.
      l = braidlab.loop([2 4 6 8]);
      testCase.verifyEqual(nested(l),1);
    end

    function test_nested_tripled(testCase)
      % Test nested level of tripled loop is 2.
      l = braidlab.loop([3 6 9 12]);
      testCase.verifyEqual(nested(l),2);
    end

    function test_nested_vector(testCase)
      % Test nested on loop vector.
      l = braidlab.loop([1 2 3 4; 2 4 6 8]);
      testCase.verifyEqual(nested(l),[0;1]);
    end

    %% char method tests

    function test_char_simple(testCase)
      % Test char conversion for simple loop.
      l = braidlab.loop([1 -1 2 3]);
      str = char(l);
      testCase.verifyTrue(contains(str,'(('));
      testCase.verifyTrue(contains(str,'))'));
    end

    function test_char_with_basepoint(testCase)
      % Test char conversion for loop with basepoint.
      l = braidlab.loop([1 -1 2 3],'bp');
      str = char(l);
      testCase.verifyTrue(contains(str,'*'));
    end

    function test_char_loop_vector(testCase)
      % Test char conversion for loop vector.
      l = testCase.l2;
      str = char(l);
      testCase.verifyTrue(size(str,1) == 2);
    end

    %% getgraph method tests

    function test_getgraph_returns_sparse(testCase)
      % Test that getgraph returns sparse adjacency matrix.
      l = braidlab.loop([1 0 -1 1]);
      [A,Lp] = getgraph(l);
      testCase.verifyTrue(issparse(A));
      testCase.verifyTrue(issparse(Lp));
    end

    function test_getgraph_error_multiloop(testCase)
      % Test that getgraph errors on loop vector.
      l = testCase.l2;
      testCase.verifyError(@()getgraph(l), ...
                           'BRAIDLAB:loop:getgraph:onlyscalar');
    end

    %% plot method tests

    function test_plot_error_multiloop(testCase)
      % Test that plot errors on loop vector.
      lv = braidlab.loop([0 1 1 1; 0 0 1 1]);
      testCase.verifyError(@()plot(lv), ...
                           'BRAIDLAB:loop:plot:multiloop');
    end

    %% Braid action on loop tests

    function test_braid_action_empty_braid(testCase)
      % Test action of empty braid on loop.
      for emptyMatrix = { [], zeros(1,0) }
        em = emptyMatrix{1};

        l0 = braidlab.loop(3);
        l = braidlab.braid(em,3)*l0;
        testCase.verifyEqual(l,l0);
      end
    end

    function test_braid_action_empty_braid_with_basepoint(testCase)
      % Test action of empty braid on loop with basepoint.
      for emptyMatrix = { [], zeros(1,0) }
        em = emptyMatrix{1};

        l0 = braidlab.loop(3,'bp');
        l = braidlab.braid(em,3)*l0;
        testCase.verifyEqual(l,l0);

        l0 = braidlab.loop(3,'bp',1);
        l = braidlab.braid(em,3)*l0;
        testCase.verifyEqual(l,l0);
      end
    end

    function test_braid_action_empty_braid_different_n(testCase)
      % Test action of empty braid on loop with different n.
      for emptyMatrix = { [], zeros(1,0) }
        em = emptyMatrix{1};

        l0 = braidlab.loop(5);
        l = braidlab.braid(em,3)*l0;
        testCase.verifyEqual(l,l0);

        l0 = braidlab.loop(5,'bp');
        l = braidlab.braid(em,3)*l0;
        testCase.verifyEqual(l,l0);

        l0 = braidlab.loop(5,'bp',1);
        l = braidlab.braid(em,3)*l0;
        testCase.verifyEqual(l,l0);
      end
    end

    function test_braid_action_error_too_many_strings(testCase)
      % Test that braid with more strings than loop errors.
      l0 = braidlab.loop(5,'bp',1);
      testCase.verifyError(@() braidlab.braid([],7)*l0, ...
                           'BRAIDLAB:braid:mtimes:badgen');
    end

    function test_braid_action_error_unsupported_object(testCase)
      % Test that braid action on unsupported object errors.
      testCase.verifyError(@() braidlab.braid([],7)*3, ...
                           'BRAIDLAB:braid:mtimes:badobject');
    end

    function test_braid_action_error_move_basepoint(testCase)
      % Test that moving basepoint (puncture 1) errors.
      l0 = braidlab.loop(5,'bp',1);
      testCase.verifyError(@() braidlab.braid(1)*l0, ...
                           'BRAIDLAB:braid:mtimes:fixbp');
    end

    function test_braid_action_sigma1_squared_ok(testCase)
      % Test that [1 1] is ok since puncture 1 not permuted.
      l0 = braidlab.loop(5,'bp',1);
      testCase.verifyEqual(braidlab.braid([1 1])*l0, ...
                           braidlab.loop([1  0  0  0  1 -1 -1 -1],'bp',1));
    end

    function test_braid_action_on_nloops_with_basepoints(testCase)
      % Test braid action on multiple loops with basepoints.
      B = braidlab.braid([2,1,-1,-2,-1],4);
      Coords = [1,0,-1,1; 2,1,1,1; -1,1,-2,3];
      Nloops = size(Coords,1);

      % Compute using MATLAB algorithm, one-by-one.
      global BRAIDLAB_braid_nomex %#ok<*GVMIS>
      oldSetting = BRAIDLAB_braid_nomex;
      BRAIDLAB_braid_nomex = true;

      INmatlab = cell(Nloops, 1);
      for k = 1:Nloops
        INmatlab{k} = braidlab.loop(Coords(k,:),'Basepoint');
      end
      OUTmatlab = cell(Nloops, 1);
      for k = 1:Nloops
        OUTmatlab{k} = B*INmatlab{k};
      end

      OUTmatlabMat = zeros(Nloops, size(Coords,2));
      for k = 1:Nloops
        OUTmatlabMat(k,:) = OUTmatlab{k}.coords;
      end

      % Restore setting.
      BRAIDLAB_braid_nomex = oldSetting;

      INmat = braidlab.loop(Coords,'Basepoint');
      OUTmat = B*INmat;

      % Compare.
      testCase.verifyTrue( all( OUTmatlabMat(:) == OUTmat.coords(:) ) );
    end

    %% MEX vs MATLAB algorithm tests

    function test_mex_vs_matlab_algorithms(testCase)
      % Test that MEX and MATLAB algorithms match.
      global BRAIDLAB_braid_nomex %#ok<*GVMIS>
      if ~isempty(BRAIDLAB_braid_nomex) && BRAIDLAB_braid_nomex
        testCase.assumeTrue(false, ...
          'Skipping MEX-specific test when BRAIDLAB_braid_nomex is set.');
      end

      B = braidlab.braid([2,1,-1,-2,-1],4);
      Coords = [1,0,-1,1; 2,1,1,1; -1,1,-2,3];
      Nloops = size(Coords,1);

      for types = {'int32','double','vpi', 'int64'}
        t = types{1};

        % Compute using MATLAB algorithm.
        oldSetting = BRAIDLAB_braid_nomex;
        BRAIDLAB_braid_nomex = true;

        INmatlab = cell(Nloops, 1);
        for k = 1:Nloops
          INmatlab{k} = braidlab.loop(Coords(k,:));
        end
        OUTmatlab = cell(Nloops, 1);
        for k = 1:Nloops
          OUTmatlab{k} = B*INmatlab{k};
        end

        OUTmatlabMat = zeros(Nloops, size(Coords,2));
        for k = 1:Nloops
          OUTmatlabMat(k,:) = OUTmatlab{k}.coords;
        end

        % Restore and compute with MEX.
        BRAIDLAB_braid_nomex = oldSetting;

        INmex = braidlab.loop(Coords,t);
        OUTmex = B*INmex;

        % Compare.
        testCase.verifyTrue( ...
            all( double(OUTmatlabMat(:)) == double(OUTmex.coords(:)) ), ...
            sprintf('Testing type %s',t) );
      end
    end

    %% loopcoords method tests

    function test_loopcoords_basic(testCase)
      % Test basic loop coordinates computation.
      br = braidlab.braid([1],3);
      l = loopcoords(br);
      testCase.verifyClass(l,'braidlab.loop');
    end

    function test_loopcoords_identity(testCase)
      % Test loop coordinates of identity braid.
      br = braidlab.braid([],4);
      l = loopcoords(br);
      testCase.verifyClass(l,'braidlab.loop');
    end

    function test_loopcoords_nontrivial(testCase)
      % Test loop coordinates for nontrivial braid.
      br = braidlab.braid([1 2 1],4);
      l = loopcoords(br);
      testCase.verifyClass(l,'braidlab.loop');
      testCase.verifyTrue(~isempty(l.coords));
    end

    function test_loopcoords_types(testCase)
      % Test loop coordinates with various types.
      br = braidlab.braid([1 -2 3]);

      l = loopcoords(br);
      testCase.verifyEqual(l.coords,int64([1 -2 1 -2 -2 2]));
      l = loopcoords(br,'double');
      testCase.verifyEqual(l.coords,[1 -2 1 -2 -2 2]);
      l = loopcoords(br,'int32');
      testCase.verifyEqual(l.coords,int32([1 -2 1 -2 -2 2]));
      l = loopcoords(br,'vpi');
      testCase.verifyEqual(l.coords,vpi([1 -2 1 -2 -2 2]));
    end

    function test_loopcoords_basepoint_options(testCase)
      % Test loop coordinates with different basepoint options.
      br = braidlab.braid([1 -2 3]);

      braidlab.prop('LoopCoordsBasePoint','left');
      l = loopcoords(br);
      testCase.verifyEqual(l.coords,int64([-1 2 -3 0 0 0]));

      braidlab.prop('LoopCoordsBasePoint','dehornoy');
      l = loopcoords(br);
      testCase.verifyEqual(l.coords,int64([1 -2 3 0 0 0]));

      braidlab.prop('reset');
    end

    function test_loopcoords_overflow_warning(testCase)
      % Test that overflow warning is raised for large braids.
      br = braidlab.braid(repmat([1 -2],[1 50]));
      testCase.verifyWarning(@() br.istrivial, ...
                             'BRAIDLAB:braid:loopcoords:overflow');
      testCase.verifyWarning(@() br == br, ...
                             'BRAIDLAB:braid:loopcoords:overflow');
    end

    %% complexity method tests

    function test_complexity_basic(testCase)
      % Test basic complexity computation.
      br = braidlab.braid([1 2],4);
      c = complexity(br);
      testCase.verifyTrue(isnumeric(c));
    end

    function test_complexity_identity(testCase)
      % Test complexity of identity braid is zero.
      br = braidlab.braid([],4);
      c = complexity(br);
      testCase.verifyEqual(c,0);
    end

    function test_complexity_dw_option(testCase)
      % Test complexity with DW option.
      br = braidlab.braid([1 2],4);
      c = complexity(br,'DW');
      testCase.verifyTrue(isnumeric(c));
    end

    function test_complexity_returns_loop(testCase)
      % Test that complexity returns loop when requested.
      br = braidlab.braid([1 2],4);
      [c,bE] = complexity(br);
      testCase.verifyTrue(isnumeric(c));
      testCase.verifyClass(bE,'braidlab.loop');
    end

    %% Overflow tests

    function test_loop_length_overflow(testCase)
      % Test that integer overflow in loop length is detected.
      mybraid = testCase.b;

      expEntropy = entropy(mybraid);
      l = loopcoords(mybraid);

      tol = 1e-2; % Generous tolerance.

      loopEntropy = @(N)(log( double(minlength(mybraid^N*l)) ) ...
                         - log( double(minlength(l)) ) ) / N;

      % Sanity check at small iteration count.
      Niter = 5;
      err = ['Manual and built-in computations of entropy do not match' ...
             ' at (small) Niter=%d.'];
      testCase.verifyEqual(loopEntropy(Niter), expEntropy, 'AbsTol', tol, ...
                           sprintf(err, Niter));

      % Actual overflow test.
      Niter = 100;
      testCase.verifyError(@()loopEntropy(Niter),...
                           'BRAIDLAB:braid:sumg:overflow');
    end

  end
end
