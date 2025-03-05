function [I, t] = summarize_impl(T, select_vars, vs, fs)

[I, t] = rowgroups( T(:, select_vars) );
for i = 1:numel(vs)
  t.(vs(i)) = cate1( rowifun(fs{i}, I, T.(vs(i)), 'un', 0) );
end

end