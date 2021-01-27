%%this script is to run ulego with multiple seeds
%
clearvars;
close all;
% problem_folder = strcat(pwd,'\problems\BLTP');
% addpath(problem_folder);

% problems = { 'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
             % 'smd8()','smd9()', 'smd10()','smd11()','smd12()'};
% problems = { 'bltp1()','bltp2()','bltp3()','bltp4()','bltp5()','bltp6()','bltp7()',...
             % 'bltp8()','bltp9()', 'bltp10()','bltp11()'};
      
% problems = { 'smd5()','smd6()','smd7()', 'smd8()'};
         
problems = {'ackley(3, 3)', 'levy(3, 3)','rastrigin(3, 3)','dsm1(3, 3)', ... %  multimodal global structure  heavy modality and weak modality
    'tp3(3, 3)', 'tp5(3, 3)', 'tp7(3, 3)','Shekel(3, 3)', ... % multimodal no global structure
    'Zakharov(3, 3)', 'smd2(3, 3)',  'rosenbrock(3, 3)', ... % unimodal
    'smd1(3, 3)', 'smd3(3, 3)', 'smd4(3, 3)' ,  'tp6(3, 3)', 'tp9(3, 3)'};

localmethods = { 'BH', 'KN'};
seeds = linspace(1, 21, 21);

% problems = { 'smd1()','smd2()','smd3()','smd4()','smd5()','smd6()','smd7()',...
%               'smd8()', 'smd9()', 'smd10()','smd11()','smd12()'
%               
%               };

% problems = {'smd1(1,1,1)','smd2(1,1,1)','smd3(1,1,1)','smd4(1,1,1)','smd5(1,1,1)','smd6(1,0, 1,1)','smd7(1,1,1)',...
%                'smd8(1,1,1)', 'smd9(1,1,1)', 'smd11(1,1,1)', 'smd10(1,1,1)','smd12(1,1,1)'};

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
parfor i = 1:nrun
    ulego_klocal_singlelevel(paras{i}{1}, paras{i}{2}, paras{i}{3}, 'normalization_y',paras{i}{4},paras{i}{5});
    % tic;
    % ulego_klocal(paras{i}{1}, paras{i}{2},'EIMnext_dace' , 'EIM_evaldace', 'normalization_y',);
    % fprintf('%d\n', paras{i}{2});
    %  ulego_klocal_singlelevel(paras{i}{1}, paras{i}{2},'EIMnext_daceUpdate', 'normalization_y', true,'BH');
    % ulego_klocal_singlelevel(paras{i}{1}, paras{i}{2},'EIMnext_daceUpdate', 'normalization_y', true, 'KN');   % eim 
    % ulego_klocal_singlelevel(paras{i}{1}, paras{i}{2},'EIMnext_daceUpdate', 'normalization_y', false, 'EI');  % hyb
    % ulego_klocal_singlelevel(paras{i}{1}, paras{i}{2},'Believer_nextUpdate','normalization_y', false, 'KB');  % kb
    % toc;
   
end

