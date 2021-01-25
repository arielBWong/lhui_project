classdef mobp8
    properties
        p = 1;
        q = 2;
        n_lvar;
        n_uvar;
        xu_bl;
        xu_bu;
        xl_bl;
        xl_bu;
        name = 'mobp8';
        uopt = NaN;
        lopt = 0; % double check needed
    end
    methods
        function obj = mobp8()
            % level variables
            obj.n_lvar = obj.q;
            obj.n_uvar = obj.p;
            
            % bounds
            %init bound upper level
            obj.xu_bl = ones(1, obj.p) * -1;
            obj.xu_bu = ones(1, obj.p) * 2 ;
           
           
            % init bound lower level
            obj.xl_bl = ones(1, obj.q) * -1;
            obj.xl_bu = ones(1, obj.q) * 2;      
        end
        
        function [f, c] = evaluate_u(obj, xu, xl) 
            %-obj
            f(:, 1) = (xl(:, 1) - 1).^2 + xl(:, 2).^2 + xu .^2;
            f(:, 2) = (xl(:, 1) - 1) .^2 + xl(:, 2) .^2 + (xu-1).^2;
                 
            %-cie
            c= [];            
        end
        
        
        function [f, c] = evaluate_l(obj, xu, xl)          
            %-obj
            f = (xl(:, 1) - xu) .^ 2 + xl(:, 2) .^ 2;
            
            %-cie
           c=[];
        
         end
    end
end
