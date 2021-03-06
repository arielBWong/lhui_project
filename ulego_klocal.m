function ulego_klocal(prob, seed, infill_metodstr, norm_str, localsearch, varargin)
% method of main optimization process of upper level ego
%--------------------------------------------------------------------------

rng(seed, 'twister');
eval('parameter_load'); % IMPORTANT, variables are load externally

n_FE            = 0;    % record lowerlevel FEs
n_up            = 0;    % record upperlevel FEs
prob            = eval(prob);
uppernext       = str2func(infill_metodstr); % EGO algorithm handle
method          = strcat('local', varargin{1});
if ~localsearch 
    method      = strcat('vanilla', varargin{1});
end

llmatch_p.prob          = prob;
llmatch_p.egostr        = infill_metodstr;
llmatch_p.egofnormstr   = norm_str;
llmatch_p.seed          = seed;
llmatch_p.localsearch   = localsearch;
llmatch_p.method        = method;

if strcmp(varargin{1}, 'BH')
    llmatch_p.localmethod = 'bh_localmodel';
    localmodelling        = str2func('bh_localmodel');
elseif strcmp(varargin{1}, 'KN')
    llmatch_p.localmethod = 'klocalpoints';
    localmodelling        = str2func('klocalpoints');
else
    llmatch_p.localmethod = [];
end


%------------------Process starts--------------------
%---xu initialization
xu = lhsdesign(inisize_u,prob.n_uvar,'criterion','maximin','iterations',1000);
xu = repmat(prob.xu_bl, inisize_u, 1) + repmat((prob.xu_bu - prob.xu_bl), inisize_u, 1) .* xu;

xl	         = [];
llfeasi_flag = []; % indicator whether lowermatch is feasible or not

%---xu match its xl and evaluate fu
for i = 1:inisize_u
    fprintf('Initialition xu matching process iteration %d\n', i);
    %tic;

    [xl_single, n, flag] = llmatch_keepdistance(xu(i, :), llmatch_p, visual, true);
    %toc;
    xl                   = [xl; xl_single];
    llfeasi_flag         = [llfeasi_flag, flag];
    n_FE                 = n_FE + n;    
end

%---xu evaluation
[fu, fc]                = prob.evaluate_u(xu, xl);

%--- initialize archive 
arc_xu = xu; arc_xl = xl; arc_fu = fu; arc_cu = fc;

%---- Infill routine
i = 0;
while size(arc_xu, 1) <  inisize_u + numiter_u
  
    fprintf('Infill iteration %d \n', size(arc_xu, 1));
    [xu, fu, fc, ~]       = data_prepare(xu, fu, fc);
    
	% --- find next infill and get its xl
	[newxu, ~]            = uppernext(xu, fu,  prob.xu_bu, prob.xu_bl, num_pop, num_gen, fc, norm_str);
    % [newxl, n, flag]    = llmatch(newxu, llmatch_p, visual, false);
    [newxl, n, flag]      = llmatch_keepdistance(newxu, llmatch_p, visual, true);
    n_FE                  = n_FE + n;
    llfeasi_flag          = [llfeasi_flag, flag]; %no use
    
    % --- true evaluation
    [newfu, newfc]        = prob.evaluate_u(newxu, newxl);
    [xu, xl, fu, fc]      = add_entry(xu, xl, fu, fc, newxu, newxl, newfu, newfc);
    [xu, xl, fu, fc]      = keepdistance_upper(xu, fu, fc, xl, prob.xu_bu, prob.xu_bl);
 
    i                     = i + 1; % only count external FE
    
    %----update archive all
    [arc_xu, arc_xl, arc_fu, arc_cu]...
                          = add_entry(arc_xu, arc_xl, arc_fu, arc_cu, newxu, newxl, newfu, newfc);

    % --- check FE budget
    if size(arc_xu, 1) == inisize_u + numiter_u
        break;
    end
    
    %--apply k nearest neighbour search every few iterations
    if mod(i, 5) == 0 && localsearch
        [localxu, ~, ~, krg, krgc, arc_obj, arc_con] ...
												   = localmodelling(xu, fu, fc);
        
		if ~isempty(krg)
            local_ub 							   = max(localxu, [], 1);
            local_lb                               = min(localxu, [], 1);
            new_localxu                            = localsurrgoate_search(krg, krgc, local_ub, local_lb,  arc_obj, arc_con,...
                                                            num_pop, num_gen, prob.xu_bl, prob.xu_bu);
            [new_localxl, n, flag]                 = llmatch_keepdistance(new_localxu, llmatch_p, visual, true);
            [new_localfu, new_localcu]             = prob.evaluate_u(new_localxu, new_localxl);
            n_FE                                   = n_FE + n;

            %----update archive all
            [arc_xu, arc_xl, arc_fu, arc_cu]       = add_entry(arc_xu, arc_xl, arc_fu, arc_cu, new_localxu, new_localxl, new_localfu, new_localcu);
            [xu, xl, fu, fc]                       = add_entry(xu, xl, fu, fc, new_localxu, new_localxl, new_localfu, new_localcu);
            [xu, xl, fu, fc]                       = keepdistance_upper(xu, fu, fc, xl, prob.xu_bu, prob.xu_bl);
            
            % --- check FE budget
            if size(arc_xu, 1) == inisize_u + numiter_u
                break;
            end
        end
    end
    
