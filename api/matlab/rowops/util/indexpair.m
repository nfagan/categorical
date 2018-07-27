function [data, labels] = indexpair(data, labels, I)

%   INDEXPAIR -- Keep rows of data and labels.
%
%     data = indexpair( dat, labs, I ) keeps rows of `dat` and `labs`
%     identified by the uint64 index vector `I`, and returns the `data`.
%     Unless explicitly copied, `labs` is modified to match the rows of 
%     `data`.
%
%     [..., labels] = indexpair(...) also returns the kept labels. Use this
%     additional output if passing a copy of `labs` to the function.
%
%     See also fcat, assert_ispair
%
%     IN:
%       - `data` (/T/)
%       - `labels` (fcat)
%     OUT:
%       - `data` (/T/)
%       - `labels` (fcat)

assert_ispair( data, labels );

data = rowref( data, I );
keep( labels, I );

end