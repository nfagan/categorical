function execute(varargin)

%   EXECUTE -- Execute sequence of functions.
%
%     execute( func1, func2, func3 ); calls func1(), then func2(), then
%     func3().
%
%     See also conditional, attempt, try_warn

for i = 1:numel(varargin)
  varargin{i}();
end

end