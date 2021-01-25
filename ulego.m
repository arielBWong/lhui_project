function ulego(prob, seed, eim, fitnesshandle, normhn)
% method of main optimization process of upper level ego
% adapt to upper level problems of "single objective"
% usage: 
%     input
%               prob                          : problem instance                  
%               seed                          : random process seed
%               eim                           : string, the name of eim function 
%               fitnesshandle                 : string, the function that eim use to
%                                                                evaluate fitess in its ea process of proposing next point
%               normhn                    : string, normalization function used in EIMnext_znorm
%               
%     output  
%               csv files saved in result folder
%               performance statistics include 3*3 matrix
%                                                       [  ul  accuracy,                       ll accuracy;
%                                                          upper number of feval,   lower number of feval;
%                                                          upper feasibility,               lower feasibility]
%                                                                      
%                                                                       
%--------------------------------------------------------------------------
tic;
rng(seed, 'twister');
% performance record variable
n_feval = 0;

% algo parameter
inisize_l   = 20;
inisize_u   = 20;
numiter_l   = 80;
numiter_u   = 80;
num_pop     = 100;
num_gen     = 100;

% parallel compatible setting
prob = eval(prob);
% eim = str2func(eim);
% fithn = str2func(fitnesshandle);


%--upper problem variable
u_nvar      = prob.n_uvar;
upper_bound = prob.xu_bu;
lower_bound = prob.xu_bl;
% inisize_u   = 11 * u_nvar - 1;

%  inisize_u = 5;
%  numiter_u = 5;

%-xu initialization
xu = lhsdesign(inisize_u,u_nvar,'criterion','maximin','iterations',1000);
xu = repmat(lower_bound, inisize_u, 1) + repmat((upper_bound - lower_bound), inisize_u, 1) .* xu;

xl = [];
llfeasi_flag = [];
% -xu match its xl and evaluate fu
disp('init');
for i=1:inisize_u
    disp(i);
    [xl_single, n, flag] = llmatch(xu(i, :), prob,num_pop, num_gen, eim, inisize_l, numiter_l, fitnesshandle, seed, normhn);
                                    
    xl = [xl; xl_single];
    llfeasi_flag = [llfeasi_flag, flag];
    n_feval = n_feval + n; %record lowerlevel nfeval
end
%--xu evaluation
[fu, fc] = prob.evaluate_u(xu, xl);
num_con  = size(fc, 2);
% scatter(xu, fu, 'b'); drawnow;

%--fu adjust
for i=1:inisize_u
    fu = llfeasi_modify(fu, llfeasi_flag, i);
end
% disp('main ego')
%-main ulego routine
uppernext = str2func(eim);
for i = 1:numiter_u
    %--search next xu
    [newxu, info] = uppernext(xu, fu, upper_bound, lower_bound,num_pop, num_gen, fc, normhn);
    
    %--get its xl
    [newxl, n, flag] = llmatch(newxu, prob, num_pop, num_gen, eim, inisize_l, numiter_l, fitnesshandle, seed, normhn);
                      
    n_feval = n_feval + n;
    %--evaluate xu
    [newfu, newfc] = prob.evaluate_u(newxu, newxl);
    %--assemble xu fu fc
    xu = [xu; newxu];
    xl = [xl; newxl];
    fu = [fu; newfu];
    fc = [fc; newfc];
    llfeasi_flag = [llfeasi_flag, flag];
    %--adjust fu by lower feasibility
    fu = llfeasi_modify(fu, llfeasi_flag, inisize_u+i);  % --?
    % scatter(xu, fu, 'r'); drawnow;
    disp(i);
end

% post process
coresteps = true;
if coresteps % no local search
    n_up =  size(xu, 1);
    n_low = n_feval;
    method = strcat('eim_init', num2str(inisize_u));
    ulego_coreending(xu, fu, fc, xl, prob, seed, n_up, n_low, method);
else
    upper_localpostprocess(prob, xu, xl, fu, n_feval, seed, 'eim');
end

toc;
end
