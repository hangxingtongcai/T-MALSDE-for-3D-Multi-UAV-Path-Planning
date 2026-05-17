% function [BestPos, BestScore, BestCost] = MSFDE(nPop, MaxIt, VarMin, VarMax, nVar, CostFunction)
%     %% 1. 参数与多种群初始化
%     VarSize = [1 nVar];
%     ng = 10; % 评估周期 [cite: 172]
% 
%     % 分配子种群大小 [cite: 174, 175]
%     nInd = floor(nPop * 0.2); % 每个指标子种群占20%
%     nRew = nPop - 3 * nInd;   % 奖励子种群占约40%
%     subPopSize = [nInd, nInd, nInd, nRew];
% 
%     % 初始化种群与参数 (F, CR 基于 TLBO 思想初始化) [cite: 168]
%     pop = struct('Position', [], 'Cost', [], 'F', [], 'CR', [], 'Strategy', []);
%     for i = 1:nPop
%         pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
%         pop(i).Cost = CostFunction(pop(i).Position);
%         pop(i).F = 0.5;  % 初始 F [cite: 141]
%         pop(i).CR = 0.5; % 初始 CR [cite: 143]
%     end
% 
%     [~, idx] = sort([pop.Cost]);
%     BestSol = pop(idx(1));
%     BestCost = zeros(MaxIt, 1);
% 
%     % 初始策略分配 [cite: 166]
%     strategy_pool = {'current-to-pbest', 'current-to-rbest', 'rworst-to-rbest'};
%     best_strat_idx = randi([1,3]); % 初始随机分配奖励种群给一个策略
% 
%     %% 2. MSFDE 主循环
%     for it = 1:MaxIt
%         % 每隔 ng 代评估一次策略表现，重新分配奖励种群 [cite: 172, 173]
%         if mod(it, ng) == 0
%             % (此处简化处理：统计各策略在前 ng 代的改进程度，选出最优策略索引 best_strat_idx)
%             % 实际代码中需记录各子种群的 fitness 提升
%         end
% 
%         new_pop = pop;
%         for i = 1:nPop
%             % 确定当前个体属于哪个子种群及对应的策略 [cite: 176]
%             if i <= nInd, s_idx = 1;
%             elseif i <= 2*nInd, s_idx = 2;
%             elseif i <= 3*nInd, s_idx = 3;
%             else, s_idx = best_strat_idx; % 奖励种群使用当前最优策略
%             end
% 
%             % --- A. TLBO 启发式参数更新 (教师/学习者阶段) [cite: 146, 149, 150] ---
%             % 更新 F 和 CR
%             pop(i).F = pop(i).F + rand*(BestSol.F - randi([1,2])*mean([pop.F]));
%             pop(i).CR = pop(i).CR + rand*(BestSol.CR - mean([pop.CR]));
%             pop(i).F = max(0.4, min(1.0, pop(i).F)); % 约束范围 [cite: 141]
%             pop(i).CR = max(0, min(1, pop(i).CR));
% 
%             % --- B. 交互变异操作 [cite: 165] ---
%             A = randperm(nPop, 4); A(A==i) = [];
%             r1 = A(1); r2 = A(2); r3 = A(3);
% 
%             switch strategy_pool{s_idx}
%                 case 'current-to-pbest' % 倾向于开发 [cite: 154]
%                     v = pop(i).Position + pop(i).F*(BestSol.Position - pop(i).Position) + ...
%                         pop(i).F*(pop(r1).Position - pop(r2).Position);
%                 case 'current-to-rbest' % 结合随机与最优
%                     v = pop(i).Position + pop(i).F*(pop(r1).Position - pop(i).Position) + ...
%                         pop(i).F*(pop(r2).Position - pop(r3).Position);
%                 case 'rworst-to-rbest' % 增加多样性，倾向于探索 [cite: 155]
%                     [~, worst_idx] = max([pop.Cost]);
%                     v = pop(r1).Position + pop(i).F*(BestSol.Position - pop(worst_idx).Position);
%             end
% 
%             % --- C. 交叉与选择 (保留标准DE逻辑) ---
%             v = max(min(v, VarMax), VarMin); % 边界检查
%             z = pop(i).Position;
%             j0 = randi(nVar);
%             for j = 1:nVar
%                 if j == j0 || rand <= pop(i).CR
%                     z(j) = v(j);
%                 end
%             end
% 
%             new_cost = CostFunction(z);
%             if new_cost < pop(i).Cost
%                 new_pop(i).Position = z;
%                 new_pop(i).Cost = new_cost;
%                 if new_cost < BestSol.Cost
%                     BestSol = new_pop(i);
%                 end
%             end
%         end
%         pop = new_pop;
%         BestCost(it) = BestSol.Cost;
%     end
%     BestPos = BestSol.Position;
%     BestScore = BestSol.Cost;
% end

