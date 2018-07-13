%   ROWOPERATIONS -- Apply function to indexed subsets of rows of data.
%
%     A rowoperation applies a function to subsets of rows of data. 
%     Usually, but not always, the function is one that collapses rows to a 
%     single row -- e.g., by taking a mean or median across rows.
%
%     The basic form of a rowoperation is A = func( data, I ), where `data`
%     is a 2-d double matrix, and `I` is a cell array of uint64 indices.
%     Each index in `I` identifies a subset of rows in `data` across which
%     `func` will be applied. 
%
%     For arrays with greater than 2 dimensions or non-double data, the 
%     generic `rowop` function is available. This function also accepts
%     `data` and a cell array of indices `I`, but also a handle to the
%     function that will operate on the data-slice.
%
%     EX //
%
%     f = fcat.example();
%     data = fcat.example( 'smalldata' );
%     I = findall( f, {'dose', 'monkey'} );
%     mean1 = rowmean( data, I );
%     mean2 = rowop( data, I, @(x) mean(x, 1) );
%     assert( isequaln(mean1, mean2) );
%
%     See also rowop, rowmean, fcat