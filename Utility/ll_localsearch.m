function [match_xl, flag, num_eval] = ll_localsearch(best_x, best_f, best_c, s, xu, prob)
% This method is part of local search algorithm
% receives starting point
%
% input:
%       best_x: starting point
%       best_f: starting point's objective value
%       best_c: starting point's constraint value
%       s: flag, whether this solution is feasible
% output:
%       match_xl: the final matching xl for a given xu
%       flag: whether match_xl is feasible
%       num_eval: number of function evaluations consumed in local search
%-----------------------------------------------------------


% give starting point to local search
fmin_obj = @(x)llobjective(x, xu, prob);
fmin_con = @(x)llconstraint(x, xu, prob);
opts = optimset('fmincon');
opts.Algorithm = 'sqp';
opts.Display = 'off';
opts.MaxFunctionEvaluations = 100;
[newxl, newfl, ~, output] = fmincon(fmin_obj, best_x, [], [],[], [],  ...
    prob.xl_bl, prob.xl_bu, fmin_con,opts);

[~, newcl] = prob.evaluate_l(xu, newxl); % being lazy

toselect_x = [best_x; newxl];
toselect_f = [best_f; newfl];
toselect_c = [best_c; newcl];

% decide which xl to return back to upper level
% compatible with unconstraint problem
[match_xl, ~, ~, flag, ~] =  localsolver_startselection(toselect_x, toselect_f, toselect_c);
num_eval = output.funcCount; 

end


%objective wrapper for true evaluation
function f = llobjective(xl, xu, prob)
[f, ~] = prob.evaluate_l(xu, xl);
end

%constraint wrapper
function [c, ceq]  = llconstraint(xl, xu, prob)
[~, c] = prob.evaluate_l(xu, xl);
ceq = [];
end
