seedmax = 21;
median_num = 11;

problems = {
     'smd1(3, 3)', 'smd2(3, 3)', 'rosenbrock(3, 3)',  'Zakharov(3, 3)',...
      'levy(3, 3)', 'ackley(3, 3)',  'smd3(3, 3)', 'smd4(3, 3)' , ...
      'dsm1(3, 3)', 'tp7(3, 3)',  'tp9(3, 3)','Shekel(3, 3)','tp3(3, 3)',...
       'tp6(3, 3)', 'rastrigin(3, 3)', 'tp5(3, 3)'         };
% 
problems = {'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
            'smd8()', 'smd9()',  'smd10()','smd11()' ,'smd12()'};
seedmax = 11;
median_num = 6;

        
% problems = {'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
%             'smd8()', 'smd9()', 'smd10()','smd11()','smd12()'};
% problems = {'smd1()','smd2()','smd3()','smd4()'  };    

algos = {'localBH','localKN', 'vanillaEI', 'vanillaKB'}; % , 'lleim_gp', 'lladp_gp'
legs = {'BLE', 'EIM', 'BHEIM'};
colors = {'b', 'r', 'k'};
legend_algos = {'BLE', 'EIM', 'BHEIM'};


np = length(problems);  
% ns = length(seeds);
na = length(algos);

%--construct result save path 
plotpath = strcat(pwd, '\plots');
best_fl = cell(1, np);
best_flnum = cell(1, np);
best_feasible = cell(1, np);

% process each problem
for ii = 1: np
    prob  = eval(problems{ii});
    nvar  = prob.n_lvar;
    ninit = 20; % 11 * nvar - 1;
    
    %collect results for each algo
    algos_out       = cell(1, na);
    best_fl{ii}     = zeros(na , seedmax);
    best_flnum{ii}  = zeros(na , seedmax);
    best_fu{ii}     = zeros(na , seedmax);
    best_funum{ii}  = zeros(na , seedmax);
    best_feasible{ii} ...
                    = zeros(na , seedmax);

    for kk = 1:na     
        algos_out{kk} = [];
        for jj = 1:seedmax
            % save folder and save name
            fout_folder = strcat(pwd, '\result_folder\', prob.name, '_', num2str(nvar), '_single_', algos{kk}, '_init', num2str(ninit));
            % fout_folder = strcat(pwd, '\resultfolder_ll\', prob.name, '_', num2str(nvar), '_', algos{kk}, 'EI';
            
            % f value
            fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' );           
            fl_out      = csvread(fout_file);
            
            % {problem}[algorithm, seed]
            best_fl{ii}(kk, jj)    = fl_out; %abs(fl_out - prob.lopt);
            fout_file              = strcat(fout_folder, '\num_', num2str(jj), '.csv' );           
            num                    = csvread(fout_file);
            % evaluation number
            best_flnum{ii}(kk, jj) = num;
            
            % feasibility
            fout_file              = strcat(fout_folder, '\fesibility', num2str(jj), '.csv' ); 
            best_feasible{ii}(kk, jj)...
                                   = csvread(fout_file);
            
        end
    end
end

%--- median to csv
savename = 'median_single2.csv';
fp=fopen(savename,'w');
fprintf(fp, 'problem_method, ');
for kk = 1 : na
    
    fprintf(fp, algos{kk});
    fprintf(fp, '_lower ,');   
    
    fprintf(fp, 'feasibility ,'); 
end
fprintf(fp, '\n');

for ii = 1 : np
    prob = eval(problems{ii});
    fprintf(fp, prob.name);   
    fprintf(fp, ',');  
    for jj = 1:na
     
        % {problem}(algorithm, seed)
        fl = best_fl{ii}(jj, :);
        fl_feasibility = best_feasible{ii}(jj, :);
        
        [~, id] = sort(fl);
        med = id(median_num);
        

        fprintf(fp, '%f,', fl(med));
        fprintf(fp, '%d,', fl_feasibility(med));
    end
    fprintf(fp, '\n');
    
end
fclose(fp);

alg_new = cell(1, np);
alg_base = cell(1, np);
alg_newname = 'localBH';

for ii = 1:np
    if strcmp(alg_newname, 'localKB')
        alg_new{ii} = best_fl{ii}(2, :);
    end
    if strcmp(alg_newname, 'localBH')
        alg_new{ii} = best_fl{ii}(1, :);
    end
    alg_base{ii}    = best_fl{ii}(3: 4, :);
end


algo_basenames =  {'vanillaEI', 'vanillaKB'};

significant_check(alg_new, alg_base,problems, alg_newname, algo_basenames);

function significant_check(alg_new, algo_base, problems, alg_newname, algo_basenames)
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
savename = 'median_sigtest2.csv';
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