end

% --- post process
if coresteps  % no upper local search
    n_up   =  size(arc_xu, 1);
    n_low  =  n_FE;
    ulego_coreending(arc_xu, arc_fu, arc_cu, arc_xl, prob, seed, n_up, n_low, method);
else
    
    if blsearch % upper bilevel local search
        [xu_start, ~, ~, ~, ~]       =  localsolver_startselection(arc_xu,  arc_fu, arc_cu);
        nest_parameter.arc_con       =  arc_cu;  % for whether problem has contraints or not
        if  nest_parameter.global_search
            nest_parameter.xlinit    =  [];else
            nest_parameter.xlinit    =  prob.xl_bl + rand(1, prob.n_lvar).* (prob.xl_bu - prob.xl_bl);
        end
        [xu_new, xl_new, nu, nl]...
            =  bl_localsearch(prob, xu_start, nest_parameter);
        [fu_new, cu_new]             =  prob.evaluate_u(xu_new, xl_new);
        
        n_up                         = n_up + nu;
        n_FE                         = n_FE + nl;
        [arc_xu, arc_xl, arc_fu, arc_cu]...
                                     = add_entry(arc_xu, arc_xl, arc_fu, arc_cu,xu_new, xl_new, fu_new, cu_new);
        
        
    end
    % re-evaluate
    [xu_final, ~, ~, ~, index]   = localsolver_startselection(arc_xu,  arc_fu, arc_cu);  
    re_evalparameter.xlinit      = arc_xl(index, :);
    [xl_final, nl]               = llmatch_trueEval(xu_final, prob, re_evalparameter);
    [fu_final, cu_final]         = prob.evaluate_u(xu_final, xl_final);
    
    % --- archive add entry
    [arc_xu, arc_xl, arc_fu, arc_cu]...
                                 = add_entry(arc_xu, arc_xl, arc_fu, arc_cu,xu_final, xl_final, fu_final, cu_final);
    n_FE                         = n_FE + nl;
    n_up                         = n_up + size(arc_xu, 1);
    
    
    ulego_coreending(arc_xu, arc_fu, arc_cu, arc_xl, prob, seed, n_up, n_FE, method);
end



end


function [x1, x2, f, c] = add_entry(x1, x2, f, c, x1_new, x2_new, f_new, c_new)
x1 = [x1; x1_new]; 
x2 = [x2; x2_new]; 
f  = [f;  f_new]; 
c  = [c;  c_new];
end