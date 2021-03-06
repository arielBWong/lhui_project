seedmax = 11;
median_num = 6;

problems = { 'smd6x(1,1,1)','smd7x(1,1,1)',  'smd8x(1,1,1)','smd4x(1,1,1)'};% { 'smd6x(1,2,1)','smd7x(1,2,1)',  'smd8x(1,2,1)','smd4x(1,2,1)'};
        
algos = { 'localKN', 'vanillaEI','vanillaKB',}; % , 'lleim_gp', 'lladp_gp'
legs = {'KN', 'EI', 'KB'};
colors = {'b', 'r', 'k'};
legend_algos = legs;


np = length(problems);  
% ns = length(seeds);
na = length(algos);

%--construct result save path
plotpath = strcat(pwd, '\plots');
best_fl = cell(1, np);
best_flnum = cell(1, np);
best_fu = cell(1, np);
best_funum = cell(1, np);

% process each problem
for ii = 1: np
    prob = eval(problems{ii});
    nvar = prob.n_lvar;
    ninit = 20; % 11 * nvar - 1;
    
    %collect results for each algo
    algos_out = cell(1, na);
    best_fl{ii} = zeros(na , seedmax);
    best_flnum{ii} = zeros(na , seedmax);
    best_fu{ii} = zeros(na , seedmax);
    best_funum{ii} = zeros(na , seedmax);


    for kk = 1:na     
        algos_out{kk} = [];
        for jj = 1:seedmax
            % save folder and save name
            fout_folder = strcat(pwd, '\result_folder\', prob.name, '_', num2str(nvar), '_', algos{kk});
            fout_file   = strcat(fout_folder, '\out_', num2str(jj), '.csv' )        
            outmatrix   = csvread(fout_file);
            
            %{problem}(algorithm, seed)
            best_fu{ii}(kk, jj) = abs(outmatrix(1, 1) - prob.uopt);
            best_fl{ii}(kk, jj) = abs(outmatrix(1, 2) - prob.lopt);
            best_funum{ii}(kk, jj) = outmatrix(2, 1);
            best_flnum{ii}(kk, jj) = outmatrix(2, 2);
        end
    end
end

% check whether there is 


%--- median to csv
savename = strcat(pwd, '\result_folder\bl_median_mix.csv');
fp=fopen(savename,'w');
fprintf(fp, 'problem_method, ');
for kk = 1 : na
    fprintf(fp, algos{kk});
    fprintf(fp, '_upper ,');   
    
    fprintf(fp, algos{kk});
    fprintf(fp, '_lower ,');   
    
    fprintf(fp, 'upper_num ,'); 
    fprintf(fp, 'lower_num ,'); 
end
fprintf(fp, '\n');

for ii = 1 : np
    prob = eval(problems{ii});
    fprintf(fp, prob.name);   
    fprintf(fp, ',');  
    for jj = 1:na
        %{problem}(algorithm, seed)
        fu = best_fu{ii}(jj, :);
        fl = best_fl{ii}(jj, :);
        fu_num = best_funum{ii}(jj, :);
        fl_num = best_flnum{ii}(jj, :);
        
        [~, id] = sort(fu);
        med = id(median_num);
        
        
        fprintf(fp, '%f,', median(fu)); %  fu(med));
        fprintf(fp, '%f,', median(fl)); %  fl(med));
        fprintf(fp, '%d,', fu_num(med));
        fprintf(fp, '%d,', fl_num(med));
    end
    fprintf(fp, '\n');
    
end
fclose(fp);

% check significance

%--- median to csv
savename = strcat(pwd, '\result_folder\bl_median_sep.csv');
fp=fopen(savename,'w');
fprintf(fp, 'problem_method, ');
for kk = 1 : na
    fprintf(fp, algos{kk});
    fprintf(fp, '_upper ,');   
    
    fprintf(fp, algos{kk});
    fprintf(fp, '_lower ,');   
    
    fprintf(fp, 'upper_num ,'); 
    fprintf(fp, 'lower_num ,'); 
end
fprintf(fp, '\n');

for ii = 1 : np
    prob = eval(problems{ii});
    fprintf(fp, prob.name);   
    fprintf(fp, ',');  
    for jj = 1:na
        %{problem}(algorithm, seed)
        fu = best_fu{ii}(jj, :);
        fl = best_fl{ii}(jj, :);
        fu_num = best_funum{ii}(jj, :);
        fl_num = best_flnum{ii}(jj, :);
        
        [~, id] = sort(fu);
        med = id(median_num);
        
        
        fprintf(fp, '%f,', median(fu)); %  fu(med));
        fprintf(fp, '%f,', median(fl)); %  fl(med));
        fprintf(fp, '%d,', fu_num(med));
        fprintf(fp, '%d,', fl_num(med));
    end
    fprintf(fp, '\n');
    
end
fclose(fp);
