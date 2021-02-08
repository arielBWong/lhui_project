seedmax = 21;
median_num = 11;



problems = {'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
            'smd8()', 'smd9()',  'smd10()','smd11()' ,'smd12()'};
        
problems = {'smd1(1,1,1)','smd2(1,1,1)','smd3(1,1,1)','smd4(1,1,1)','smd5(1,1,1)','smd6(1,0, 1,1)','smd7(1,1,1)',...
               'smd8(1,1,1)', 'smd9(1,1,1)', 'smd11(1,1,1)', 'smd10(1,1,1)','smd12(1,1,1)'};

           
           problems = {'smd1(3, 3)', 'smd2(3, 3)', 'rosenbrock(3, 3)',  'Zakharov(3, 3)',...
            'levy(3, 3)', 'ackley(3, 3)',  'smd3(3, 3)', 'smd4(3, 3)' , ...
            'dsm1(3, 3)', 'tp7(3, 3)',  'tp9(3, 3)','Shekel(3, 3)','tp3(3, 3)',...
            'tp6(3, 3)', 'rastrigin(3, 3)', 'tp5(3, 3)'         };
        
problems = { 'smd6x(1,2,1)','smd7x(1,2,1)',  'smd8x(1,2,1)'};
problems = {'smd6x(1,1,1)','smd7x(1,1,1)',  'smd8x(1,1,1)',...
    'smd1(1,1,1)','smd2(1,1,1)','smd3(1,1,1)', 'smd4(1,1,1)','smd5(1,1,1)','smd6(1,0, 1,1)','smd7(1,1,1)',...
           'smd8(1,1,1)', 'smd9(1,1,1)', 'smd11(1,1,1)', 'smd10(1,1,1)','smd12(1,1,1)'};

problems = {'ackley(3, 3)', 'levy(3, 3)','rastrigin(3, 3)','dsm1(3, 3)', ... %  multimodal global structure  heavy modality and weak modality
    'tp3(3, 3)', 'tp5(3, 3)', 'tp7(3, 3)', 'Shekel(3, 3)', ... % multimodal no global structure
    'Zakharov(3, 3)', 'smd2(3, 3)',  'rosenbrock(3, 3)', ... % unimodal
    'smd1(3, 3)', 'smd3(3, 3)', 'smd4(3, 3)' ,  'tp6(3, 3)', 'tp9(3, 3)'};

seedmax = 21;
median_num = 11;

        
% problems = {'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
%             'smd8()', 'smd9()', 'smd10()','smd11()','smd12()'};
% problems = {'smd1()','smd2()','smd3()','smd4()'  };    

algos = {'localKN', 'vanillaEI',  'vanillaKB'}; % , 'lleim_gp', 'lladp_gp',  'vanillaKB'
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



selpath = uigetdir; 

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
            fout_folder = strcat(selpath, '\', prob.name, '_', num2str(nvar), '_single_mixModel', algos{kk}, '_init', num2str(ninit));
            
            % f value
            fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' )           
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
median_overproblems = zeros(np, na);
median_seed = zeros(np, na);

for ii = 1:np
    for jj = 1:na
        median_overproblems(ii, jj) = median(best_fl{ii}(jj, :)); %{problem}(algorithm, seed)
        one_record = best_fl{ii}(jj, :);   
        %(problems, algorithm)
        median_seed(ii, jj) = median(one_record);        
    end
end
% 


% %---- generate profiling
legs = {'BHEI', 'EI', 'KB'};
Data1 = median_overproblems';
PerformanceProfile(Data1,legs);

%--- median to csv
savename = strcat(selpath, '\median_singlelevel.csv');
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

alg_new     = cell(1, np);
alg_base    = cell(1, np);
alg_newname = 'localBH';

for ii = 1:np
    if strcmp(alg_newname, 'localKN')
        alg_new{ii} = best_fl{ii}(2, :);
    end
    if strcmp(alg_newname, 'localBH')
        alg_new{ii} = best_fl{ii}(1, :);
    end
    alg_base{ii}    = best_fl{ii}(2: 3, :);
end
algo_basenames =  {'vanillaEI',  'vanillaKB'};

% compare between EI, KB
% for ii = 1:np
%     alg_new{ii} = best_fl{ii}(2, :);
%     alg_base{ii}    = best_fl{ii}(3, :);
% end
% alg_newname = 'EI';
% algo_basenames =  {'KB'};

significant_check(alg_new, alg_base,problems, alg_newname, algo_basenames, selpath);

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
% savename = strcat(selpath, '\median_sigtest.csv');
savename = strcat(selpath, '\median_sigtest_eikb.csv');
fp=fopen(savename,'w');
fprintf(fp, 'problem_method, ');

for kk = 1 : compare_na    
    fprintf(fp, algo_basenames{kk});
    fprintf(fp, ',%s, ', alg_newname);       
    fprintf(fp, '%s, ', strcat(alg_newname, ' compared to ', algo_basenames{kk}, ','));    
end
fprintf(fp, '\n');

for kk = 1 : np
    prob = eval(problems{kk});

    fprintf(fp,  prob.name);
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