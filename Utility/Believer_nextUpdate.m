function[best_x, info] = Believer_nextUpdate(train_x, train_y, xu_bound, xl_bound, ...
    num_pop, num_gen, train_c, normhn, varargin)
%----------------------------------
if ~isempty(varargin)
    fighn    = varargin{1};
end

if size(train_y, 2) > 1
    train_y_norm = normhn(train_y);
else
    train_y_norm = normalization_z(train_y);
end

param.GPR_type   = 2;
param.no_trials  = 5;
krg_obj          = Train_GPR(train_x, train_y_norm, param);

if ~isempty(train_c)
    krg_con      = Train_GPR(train_x, train_c, param); else
    krg_con      = {};
end

arc_obj.x        = train_x;
arc_obj.muf      = train_y_norm;

arc_con.x        = train_x;
arc_con.muf      = train_c;

% KB objective function
funh_obj         = @(x)Predict_GPR(krg_obj, x, param, arc_obj);
if ~isempty(train_c)
    funh_con     = @(x)Predict_GPR(krg_con, x, param, arc_con); else
    funh_con     = @(x)NoConstraint(x);
end

param_ea.gen     = num_gen;
param_ea.popsize = num_pop;

l_nvar           = size(train_x, 2);
[~,~,~, archive] = gsolver(funh_obj, l_nvar,  xl_bound, xu_bound, [], funh_con, param_ea);
newx             = archive.pop_last.X(1, :);
[best_x]         = surrogate_localsearch(newx, xu_bound, xl_bound, krg_obj, krg_con, arc_obj, arc_con);


%-----
info                = struct();
info.krg            = krg_obj;
info.arc_obj        = arc_obj;     
% info.stable = true;
if  ~isempty(train_c)
    info.krgc       = krg_con;
    info.arc_c      = arc_con ;
else
    info.krgc       = {};
    info.arc_c      = [];
end
%----
end

function f = NoConstraint(x)
f = [];
end

function[newx] = surrogate_localsearch(newx, xu_bound, xl_bound, krg_obj, krg_con, arc_obj, arc_con)
%----------------------------

if length(krg_obj) > 1
    % no local search for MO
    fprintf('no local surrogate search for MO \n');
     return
end

param.GPR_type   = 2;
param.no_trials  = 5;
% KB objective function
funh_obj         = @(x)Predict_GPR(krg_obj, x, param, arc_obj);
funh_con         = @(x)Predict_GPR(krg_con, x, param, arc_con);


opts                        = optimset('fmincon');
opts.Algorithm              = 'sqp';
opts.Display                = 'off';
opts.MaxFunctionEvaluations = 100;
[newx_local, newx_localf, ~, ~] ...
                            = fmincon(funh_obj, newx, [], [],[], [],  ...
                                xl_bound,  xu_bound, funh_con, opts);

newx_localc                 = Predict_GPR(krg_con, newx_local, param, arc_con);                           

newf                        = Predict_GPR(krg_obj, newx, param, arc_obj);
newc                        = Predict_GPR(krg_con, newx, param, arc_con);

% decide which x to use
xx                         = [newx; newx_local];
ff                         = [newf; newx_localf];
cc                         = [newc; newx_localc];
[newx, ~, ~, ~, ~]         = localsolver_startselection(xx,  ff, cc);

end









