function ulego_klocal(prob, seed, infill_metodstr, infill_evalstr, norm_str, localsearch)
% method of main optimization process of upper level ego
%--------------------------------------------------------------------------
tic;
rng(seed, 'twister');
% performance record variable
n_feval = 0;

% algo parameter distribution
inisize_u   = 20;
inisize_l   = 20;
numiter_l   = 80;
numiter_u   = 80;
num_pop     = 100;
num_gen     = 100;
prob        = eval(prob);
method      = 'local';

% localsearch = false;
if ~localsearch
    numiter_l   = 80;
    numiter_u   = 80;
    method      = 'vanilla';
end

llmatch_p               = struct();
llmatch_p.prob          = prob;
llmatch_p.num_pop       = num_pop;
llmatch_p.num_gen       = num_gen;
llmatch_p.egostr        = infill_metodstr;
llmatch_p.egoinitsize   = inisize_l;
llmatch_p.egoitersize   = numiter_l;
llmatch_p.egoevalstr    = infill_evalstr;
llmatch_p.egofnormstr   = norm_str;
llmatch_p.seed          = seed;
llmatch_p.localsearch   = localsearch;
llmatch_p.method        = method;

% local archive
arclocal_xu = []; arclocal_xl = []; arclocal_fu = []; arclocal_cu = [];


%--upper problem variable
u_nvar          = prob.n_uvar;
upper_bound     = prob.xu_bu;
lower_bound     = prob.xu_bl;


%------------------All start from here--------------------
%-xu initialization
xu = lhsdesign(inisize_u,u_nvar,'criterion','maximin','iterations',1000);
xu = repmat(lower_bound, inisize_u, 1) + repmat((upper_bound - lower_bound), inisize_u, 1) .* xu;

xl = [];
llfeasi_flag = []; % indicator whether lowermatch is feasible or not

%--xu match its xl and evaluate fu
for i = 1:inisize_u
    fprintf('Initial xu matching process iteration %d\n', i);
    [xl_single, n, flag] = llmatch(xu(i, :), llmatch_p);
    xl                   = [xl; xl_single];
    llfeasi_flag         = [llfeasi_flag, flag];
    n_feval              = n_feval + n; %record lowerlevel nfeval
end

%--xu evaluation
[fu, fc] = prob.evaluate_u(xu, xl);
num_con  = size(fc, 2);

%--fu adjust
for i=1:inisize_u
    fu = llfeasi_modify(fu, llfeasi_flag, i);
end

arc_xu = xu; arc_xl = xl; arc_fu = fu; arc_cu = fc;
%-main ulego routine
uppernext = str2func(infill_metodstr);
i = 1;
while size(arclocal_xu, 1) <=  inisize_u + numiter_u
    
    if size(arclocal_xu, 1) == inisize_u + numiter_u
        break;
    end
    
    fprintf('main iteration %d \n', size(arclocal_xu, 1));
    %--search next xu--- get xl---count n---- evaluate xu xl--- archive
    %update---- feasibility ajust
    [newxu, info]    = uppernext(xu, fu, upper_bound, lower_bound, num_pop, num_gen, fc, norm_str);
    [newxl, n, flag] = llmatch(newxu, llmatch_p);
    n_feval          = n_feval + n;
    [newfu, newfc]   = prob.evaluate_u(newxu, newxl);
    xu = [xu; newxu];  xl = [xl; newxl];
    fu = [fu; newfu];  fc = [fc; newfc];
    llfeasi_flag     = [llfeasi_flag, flag];
    fu = llfeasi_modify(fu, llfeasi_flag, inisize_u+i);
    i = i + 1;
    
    %----update archive all
    arc_xu = [arc_xu; newxu]; arc_xl = [arc_xl; newxl];
    arc_fu = [arc_fu; newfu]; arc_cu = [arc_cu; newfc];
    
    if size(arclocal_xu, 1) == inisize_u + numiter_u
        break;
    end
    
    %--apply k nearest neighbour search every few iterations
    if mod(i, 5) == 0 && localsearch
        % define local -- search xu -- match xl -- evaluate fu,cu --
        % count n -- adjust fesibility -- update archives
        [localxu, localfu, localcu, krg, krgc] = klocalpoints(arc_xu, arc_fu, arc_cu);
        if ~isempty(krg)
            local_ub = max(localxu, [], 1);
            local_lb = min(localxu, [], 1);
            [new_localxu, ~]                       = localsurrgoate_search(krg, krgc, local_ub, local_lb);
            [new_localxl, n, flag]                 = llmatch(new_localxu, llmatch_p);
            [new_localfu, new_localcu]             = prob.evaluate_u(new_localxu, new_localxl);
            n_feval = n_feval + n;
            if ~flag % not feasible lower
                new_localfu = max(arc_fu, [], 1);
            end
            arclocal_xu = [arclocal_xu; new_localxu];   arclocal_xl = [arclocal_xl; new_localxl];
            arclocal_fu = [arclocal_fu; new_localfu];   arclocal_cu = [arclocal_cu; new_localcu];
            
            % update general archive
            arc_xu = [arc_xu;  new_localxu]; arc_xl = [arc_xl; new_localxl];
            arc_fu = [arc_fu;  new_localfu]; arc_cu = [arc_cu; new_localcu];
            
        end
    end
    
end

% post process
coresteps = true;
if coresteps % no local search
    n_up =  size(arc_xu, 1);
    n_low = n_feval;
    method = strcat(method, '_init_', num2str(inisize_u));
    ulego_coreending(arc_xu, arc_fu, arc_cu, arc_xl, prob, seed, n_up, n_low, method);
else
    upper_localpostprocess(prob, xu, xl, fu, n_feval, seed, method);
end

toc;
end



