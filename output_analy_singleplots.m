seedmax = 21;
median_num = 11;

 problems = {'smd1(3, 3)', 'smd2(3, 3)', 'rosenbrock(3, 3)',  'Zakharov(3, 3)',...
            'levy(3, 3)', 'ackley(3, 3)',  'smd3(3, 3)', 'smd4(3, 3)' , ...
            'dsm1(3, 3)', 'tp7(3, 3)',  'tp9(3, 3)','Shekel(3, 3)','tp3(3, 3)',...
            'tp6(3, 3)', 'rastrigin(3, 3)', 'tp5(3, 3)'         };
 
problems = {'Shekel(3, 3)'};
algos = {'localBH', 'vanillaEI',  'vanillaKB'}; % , 'lleim_gp', 'lladp_gp',  'vanillaKB'
legs = {'BHEI', 'EI', 'KB'};
colors = {'b', 'r', 'k'};
legend_algos = {'BHEI', 'EI', 'KB'};


np = length(problems);  
% ns = length(seeds);
na = length(algos);

%--construct result save path
plotpath = strcat(pwd, '\plots');
best_fl = cell(1, np);
best_flnum = cell(1, np);
fighn = figure(1);
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
            fout_folder = strcat(pwd, '\resultfolder_ll\gecco21\', prob.name, '_', num2str(nvar), '_', algos{kk});
            fout_file = strcat(fout_folder, '\fl_', num2str(jj), '.csv' )
            
            fl = csvread(fout_file);
            fl_size = length(fl);
            fl_part = [];
            
            
            
            % min f so far
            for mm = ninit : fl_size-1
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
    p = [];
    for kk = 1:na
        alg_record = best_fl{ii}(kk, : );
        
        [sorted_fl, id] = sort(alg_record);
        median_id  = id(median_num);
        
        % algo_mean = mean(algos_out{kk}, 1);
        algo_mean = algos_out{kk}(median_id, :);
        

        
        


        % std
        % algo_std = std(algos_out{kk},1);
        % quantile
        algo_std = quantile (algos_out{kk}, 5);
        
        plot(algo_std(3, :), colors{kk}, 'LineWidth', 2); hold on;
        
        x = 1:length(algo_mean);
        x = [x, fliplr(x)];
        y1 = algo_std(2,:);
        y2 = algo_std(4,:);
        y = [y1, fliplr(y2)];
        fill(x, y, colors{kk}, 'FaceAlpha', 0.3, 'EdgeColor','none', 'HandleVisibility','off');
        
    end
    % title(prob.name, 'FontSize', 16);
    % legend(legs{1}, legs{2}, legs{3},  'FontSize', 20);
    legend(legs,  'FontSize', 20);
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