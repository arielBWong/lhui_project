
function [xl, n]   = llmatch_trueEval(xu, prob, nest_parameter)
% find xl for xu, use true evaluations
funh_obj        = @(x)lower_evalobj(xu, x, prob);
funh_con        = @(x)lower_evalcon(xu, x, prob);
param.gen       = nest_parameter.num_gen;
param.popsize   = nest_parameter.num_pop;
xlinit          = nest_parameter.xlinit; % can be []
n               = 0;
% whether EA + SQP or SQP
if nest_parameter.global_search
    nvar = prob.n_lvar;
    [xlstart, ~, ~, ~] ...
        = gsolver(funh_obj, nvar,  prob.xl_bl, prob.xl_bu, xlinit, funh_con, param);
    n            = n + param.gen * param.popsize;
    
else
    xlstart         = xlinit;
end

funh_con            = @(x)lower_evalcon2(xu, x, prob);
opts                = optimset('fmincon');
opts.Algorithm      = 'sqp';
opts.Display        = 'off';
opts.MaxFunctionEvaluations ...
                    = nest_parameter.maxLowerFE;
[xl, ~, ~, out] ...
                    = fmincon(funh_obj, xlstart, [], [],[], [],  ...
                                prob.xl_bl, prob.xl_bu, funh_con,opts);
n                   = n + out.funcCount;
end


function obj = lower_evalobj(xu, xl, prob)
n = size(xl, 1);
if n > 1
    xu = repmat(xu, n, 1);
end
[obj, ~] = prob.evaluate_l(xu, xl);
end

function con = lower_evalcon(xu, xl, prob)
n = size(xl, 1);
if n > 1
    xu = repmat(xu, n, 1);
end
[~, con] = prob.evaluate_l(xu, xl);
end

function [con, ceq] = lower_evalcon2(xu, xl, prob)
[~, con] = prob.evaluate_l(xu, xl);
ceq = [];
end