classdef bltp1
    properties
        p = 1;
        q = 1;
        r = 1;
        n_lvar;
        n_uvar;
        xu_bl;
        xu_bu;
        xl_bl;
        xl_bu;
        uopt = 0;
        lopt = 200;
        name =  'bltp1';
    end
    methods
        function obj = bltp1()
            % level variables
            obj.n_lvar = obj.q + obj.r;
            obj.n_uvar = obj.p + obj.r;
            
            % bounds
            %init bound upper level
            xu_bl_1 = zeros(1, obj.p);
            xu_bu_1 = ones(1, obj.p) * 50.0;
            xu_bl_2 = zeros(1, obj.r);
            xu_bu_2 = ones(1, obj.r) * 50.0;
            obj.xu_bl = [xu_bl_1, xu_bl_2];
            obj.xu_bu = [xu_bu_1, xu_bu_2];
            
            % init bound lower level
            xl_bl_1 = ones(1, obj.q) * (-10.0);
            xl_bu_1 = ones(1, obj.q) * 20.0;
            xl_bl_2 = ones(1, obj.r) * (-10.0);
            xl_bu_2 = ones(1, obj.r) * 20.0;
            obj.xl_bl = [xl_bl_1, xl_bl_2];
            obj.xl_bu = [xl_bu_1, xl_bu_2];
            
        end
        
        function [f, c] = evaluate_u(obj, xu, xl)
            xu1 = xu(:, 1 : obj.p);
            xu2 = xu(:, obj.p + 1: obj.p + obj.r);
            
            xl1 = xl(:, 1 : obj.q);
            xl2 = xl(:, obj.q+1 : obj.q+obj.r);
            %-obj
            f = 2*xu1 + 2*xu2 - 3*xl1 - 3*xl2 - 60;
            %-cie
            c = xu1 + xu2 + xl1 - 2*xl2 - 40;
            
        end
        
        
        function [f, c] = evaluate_l(obj, xu, xl)
            xu1 = xu(:, 1 : obj.p);
            xu2 = xu(:, obj.p + 1: obj.p + obj.r);
            
            xl1 = xl(:, 1 : obj.q);
            xl2 = xl(:, obj.q+1 : obj.q+obj.r);
            %-obj
            f = (xl1-xu1+20).^2 + (xl2-xu2+20).^2;
            %-cie
            c(:, 1) = 2*xl1-xu1+10;
            c(:, 2) = 10-xu2+2*xl2;
            
        end
    end
end
