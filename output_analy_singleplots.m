seedmax = 11;
median_num = 6;

problems = {'smd4()'};
        
algos = { 'local', 'vanilla'}; % , 'lleim_gp', 'lladp_gp'
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
fighn = figure(1);
% process each problem
for ii = 1: np
    prob = eval(problems{ii});
    nvar = prob.n_lvar;
    ninit = 20; % 11 * nvar - 1;
    



     plotfl = [];
     for jj = 1:seedmax 
         
         clf(fighn);
%          for kk = 1:na    
%             % save folder and save name
%             fout_folder = strcat(pwd, '\resultfolder_ll\', prob.name, '_', num2str(nvar), '_', algos{kk});
%             
%             fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' );           
%             fl      = csvread(fout_file);
%             convergef   = [];
%             for m = 21:length(fl)
%                 convergef = [convergef, min(fl(1:m))];
%             end
%             
%             plot(convergef,colors{kk}, 'LineWidth', 2); hold on;
%          end
          f2 = {};
          for kk = 1:na    
            % save folder and save name
            fout_folder = strcat(pwd, '\resultfolder_ll\', prob.name, '_', num2str(nvar), '_', algos{kk}, 'EI');
            
            fout_file   = strcat(fout_folder, '\fl_', num2str(jj), '.csv' )          
            fl      = csvread(fout_file);            
            f2{end + 1} = fl;
            
         end
        n = length(f2{1});
        plot(f2{1}); hold on;
        plot(f2{2}(1:n))
        
        legend('local', 'vanilla');
        outfile = strcat(plotpath, '\', prob.name, '_seed', num2str(jj), '.fig');
        
       % saveas(fighn, outfile);

    end
end

