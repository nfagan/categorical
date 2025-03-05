function [t, I] = summarize_within(T, within, vs, fs)

%   SUMMARIZE_WITHIN -- Collapse within variables.
%
%     y = summarize_within( t, within_vars, data_var, f )
%
%     applies function `f` to subsets of the variable `data_var` given by
%     the unique rows of table `t`, considering  `within_vars`. This 
%     collapses across the remaining variabes in `t`. `f` must return an 
%     array whose first-dimension size is equal to 1.
%
%     y = summarize_within( t, across_vars, data_vars, fs )
%
%     for the string array `data_vars` and cell array of function handles
%     `fs` applies functions to corresponding variables in `data_vars`.
%
%     //  EX
%
%     load('carbig');
%     t = rmmissing(table(Model, Origin, MPG, Displacement, Horsepower, Mfg));
%     % compute average horsepower for each model, mpg, and displacement
%     summarize_within(t, {'Model', 'MPG', 'Displacement'}, 'Horsepower', @mean)
%
%     See also summarize_across, findeach, rowsets, groupi, splitapply

[within, vs, fs] = summarize_check( within, vs, fs );
[I, t] = summarize_impl( T, setdiff(within, vs), vs, fs );

end