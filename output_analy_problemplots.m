problems = {'smd1(1,1,1)', 'smd2(1,1,1)', 'rosenbrock(2, 2)',  'Zakharov(2, 2)',...
    'levy(2, 2)', 'ackley(2, 2)',  'smd3(1,1,1)', 'smd4(1,1,1)' , ...
    'dsm1(2, 2)', 'tp7(2, 2)',  'tp9(2, 2)','Shekel(2, 2)','tp3(2, 2)',...
    'tp6(2, 2)', 'rastrigin(2, 2)', 'tp5(2, 2)'         };

problems = {'smd7x(1,1,1)'};
np = length(problems);
plotpath = 'C:\Users\z3276872\matlab_scripts\bilevel_lhui\problemlandscape\';
figh = figure;
for i =  1:np
    clf(figh);
    xu                  = [0, 0];
    prob                = eval(problems{i});
    nt                  = 200;
    local_bl            =  prob.xl_bl;
    local_bu            =  prob.xl_bu;
    x1_tst              = linspace(local_bl(1), local_bu(1), nt);
    x2_tst              = linspace(local_bl(2), local_bu(2), nt);
    
    
    [msx1, msx2]        = meshgrid(x1_tst, x2_tst);
    f                   = zeros(nt, nt);
    c1                  = zeros(nt, nt);
    
    for i =1 : nt
        for j = 1: nt
 
                f(i, j) ...
                        = prob.evaluate_l(xu, [msx1(i, j), msx2(i, j)]);
       
        end
    end
    % contour(msx1, msx2, f); hold on;
    surf(msx1, msx2, f, 'FaceAlpha',0.5, 'EdgeColor', 'none'); hold on;
    % title(prob.name);
    xlabel('x_1', 'FontSize', 20)
    ylabel('x_2',  'FontSize', 20);
    zlabel('F',  'FontSize', 20);
    
    ylh = get(gca,'ylabel');
    set(ylh, 'Rotation',0, 'FontName', 'Times New Roman');
    
    ylh = get(gca,'zlabel');
    set(ylh, 'Rotation',0, 'FontName', 'Times New Roman');
    
    xlh = get(gca,'xlabel');
    set(xlh, 'FontName', 'Times New Roman');
    colorbar
    
    % save to plot folder   
    savename = strcat(plotpath, '\', prob.name, '_landscape.fig');
    saveas(figh, savename);
    
    savename = strcat(plotpath, '\', prob.name, '_landscape.png');
    saveas(figh, savename);
    pause(1);
    % close(figure(i));
end


