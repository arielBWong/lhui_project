
problems = {'smd1(1,1,1)','smd2(1,1,1)','smd3(1,1,1)','smd4(1,1,1)','smd5(1,1,1)','smd6(1,0, 1,1)','smd7(1,1,1)',...
               'smd8(1,1,1)', 'smd9(1,1,1)', 'smd11(1,1,1)', 'smd10(1,1,1)','smd12(1,1,1)'};

 problems = {'smd1(3, 3)', 'smd2(3, 3)', 'rosenbrock(3, 3)',  'Zakharov(3, 3)',...
            'levy(3, 3)', 'ackley(3, 3)',  'smd3(3, 3)', 'smd4(3, 3)' , ...
            'dsm1(3, 3)', 'tp7(3, 3)',  'tp9(3, 3)','Shekel(3, 3)','tp3(3, 3)',...
            'tp6(3, 3)', 'rastrigin(3, 3)', 'tp5(3, 3)'         };
    % 'smd1(1,1,1)','smd2(1,1,1)','smd3(1,1,1)','smd4(1,1,1)','smd5(1,1,1)','smd6(1,0, 1,1)','smd7(1,1,1)',...
    % 'smd8(1,1,1)', 'smd9(1,1,1)', 'smd11(1,1,1)', 'smd10(1,1,1)','smd12(1,1,1)'};

%problems = {'Shekel(3, 3)'};

algos = {'localBH'}; % 'localKN'

np = length(problems);
na = 4;
seedmax = 21;
fprintf('select the sep version');
selpath = uigetdir;


best_fl = cell(1, np);
best_flnum = cell(1, np);
best_feasible = cell(1, np);

