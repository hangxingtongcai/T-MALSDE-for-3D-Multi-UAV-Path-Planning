%%  闲鱼：深度学习与智能算法
%%  唯一官方店铺：https://mbd.pub/o/author-aWWbm3BtZw==
%%  微信公众号：强盛机器学习，关注公众号获得更多免费代码！
% Developed in MATLAB R2013b
% Source codes demo version 1.0
% _____________________________________________________

% Main paper:
% Harris hawks optimization: Algorithm and applications
% Ali Asghar Heidari, Seyedali Mirjalili, Hossam Faris, Ibrahim Aljarah, Majdi Mafarja, Huiling Chen
% Future Generation Computer Systems, 
% DOI: https://doi.org/10.1016/j.future.2019.02.028
% https://www.sciencedirect.com/science/article/pii/S0167739X18313530
% _____________________________________________________

% You can run the HHO code online at codeocean.com  https://doi.org/10.24433/CO.1455672.v1
% You can find the HHO code at https://github.com/aliasghar68/Harris-hawks-optimization-Algorithm-and-applications-.git
% _____________________________________________________

%  Author, inventor and programmer: Ali Asghar Heidari,
%  PhD research intern, Department of Computer Science, School of Computing, National University of Singapore, Singapore
%  Exceptionally Talented Ph. DC funded by Iran's National Elites Foundation (INEF), University of Tehran
%  03-03-2019

%  Researchgate: https://www.researchgate.net/profile/Ali_Asghar_Heidari

%  e-Mail: as_heidari@ut.ac.ir, aliasghar68@gmail.com,
%  e-Mail (Singapore): aliasgha@comp.nus.edu.sg, t0917038@u.nus.edu
% _____________________________________________________
%  Co-author and Advisor: Seyedali Mirjalili
%
%         e-Mail: ali.mirjalili@gmail.com
%                 seyedali.mirjalili@griffithuni.edu.au
%
%       Homepage: http://www.alimirjalili.com
% _____________________________________________________
%  Co-authors: Hossam Faris, Ibrahim Aljarah, Majdi Mafarja, and Hui-Ling Chen

%       Homepage: http://www.evo-ml.com/2019/03/02/hho/
% _____________________________________________________
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Harris's hawk optimizer: In this algorithm, Harris' hawks try to catch the rabbit.

% T: maximum iterations, N: populatoin size, CNVG: Convergence curve
% To run HHO: [Rabbit_Energy,Rabbit_Location,CNVG]=HHO(N,T,lb,ub,dim,fobj)

