classdef Mystery
    properties       
        p = 1;
        q = 2;
        n_lvar;
        n_uvar;
        n_con;
        n_obj;
        xu_bl;
        xu_bu;
        xl_bl;
        xl_bu;
        ref;
        xprime = [2.7450,2.3523];
        fprime = -1.1743;
        name = 'Mystery';

    end
    methods
        function obj = Mystery()
            obj.n_lvar = obj.q;
            obj.n_uvar = obj.p;
            % bounds
            %init bound upper level
            obj.xu_bl = zeros(1, obj.p);
            obj.xu_bu = ones(1, obj.p);
            
            
            % init bound lower level
            obj.xl_bl = [0, 0];
            obj.xl_bu = [5, 5];
        end
        function [f, con] = evaluate(obj, x)
            x1 = x(:,1); x2 = x(:, 2);
            
            part1 = 0.01 * (x2 - x1.^2).^2;
            part2 = (1 - x1).^2;
            part3 = 2 * (2 - x2).^2;
            part4 = 7 * sin(0.5 * x1) * sin(0.7 .* x1 .* x2);

            f = 2 + part1 + part2 + part3 + part4;

            con = -sin(x1 - x2 - pi/8);
     
        end
        
        function [f, con] = evaluate_l(obj, xu, x)
            x1 = x(:,1); x2 = x(:, 2);
            
            part1 = 0.01 * (x2 - x1.^2).^2;
            part2 = (1 - x1).^2;
            part3 = 2 * (2 - x2).^2;
            part4 = 7 * sin(0.5 * x1) .* sin(0.7 .* x1 .* x2);

            f = 2 + part1 + part2 + part3 + part4;

            con = -sin(x1 - x2 - pi/8);
     
        end
    end
end