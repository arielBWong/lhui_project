function ulego_klocal_singlelevel(prob, seed, infill_metodstr, norm_str, localsearch, varargin)
% method of main optimization process of upper level ego
%--------------------------------------------------------------------------
tic;
rng(seed, 'twister');
visualization = false;
% performance record variable
n_feval       = 0;

% algo parameter distribution
inisize_u   = 20;
inisize_l   = 20;
numiter_l   = 180; % 150; %67;
numiter_u   = 180;
num_pop     = 100;
num_gen     = 100;
prob        = eval(prob);
method      = strcat('local', varargin{1});

% localsearch = false;
if ~localsearch
    numiter_l   =  180;
    numiter_u   =  80;
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



nu = prob.n_uvar;
% xu = zeros(1, nu);
xu = ones(1, nu);
[xl_single, n, flag] ...
                  = llmatch(xu, llmatch_p, visualization);

num               = prob.n_lvar;
savepath          = strcat(pwd, '\result_folder\', prob.name, '_', num2str(num), ...
                    '_single_', method, '_init', num2str(inisize_u));
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