% function [Rabbit_Energy,Rabbit_Location,CNVG]=HHO(N,T,lb,ub,dim,fobj)
% % function [Rabbit_Energy,Rabbit_Location,CNVG]=HHO(N,T,lb,ub,dim,fhd,varargin)
% % disp('HHO is now tackling your problem')
% 
% % initialize the location and Energy of the rabbit
% Rabbit_Location=zeros(1,dim);
% Rabbit_Energy=inf;
% 
% %Initialize the locations of Harris' hawks
% X=initialization(N,dim,ub,lb);
% 
% CNVG=zeros(1,T);
% 
% t=0; % Loop counter
% 
% while t<T
%     for i=1:size(X,1)
%         % Check boundries
%         FU=X(i,:)>ub;FL=X(i,:)<lb;X(i,:)=(X(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;
%         % fitness of locations
%         fitness=fobj(X(i,:));
%          % fitness=feval(fhd,X(i,:)',varargin{:});  
%         % Update the location of Rabbit
%         if fitness<Rabbit_Energy
%             Rabbit_Energy=fitness;
%             Rabbit_Location=X(i,:);
%         end
%     end
% 
%     E1=2*(1-(t/T)); % factor to show the decreaing energy of rabbit
%     % Update the location of Harris' hawks
%     for i=1:size(X,1)
%         E0=2*rand()-1; %-1<E0<1
%         Escaping_Energy=E1*(E0);  % escaping energy of rabbit
% 
%         if abs(Escaping_Energy)>=1
%             %% Exploration:
%             % Harris' hawks perch randomly based on 2 strategy:
% 
%             q=rand();
%             rand_Hawk_index = floor(N*rand()+1);
%             X_rand = X(rand_Hawk_index, :);
%             if q<0.5
%                 % perch based on other family members
%                 X(i,:)=X_rand-rand()*abs(X_rand-2*rand()*X(i,:));
%             elseif q>=0.5
%                 % perch on a random tall tree (random site inside group's home range)
%                 X(i,:)=(Rabbit_Location(1,:)-mean(X))-rand()*((ub-lb)*rand+lb);
%             end
% 
%         elseif abs(Escaping_Energy)<1
%             %% Exploitation:
%             % Attacking the rabbit using 4 strategies regarding the behavior of the rabbit
% 
%             %% phase 1: surprise pounce (seven kills)
%             % surprise pounce (seven kills): multiple, short rapid dives by different hawks
% 
%             r=rand(); % probablity of each event
% 
%             if r>=0.5 && abs(Escaping_Energy)<0.5 % Hard besiege
%                 X(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-X(i,:));
%             end
% 
%             if r>=0.5 && abs(Escaping_Energy)>=0.5  % Soft besiege
%                 Jump_strength=2*(1-rand()); % random jump strength of the rabbit
%                 X(i,:)=(Rabbit_Location-X(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));
%             end
% 
%             %% phase 2: performing team rapid dives (leapfrog movements)
%             if r<0.5 && abs(Escaping_Energy)>=0.5, % Soft besiege % rabbit try to escape by many zigzag deceptive motions
% 
%                 Jump_strength=2*(1-rand());
%                 X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:));
%                 FU=X1>ub;FL=X1<lb;X1=(X1.*(~(FU+FL)))+ub.*FU+lb.*FL;
%                 if fobj(X1)<fobj(X(i,:)) % improved move?
%                     X(i,:)=X1;
%                 else % hawks perform levy-based short rapid dives around the rabbit
%                     X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-X(i,:))+rand(1,dim).*Levy(dim);
%                     FU=X2>ub;FL=X2<lb;X2=(X2.*(~(FU+FL)))+ub.*FU+lb.*FL;
%                     if (fobj(X2)<fobj(X(i,:))), % improved move?
%                         X(i,:)=X2;
%                     end
%                 end
%             end
% 
%             if r<0.5 && abs(Escaping_Energy)<0.5, % Hard besiege % rabbit try to escape by many zigzag deceptive motions
%                 % hawks try to decrease their average location with the rabbit
%                 Jump_strength=2*(1-rand());
%                 X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X));
%                 FU=X1>ub;FL=X1<lb;X1=(X1.*(~(FU+FL)))+ub.*FU+lb.*FL;
% 
%                 if fobj(X1)<fobj(X(i,:)) % improved move?
%                     X(i,:)=X1;
%                 else % Perform levy-based short rapid dives around the rabbit
%                     X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(X))+rand(1,dim).*Levy(dim);
%                     FU=X2>ub;FL=X2<lb;X2=(X2.*(~(FU+FL)))+ub.*FU+lb.*FL;
%                     if (fobj(X2)<fobj(X(i,:))), % improved move?
%                         X(i,:)=X2;
%                     end
%                 end
%             end
%             %%
%         end
%     end
%     t=t+1;
%     CNVG(t)=Rabbit_Energy;
% end
% 
% end
% 
% % ___________________________________
% function o=Levy(d)
% beta=1.5;
% sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
% u=randn(1,d)*sigma;v=randn(1,d);step=u./abs(v).^(1/beta);
% o=step;
% end


