function ulego_klocal_singlelevel(prob, seed, infill_metodstr, norm_str, localsearch, varargin)
% method of main optimization process of upper level ego
%--------------------------------------------------------------------------

rng(seed, 'twister');
visualization = false;
include_local = true;
fprintf('Problem %s, seed %d\n', prob, seed); 

% temp only for SMD(1,1,1) problems
% nu = 2;
% if contains(prob, 'smd10') || contains(prob, 'smd12')   
%     xu = ones(1, nu);
% else
%     xu = zeros(1, nu);
% end


              

% performance record variable
n_feval       = 0;

% algo parameter distribution
% inisize_u   = 20;
% inisize_l   = 20;
% numiter_l   = 168; % 
% numiter_u   = 180;
% num_pop     = 100;
% num_gen     = 100;
eval('parameter_load');
prob        = eval(prob);
method      = strcat('local', varargin{1});

% localsearch = false;
if ~localsearch
    % numiter_l   =  168;
    % numiter_u   =  180;
    method      =  strcat('vanilla', varargin{1});
end



llmatch_p               = struct();
llmatch_p.prob          = prob;
llmatch_p.num_pop       = num_pop;
llmatch_p.num_gen       = num_gen;
llmatch_p.egostr        = infill_metodstr;
llmatch_p.egoinitsize   = inisize_l;
llmatch_p.egoitersize   = numiter_l;
llmatch_p.egofnormstr   = norm_str;
llmatch_p.seed          = seed;
llmatch_p.localsearch   = localsearch;
llmatch_p.method        = method;


if strcmp(varargin{1}, 'BH')
    llmatch_p.localmethod  = 'bh_localmodel';
elseif strcmp(varargin{1}, 'KN')
    llmatch_p.localmethod  = 'klocalpoints';
else
    llmatch_p.localmethod  = [];
end


% paper setting
% nu = prob.n_lvar;
% xu = zeros(1, nu);
% paper setting
if contains(prob.name, 'x')
    xu = prob.xu_prime;
else
    xu = zeros(1, prob.n_uvar);
end

[xl_single, n, flag] ...
                  = llmatch_keepdistance(xu, llmatch_p, visualization, include_local);
                % = llmatch(xu, llmatch_p, visualization, include_local);
                  

num               = prob.n_lvar;
if include_local
    savepath      = strcat(pwd, '\result_folder\', prob.name, '_', num2str(num), ...
        '_single_mixModel', method, '_init', num2str(inisize_u));
else
    savepath      = strcat(pwd, '\result_folder\', prob.name, '_', num2str(num), ...
        '_single_sepModel', method, '_init', num2str(inisize_u));
end
k = exist(savepath);
if k ~= 7
    mkdir(savepath)
end

[fl, ~]          = prob.evaluate_l(xu, xl_single);
savename         = strcat(savepath, '\xl_', num2str(seed),'.csv');
csvwrite(savename, xl_single);
savename         = strcat(savepath, '\num_', num2str(seed),'.csv');
csvwrite(savename, n);
savename         = strcat(savepath, '\fl_', num2str(seed),'.csv');
csvwrite(savename, fl);

savename         = strcat(savepath, '\fesibility', num2str(seed),'.csv');
csvwrite(savename, flag);


end


