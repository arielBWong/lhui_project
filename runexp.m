%%this script is to run ulego with multiple seeds
%
clearvars;
close all;

problem_folder = strcat(pwd,'/problems');
addpath(problem_folder);
problem_folder = strcat(pwd,'/problems/SMD');
addpath(problem_folder);
problem_folder = strcat(pwd,'/problems/SMDm');
addpath(problem_folder);
problem_folder = strcat(pwd,'/problems/BLTP');
addpath(problem_folder);

problem_folder = strcat(pwd,'/Surrogate/Methods/Surrogate');
addpath(problem_folder);

problem_folder = strcat(pwd,'/globalsolver');
addpath(problem_folder);

problem_folder = strcat(pwd,'/ND_Sort');
addpath(problem_folder);

problem_folder = strcat(pwd,'/Utility');
addpath(problem_folder);

%          
% problems = {'ackley(3, 3)', 'levy(3, 3)','rastrigin(3, 3)','dsm1(3, 3)', ... %  multimodal global structure  heavy modality and weak modality
%     'tp3(3, 3)', 'tp5(3, 3)', 'tp7(3, 3)',... %'Shekel(3, 3)', ... % multimodal no global structure
%     'Zakharov(3, 3)', 'smd2(3, 3)',  'rosenbrock(3, 3)', ... % unimodal
%     'smd1(3, 3)', 'smd3(3, 3)', 'smd4(3, 3)' ,  'tp6(3, 3)', 'tp9(3, 3)'};

localmethods = { 'KN'}; %, 'KN'
seeds = linspace(1,11, 11);
problems = {'smd6x(1,2,1)','smd7x(1,2,1)',  'smd8x(1,2,1)',...
             'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
             'smd8()','smd9()', 'smd10()','smd11()','smd12()' };
         
% problems = { 'smd3()','smd4()','smd5()','smd6()','smd7()','smd8()','smd9()'};
% problems = {'smd10()','smd11()','smd12()' ,'smd6x(1,2,1)','smd7x(1,2,1)',  'smd8x(1,2,1)' };
problem  ={ 'smd1()','smd2()'};
% problems = {'ackley(3, 3)', 'levy(3, 3)','rastrigin(3, 3)','dsm1(3, 3)', ... %  multimodal global structure  heavy modality and weak modality
%     'tp3(3, 3)', 'tp5(3, 3)', 'tp7(3, 3)', 'Shekel(3, 3)', ... % multimodal no global structure
%     'Zakharov(3, 3)', 'smd2(3, 3)',  'rosenbrock(3, 3)', ... % unimodal
%     'smd1(3, 3)', 'smd3(3, 3)', 'smd4(3, 3)' ,  'tp6(3, 3)', 'tp9(3, 3)'};

% ulego_klocal_singlelevel('Shekel(3, 3)', 4, 'EIMnext_daceUpdate' ,'normalization_y',true, 'BH');

% parpool('local', 48);
% ulego_klocal('smd4(1,1,1)', 1, 'EIMnext_daceUpdate','normalization_y' , true, 'KN');
% return

np = length(problems);
ns = length(seeds);
nm = length(localmethods);


cc = 1;
for i = 1:np
    for j = 1:ns
        for k = 1:nm
            paras{ cc} = {problems{i}, seeds(j),'EIMnext_daceUpdate', true,  localmethods{k}};
            cc = cc + 1;
        end

    end
end
%
for i = 1:np
    for j = 1:ns
        paras{ cc} = {problems{i}, seeds(j), 'EIMnext_daceUpdate', false, 'EI'};
        cc = cc + 1;
    end
end


for i = 1:np
    for j = 1:ns
        paras{ cc} = {problems{i}, seeds(j), 'Believer_nextUpdate', false, 'KB'};
        cc = cc + 1;
    end
end

nrun = length(paras);
for i = 1:nrun
    % ulego_klocal_singlelevel(paras{i}{1}, paras{i}{2}, paras{i}{3}, 'normalization_y',paras{i}{4},paras{i}{5});
    % tic;
    ulego_klocal(paras{i}{1},  paras{i}{2},  paras{i}{3}, 'normalization_y' ,paras{i}{4},paras{i}{5});
     % toc;
end