function [best_solution, best_fitness, curve_MSFDE] = MSFDE(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj)
    %% 1. 参数与多种群初始化
    nPop = pop_size;
    MaxIt = max_iter;
    VarMin = lower_bound;
    VarMax = upper_bound;
    nVar = variables_no;
    CostFunction = fobj;
    
    VarSize = [1 nVar];
    ng = 10; % 策略评估周期
    
    % 分配子种群大小：三个指标子种群（各20%）+ 一个奖励子种群（40%）
    nInd = floor(nPop * 0.2); 
    nRew = nPop - 3 * nInd;   
    
    % 初始化种群结构
    pop = struct('Position', [], 'Cost', [], 'F', [], 'CR', []);
    
    % 兼容标量或向量边界的初始化
    for i = 1:nPop
        pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
        pop(i).Cost = CostFunction(pop(i).Position);
        pop(i).F = 0.5;  % 初始缩放因子
        pop(i).CR = 0.5; % 初始交叉概率
    end
    
    [~, idx] = sort([pop.Cost]);
    BestSol = pop(idx(1));
    curve_MSFDE = zeros(MaxIt, 1);
    
    % 策略池定义
    strategy_pool = {'current-to-pbest', 'current-to-rbest', 'rworst-to-rbest'};
    best_strat_idx = randi([1,3]); % 初始随机分配给奖励种群
    
    % 用于统计子种群改进程度的变量
    improvement = zeros(1, 3); 
    
    %% 2. MSFDE 主循环
    for it = 1:MaxIt
        % 每隔 ng 代根据各策略的改进程度，重新分配奖励种群的策略
        if mod(it, ng) == 0 && it > 1
            [~, best_strat_idx] = max(improvement);
            improvement(:) = 0; % 重置统计量
        end
        
        new_pop = pop;
        for i = 1:nPop
            % 确定当前个体所属子种群索引
            if i <= nInd, s_idx = 1;      % 指标子种群 1
            elseif i <= 2*nInd, s_idx = 2; % 指标子种群 2
            elseif i <= 3*nInd, s_idx = 3; % 指标子种群 3
            else, s_idx = best_strat_idx;  % 奖励子种群：使用最优策略
            end
            
            % --- A. TLBO 启发式参数更新 (F 和 CR 自适应) ---
            % 基于教师领导思想更新参数
            pop(i).F = pop(i).F + rand * (BestSol.F - randi([1,2]) * mean([pop.F]));
            pop(i).CR = pop(i).CR + rand * (BestSol.CR - mean([pop.CR]));
            
            % 参数约束处理
            pop(i).F = max(0.4, min(1.0, pop(i).F)); 
            pop(i).CR = max(0.0, min(1.0, pop(i).CR));
            
            % --- B. 交互变异操作 ---
            A = randperm(nPop, 4); A(A==i) = [];
            r1 = A(1); r2 = A(2); r3 = A(3);
            
            switch strategy_pool{s_idx}
                case 'current-to-pbest' % 倾向于局部开发
                    v = pop(i).Position + pop(i).F * (BestSol.Position - pop(i).Position) + ...
                        pop(i).F * (pop(r1).Position - pop(r2).Position);
                case 'current-to-rbest' % 结合随机与最优
                    v = pop(i).Position + pop(i).F * (pop(r1).Position - pop(i).Position) + ...
                        pop(i).F * (pop(r2).Position - pop(r3).Position);
                case 'rworst-to-rbest' % 倾向于全局探索
                    [~, worst_idx] = max([pop.Cost]);
                    v = pop(r1).Position + pop(i).F * (BestSol.Position - pop(worst_idx).Position);
            end
            
            % --- C. 交叉与选择 ---
            v = max(min(v, VarMax), VarMin); % 边界检查
            z = pop(i).Position;
            j0 = randi(nVar);
            for j = 1:nVar
                if j == j0 || rand <= pop(i).CR
                    z(j) = v(j);
                end
            end
            
            new_cost = CostFunction(z);
            
            % 贪婪选择逻辑
            if new_cost < pop(i).Cost
                % 记录策略改进量（仅针对前三个指标子种群统计）
                if s_idx <= 3
                    improvement(s_idx) = improvement(s_idx) + (pop(i).Cost - new_cost);
                end
                
                new_pop(i).Position = z;
                new_pop(i).Cost = new_cost;
                
                % 更新全局最优
                if new_cost < BestSol.Cost
                    BestSol = new_pop(i);
                end
            end
        end
        pop = new_pop;
        curve_MSFDE(it) = BestSol.Cost;
    end
    
    best_solution = BestSol.Position;
    best_fitness = BestSol.Cost;
end