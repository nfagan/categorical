function assert_ispair(data, labels)

%   ASSERT_ISPAIR -- Assert that inputs form a valid data, label pair.
%
%     assert_ispair( data, labels ); throws an error if `labels` is not an
%     fcat object, or if `data` and `labels` do not have the same number of
%     rows.
%
%     See also rowsmatch, rows, fcat
%
%     IN:
%       - `data` (/any/)
%       - `labels` (/any/)

assert( fcat.is(labels), 'labels must be an fcat object; was "%s".', class(labels) );
assert_rowsmatch( data, labels, 'data', 'labels' );

end