for ii = 1: np
    prob  = eval(problems{ii});
    nvar  = prob.n_lvar;
    ninit = 20; % 11 * nvar - 1;
    
    best_fl{ii}     = zeros(na , seedmax);
    best_flnum{ii}  = zeros(na , seedmax);
    best_feasible{ii} ...
        = zeros(na , seedmax);
    
    for jj = 1:seedmax
        fout_folder = strcat(selpath, '\', prob.name, '_', num2str(nvar), '_single_sepModel', algos{1}, '_init', num2str(ninit));
        
        fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' )
        fl_out      = csvread(fout_file);
        
        % {problem}[algorithm, seed]
        best_fl{ii}(1, jj)    = fl_out; %abs(fl_out - prob.lopt);
        fout_file             = strcat(fout_folder, '\num_', num2str(jj), '.csv' )
        num                   = csvread(fout_file);
        
        
        % evaluation number
        best_flnum{ii}(1, jj) = num;
        
        % feasibility
        fout_file              = strcat(fout_folder, '\fesibility', num2str(jj), '.csv' )
        best_feasible{ii}(1, jj)...
            = csvread(fout_file);
    end
end

fprintf('select Mix');
selpath = uigetdir;

for ii = 1: np
    prob  = eval(problems{ii});
    nvar  = prob.n_lvar;
    ninit = 20; % 11 * nvar - 1;
    
    
    for jj = 1:seedmax
        fout_folder = strcat(selpath, '\', prob.name, '_', num2str(nvar), '_single_mixModel', algos{1}, '_init', num2str(ninit));
        
        fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' )
        fl_out      = csvread(fout_file);
        
        % {problem}[algorithm, seed]
        best_fl{ii}(2, jj)    = fl_out; %abs(fl_out - prob.lopt);
        fout_file             = strcat(fout_folder, '\num_', num2str(jj), '.csv' )
        num                   = csvread(fout_file);
        
        
        % evaluation number
        best_flnum{ii}(2, jj) = num;
        
        % feasibility
        fout_file              = strcat(fout_folder, '\fesibility', num2str(jj), '.csv' )
        best_feasible{ii}(2, jj)...
            = csvread(fout_file);
    end
end

fprintf('select EI and KB');
selpath = uigetdir;

algos = {'vanillaEI',  'vanillaKB'}; 
na = length(algos);
for ii = 1: np
    prob  = eval(problems{ii});
    nvar  = prob.n_lvar;
    ninit = 20; % 11 * nvar - 1;
    
    for kk = 1:na
        for jj = 1:seedmax
            fout_folder = strcat(selpath, '\', prob.name, '_', num2str(nvar), '_single_sepModel', algos{kk}, '_init', num2str(ninit));
            
            fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' );
            fl_out      = csvread(fout_file);
            
            % {problem}[algorithm, seed]
            best_fl{ii}(kk+2, jj)  = fl_out; %abs(fl_out - prob.lopt);
            fout_file             = strcat(fout_folder, '\num_', num2str(jj), '.csv' );
            num                   = csvread(fout_file);
            
            
            % evaluation number
            best_flnum{ii}(kk+2, jj) = num;
            
            % feasibility
            fout_file              = strcat(fout_folder, '\fesibility', num2str(jj), '.csv' );
            best_feasible{ii}(kk+2, jj)...
                = csvread(fout_file);
        end
    end
end

alg_new     = cell(1, np);
alg_base    = cell(1, np);
alg_newname = 'Sep';

for ii = 1:np
    if contains( alg_newname,'Sep')
        alg_new{ii} = best_fl{ii}(1, :);
    else
        alg_new{ii} = best_fl{ii}(2, :);
    end
    alg_base{ii} = best_fl{ii}(3:4, :);
end


%--- median to csv
median_overproblems = zeros(np, na);
median_seed = zeros(np, na);
na = 4;
for ii = 1:np
    for jj = 1:na
        median_overproblems(ii, jj) = median(best_fl{ii}(jj, :));
        one_record = best_fl{ii}(jj, :);   
        median_seed(ii, jj) = median(one_record);        
    end
end
% 


% %---- generate profiling
min_alg = min(median_overproblems, [], 2);
rangelist = max(median_overproblems,  [], 2) ./ min(median_overproblems, [], 2);
range = max(rangelist);
legs = {'Sep hybrid', 'Mix hybrid', 'EI', 'KB'};
Data1 = median_overproblems';
PerformanceProfile(Data1,legs);


algo_basenames =  {'EI', 'KB'};
% significant_check(alg_new, alg_base,problems, alg_newname, algo_basenames, selpath);


function significant_check(alg_new, algo_base, problems, alg_newname,algo_basenames, selpath)
% to    : baseline algorithms {problem}[seed-->] row
% from  : new algorithms      {problem}[algs|, seed-->] (col, row)
%---------------------------
np             = length(alg_new);      %
compare_na     = length(algo_basenames);
compare_sig    = zeros(np, compare_na);  %
compare_median = zeros(np, compare_na);
new_median     = zeros(np, 1);
for i = 1: np
    new_result  = alg_new{i}(:);
    new_median(i) = median(new_result);
    
    for j = 1: compare_na
        
        base_result = algo_base{i}(j, :);
        
        base_median = median(base_result);
        compare_median(i, j) = base_median;
        
        % check whether two results are same distribution
        [~, h] = ranksum(new_result, base_result);
        if h % logical 1, reject null (equal median at 5% sig level), accept difference
            
            [~, h_newsmall] = ranksum(new_result, base_result,'tail','left');
            if h_newsmall % logical 1, rejectl null (equal median), accept alternative new_result smaller
                compare_sig(i, j) = 1; % new smaller than base
            end
            
            [~, h_basesmall] = ranksum(new_result, base_result,'tail','right');
            if h_basesmall % logical 1, rejectl null (equal median), accept alternative new_result smaller
                compare_sig(i, j) = -1; % new bigger/worse than base
            end
        else
            compare_sig(i, j) = 0; % base/new no difference
        end
    end
end
savename = strcat(selpath, '\median_sigtest2.csv');
fp=fopen(savename,'w');
fprintf(fp, 'problem_method, ');

for kk = 1 : compare_na
    fprintf(fp, algo_basenames{kk});
    fprintf(fp, strcat(',', alg_newname, ','));
    fprintf(fp, strcat(alg_newname, 'compared to ', algo_basenames{kk}, ','));
end
fprintf(fp, '\n');

for kk = 1 : np
    fprintf(fp,  problems{kk}(1:5));
    fprintf(fp,  ',');
    for  ii = 1 : compare_na
        fprintf(fp, '%f,', compare_median(kk, ii));
        fprintf(fp, '%f,', new_median(kk));
        fprintf(fp, '%d,', compare_sig (kk, ii) );
    end
    fprintf(fp, '\n');
end
fclose(fp);
end