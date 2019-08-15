function pair = mkpair(data, labels)

%   MKPAIR -- Make data-label pair.
%
%     pair = mkpair( data, labels ); returns a scalar struct with fields
%     'data' and 'labels' set to the input `data` and `labels`,
%     respectively. `data` must have the same number of rows as `labels`,
%     and `labels` must be an fcat object.
%
%     See also fcat, assert_ispair, indexpair, copypair

assert_ispair( data, labels );

pair = struct();
pair.data = data;
pair.labels = labels;

end