function [best_solution, best_fitness, curve_HHO] = HHO(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj)
    %% 1. 参数对齐与初始化
    N = pop_size;
    T = max_iter;
    lb = lower_bound;
    ub = upper_bound;
    dim = variables_no;
    
    % 初始化猎物（兔子）的位置和能量
    Rabbit_Location = zeros(1, dim);
    Rabbit_Energy = inf;
    
    % 初始化哈里斯鹰种群位置
    % 修复：直接使用 unifrnd 确保初始化在边界内，且适配向量边界
    LB_mat = repmat(lb, N, 1);
    UB_mat = repmat(ub, N, 1);
    X = unifrnd(LB_mat, UB_mat);
    
    curve_HHO = zeros(1, T);
    t = 0; % 循环计数器

    %% 2. 主循环
    while t < T
        for i = 1:size(X, 1)
            % 边界检查
            X(i, :) = max(min(X(i, :), ub), lb);
            
            % 计算适应度
            fitness = fobj(X(i, :));
            
            % 更新猎物位置（当前全局最优）
            if fitness < Rabbit_Energy
                Rabbit_Energy = fitness;
                Rabbit_Location = X(i, :);
            end
        end
        
        % E1: 猎物能量衰减因子，从2递减到0
        E1 = 2 * (1 - (t / T)); 
        
        for i = 1:size(X, 1)
            E0 = 2 * rand() - 1;       % 初态能量 [-1, 1]
            Escaping_Energy = E1 * E0; % 逃逸能量
            
            %% 阶段 1: 探索 (Exploration)
            if abs(Escaping_Energy) >= 1
                q = rand();
                rand_Hawk_index = floor(N * rand() + 1);
                X_rand = X(rand_Hawk_index, :);
                if q < 0.5
                    % 策略 1: 基于其他家庭成员的位置
                    X(i, :) = X_rand - rand() * abs(X_rand - 2 * rand() * X(i, :));
                elseif q >= 0.5
                    % 策略 2: 随机栖息在范围内的树上
                    X(i, :) = (Rabbit_Location - mean(X)) - rand() * ((ub - lb) * rand + lb);
                end
                
            %% 阶段 2: 开发 (Exploitation)
            elseif abs(Escaping_Energy) < 1
                r = rand(); % 逃逸成功概率
                
                % 2.1 软包围 (Soft besiege)
                if r >= 0.5 && abs(Escaping_Energy) >= 0.5
                    Jump_strength = 2 * (1 - rand()); % 随机跳跃强度
                    X(i, :) = (Rabbit_Location - X(i, :)) - Escaping_Energy * abs(Jump_strength * Rabbit_Location - X(i, :));
                
                % 2.2 硬包围 (Hard besiege)
                elseif r >= 0.5 && abs(Escaping_Energy) < 0.5
                    X(i, :) = (Rabbit_Location) - Escaping_Energy * abs(Rabbit_Location - X(i, :));
                
                % 2.3 带有激进快速俯冲的软包围
                elseif r < 0.5 && abs(Escaping_Energy) >= 0.5
                    Jump_strength = 2 * (1 - rand());
                    X1 = Rabbit_Location - Escaping_Energy * abs(Jump_strength * Rabbit_Location - X(i, :));
                    X1 = max(min(X1, ub), lb);
                    
                    if fobj(X1) < fobj(X(i, :))
                        X(i, :) = X1;
                    else
                        X2 = Rabbit_Location - Escaping_Energy * abs(Jump_strength * Rabbit_Location - X(i, :)) + rand(1, dim) .* Levy(dim);
                        X2 = max(min(X2, ub), lb);
                        if fobj(X2) < fobj(X(i, :))
                            X(i, :) = X2;
                        end
                    end
                
                % 2.4 带有激进快速俯冲的硬包围
                elseif r < 0.5 && abs(Escaping_Energy) < 0.5
                    Jump_strength = 2 * (1 - rand());
                    X1 = Rabbit_Location - Escaping_Energy * abs(Jump_strength * Rabbit_Location - mean(X));
                    X1 = max(min(X1, ub), lb);
                    
                    if fobj(X1) < fobj(X(i, :))
                        X(i, :) = X1;
                    else
                        X2 = Rabbit_Location - Escaping_Energy * abs(Jump_strength * Rabbit_Location - mean(X)) + rand(1, dim) .* Levy(dim);
                        X2 = max(min(X2, ub), lb);
                        if fobj(X2) < fobj(X(i, :))
                            X(i, :) = X2;
                        end
                    end
                end
            end
        end
        
        t = t + 1;
        curve_HHO(t) = Rabbit_Energy;
    end
    
    %% 3. 输出赋值
    best_solution = Rabbit_Location;
    best_fitness = Rabbit_Energy;
end

%% 辅助函数：莱维飞行 (Levy Flight)
function o = Levy(d)
    beta = 1.5;
    sigma = (gamma(1 + beta) * sin(pi * beta / 2) / (gamma((1 + beta) / 2) * beta * 2^((beta - 1) / 2)))^(1 / beta);
    u = randn(1, d) * sigma;
    v = randn(1, d);
    step = u ./ abs(v).^(1 / beta);
    o = step;
end
