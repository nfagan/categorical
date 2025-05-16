function [I, L0, L1, L2] = rowsets3(X, l0, l1, l2, varargin)

%   ROWSETS3 -- Partition row indices into subsets, with 3 levels of nesting.
%
%     [I, C1, C2, C3] = rowsets3( X, cols1, cols2, cols3 )
%     returns indices of unique rows of the 2D array `X`, evaluated over
%     the union of columns identified by cols1, col2, and cols3. 
%
%     For example, if `X` is a table, then column indices could be strings 
%     identifying variables in `X`. Or, if `X` is a double matrix, then 
%     indices could be integers selecting columns of `X`.
%
%     `C1`, ... contain the unique rows of `cols1`, ... columns of `X`, and
%     rows of each correspond to elements of `I`.
%
%     //  EX.
%     t = struct2table( load('carbig') );
%     [I, pl, gl, xl] = rowsets3( t, "Origin", "Cylinders", "when", Mask=~isnan(t.MPG) )
%     % plot
%     figure(1); clf; axs = plots.summarized2( t.MPG, I, pl, gl, xl, Type='bar' );
%     ylabel( axs, 'Average MPG' );
%
%     See also rowsetsn, rowgroups, table, plots.summarized2

[I, L] = rowsetsn( X, {l0, l1, l2}, varargin{:} );
[L0, L1, L2] = deal( L{:} );

end