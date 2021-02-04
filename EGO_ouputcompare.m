seedmax = 21;
median_num = 11;

problems = {'smd1(3, 3)', 'smd2(3, 3)', 'rosenbrock(3, 3)',  'Zakharov(3, 3)',...
    'levy(3, 3)', 'ackley(3, 3)',  'smd3(3, 3)', 'smd4(3, 3)' , ...
    'dsm1(3, 3)', 'tp7(3, 3)',  'tp9(3, 3)','Shekel(3, 3)','tp3(3, 3)',...
    'tp6(3, 3)', 'rastrigin(3, 3)', 'tp5(3, 3)'         };

algos = { 'llble_gp', 'lleim_gp','lladp_bh4'}; % , 'lleim_gp', 'lladp_gp'
legs = {'KB', 'EI', 'BHEI'};
colors = {'b', 'r', 'k'};
legend_algos = {'KB', 'EI', 'BHEI'};


np = length(problems);
% ns = length(seeds);
na = length(algos);

%--construct result save path
plotpath = strcat(pwd, '\plots');


best_fl = cell(1,np);

% process each problem
for ii = 1: np
    prob = eval(problems{ii});
    nvar = prob.n_lvar;
    ninit = 11 * nvar - 1;
    
    %collect results for each algo
    algos_out = cell(1, na);
    best_fl{ii} = zeros(na, seedmax);
    
    for kk = 1:na
        
        algos_out{kk} = [];
        for jj = 1:seedmax
            % save folder and save name
            fout_folder = strcat(pwd, '\resultfolder_gp\', prob.name, '_', num2str(nvar), '_', algos{kk}, '_init_', num2str(ninit));
            fout_file = strcat(fout_folder, '\fl_', num2str(jj), '.csv' );
            
            fl = csvread(fout_file);
            fl_size = length(fl);
            fl_part = [];
            
            if kk == 3  % BHEI
                % adjust fl
                fl_local = fl(173 : end);
                localindex = 1;
                
                fl_part = fl(1: ninit)';
                for nn = ninit + 1 : ninit + 140
                    fl_part = [fl_part, fl(nn)];
                    g = nn - ninit;
                    if mod(g, 5) == 0
                        fl_part = [fl_part, fl_local(localindex)];
                        localindex = localindex + 1;
                    end
                end
                fl_part = [fl_part, fl(end)];
                
                fl = fl_part;
                fl_part = [];
            end
            
            % min f so far
            for mm = ninit : fl_size
                tmp = min(fl(1: mm));
                fl_part = [fl_part, tmp];
            end
            algos_out{kk} = [algos_out{kk}; fl_part];
            best_fl{ii}(kk, jj) = fl_part(end);
            
            % adjust the order of results
            
        end
    end
    
    
    % generate plot: median fl from start from 32 to last
    figure(ii);
    % plot each algo output
    for kk = 1:na
        algo_mean = mean(algos_out{kk}, 1);
        plot(algo_mean, colors{kk}, 'LineWidth', 2); hold on;
        
        % std
        algo_std = std(algos_out{kk},1);
        
        x = 1:length(algo_mean);
        x = [x, fliplr(x)];
        y1 = algo_mean + algo_std;
        y2 = algo_mean - algo_std;
        y = [y1, fliplr(y2)];
        fill(x, y, colors{kk}, 'FaceAlpha', 0.1, 'EdgeColor','none');
        
    end
    % title(prob.name, 'FontSize', 16);
    legend(legs{1}, strcat(legs{1}, ' std'),  legs{2}, strcat(legs{2}, ' std'), legs{3}, strcat(legs{3}, ' std'),  'FontSize', 20);
    
    hLegend = findobj(gcf, 'Type', 'Legend');
    set(hLegend, 'FontName', 'Times New Roman')
    
    xlabel('Iterations', 'FontSize', 20)
    ylabel('F',  'FontSize', 20);
    
    ylh = get(gca,'ylabel');
    set(ylh, 'Rotation',0, 'FontName', 'Times New Roman');
    
    xlh = get(gca,'xlabel');
    set(xlh, 'FontName', 'Times New Roman');
    
    
    tlh = get(gca,'title');
    set(tlh, 'FontName', 'Times New Roman');
    
    
    % xtk = get(gca,'XTickLabel');
    % set(gca,'XTickLabel',xtk,'fontsize',12);
    
    % save to plot folder
    savename = strcat(plotpath, '\', prob.name,'_', num2str(nvar), '_converge.fig');
    saveas(figure(ii), savename);
    
    savename = strcat(plotpath, '\', prob.name,'_', num2str(nvar), '_converge.png');
    saveas(figure(ii), savename);
    close(figure(ii));
end

%--- median to csv
median_overproblems = zeros(np, na);
median_seed = zeros(np, na);
for ii = 1:np
    for jj = 1:na
        median_overproblems(ii, jj) = median(best_fl{ii}(jj, :));
        one_record = best_fl{ii}(jj, :);
        % ----
        [~, id] = sort(one_record);
        median_seed(ii, jj) = id(median_num);        
    end
end
% 


% %---- generate profiling
min_alg = min(median_overproblems, [], 2);
rangelist = max(median_overproblems,  [], 2) ./ min(median_overproblems, [], 2);
range = max(rangelist);

Data1 = median_overproblems';
PerformanceProfile(Data1,legs);

