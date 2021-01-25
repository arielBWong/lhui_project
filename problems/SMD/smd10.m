classdef smd10
    properties
        p = 1;
        q = 2;
        r = 1;
        n_lvar;
        n_uvar;
        xu_bl;
        xu_bu;
        xl_bl;
        xl_bu;
        name;
        uopt = 4.0;
        lopt = 3.0;
    end
    methods
        function obj = smd10(p, q, r)
            if nargin == 3
                obj.p = p;
                obj.q = q;
                obj.r = r;
            end
            obj.name = 'SMD10';
            
            % level variables
            obj.n_lvar = obj.q + obj.r;
            obj.n_uvar = obj.p + obj.r;
            
            % bounds
            %init bound upper level
            xu_bl_1 = ones(1, obj.p)* (-5.0);
            xu_bu_1 = ones(1, obj.p) * 10.0;
            xu_bl_2 = ones(1, obj.r)* (-5.0);
            xu_bu_2 = ones(1, obj.r) * 10.0;
            obj.xu_bl = [xu_bl_1, xu_bl_2];
            obj.xu_bu = [xu_bu_1, xu_bu_2];
            
            % init bound lower level
            xl_bl_1 = ones(1, obj.q) * (-5.0);
            xl_bu_1 = ones(1, obj.q) * 10.0;
            xl_bl_2 = ones(1, obj.r) * (-pi/2 + 1e-6);
            xl_bu_2 = ones(1, obj.r) * (pi/2  - 1e-6);
            obj.xl_bl = [xl_bl_1, xl_bl_2];
            obj.xl_bu = [xl_bu_1, xl_bu_2];
            
            
        end
        
        function [f, c] = evaluate_u(obj, xu, xl)
            xu1 = xu(:, 1 : obj.p);
            xu2 = xu(:, obj.p + 1: obj.p + obj.r);
            
            xl1 = xl(:, 1 : obj.q);
            xl2 = xl(:, obj.q+1 : obj.q+obj.r);
            
            %---f
            a = 2*ones(size(xu1));
            c = 2*ones(size(xu2));
            
            
            f = sum((xu1 - a).^2, 2) ...
                + sum((xl1).^2, 2) ...
                + sum((xu2 - c).^2, 2) - sum((xu2 - tan(xl2)).^2, 2);
            
            %----cieq
            for i=1:obj.p
                c(:, i) = xu1(:, i) + xu1(:, i).^3 - sum(xu1.^3, 2) - sum(xu2.^3, 2);
            end
            
            for i=1:obj.r
                c(:, obj.p+i) = xu2(:, i) + xu2(:, i).^3 - sum(xu2.^3, 2) - sum(xu1.^3, 2);
            end
            
            c = - c;
        end
        
        function [f, c] = evaluate_l(obj, xu, xl)
            xu1 = xu(:, 1 : obj.p);
            xu2 = xu(:, obj.p+1 : obj.p+obj.r);
            
            xl1 = xl(:, 1 : obj.q);
            xl2 = xl(:, obj.q+1 : obj.q+obj.r);
            
            b = 2*ones(size(xl1));
            
            f = sum((xu1).^2, 2) ...
                + sum((xl1 - b).^2, 2) ...
                + sum((xu2 - tan(xl2)).^2, 2);
            
            
            
            
            for i=1:obj.q
                 c(:, i) = xl1(:, i) + xl1(:, i).^3 - sum(xl1.^3, 2);
            end
            c = - c;
        end
        
        
        function xl_prime = get_xlprime(obj, xu)
            for i = 1:obj.q
                xl_prime(i) = 1/(sqrt(obj.q - 1));
            end
            
            j = 1;
            for i = obj.q + 1 : obj.q + obj.r
      
                xl_prime(i) = atan(xu(obj.p+ j));
                j = j + 1;
            end
        end
    end
end
