%%
cat_profile_append

%  categorical:   6249.876 (ms) [10000]
%  fcat:          2063.288 (ms) [10000]
%  fcat: (subs)   3008.521 (ms) [10000]
%  fcat: (assign) 777.115 (ms) [10000]
%  fcat: (assign) 135.779 (ms) [10000]>> 

%%
cat_profile_assign

%  categorical (subscripts): 17.003 (ms)
%  fcat        (subscripts): 15.365 (ms)
%  fcat      (cellstr subs): 402.374 (ms)
%  fcat      (cellstr subs): 416.634 (ms)
%  categorical     (direct): 2.317 (ms)
%  fcat   (direct, subsref): 7.407 (ms)
%  fcat  (direct, function): 5.740 (ms)>> 
%%
cat_profile_assign_random

%  categorical (subscripts): 37.989 (ms)
%  fcat        (subscripts): 217.588 (ms)>> 
%%
cat_profile_assign_self

%  fcat        (loop): 12.429 (ms)
%  categorical (loop): 409.212 (ms)
%  fcat        (subs): 8.498 (ms)
%  categorical (subs): 0.681 (ms)>>
%%
cat_profile_assign_subset

%  fcat      (loop, function): 2.057 (ms)
%  categorical         (loop): 10.830 (ms)
%  fcat            (function): 301.251 (ms)
%  fcat                (copy): 186.854 (ms)
%  categorical               : 35.175 (ms)>> 
%%
cat_profile_create

%  categorical: 604.529 (ms) [10]
%  fcat:        289.123 (ms) [10]>> 

%%
cat_profile_keepeach

%  fcat:          12.844 (ms)
%  categorical:   50.168 (ms)>> 
%%
cat_profile_keep
% categorical (keep): 307.613 (ms)
%  fcat        (keep): 413.854 (ms)>> 

%%
cat_profile_setcats
%  fcat:        209.363 (ms) [1000]
%  fcat: (subs) 241.487 (ms) [1000]>> 

