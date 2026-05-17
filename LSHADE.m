% function [best_solution, best_fitness, curve_LSADE] = LSHADE(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj)
%     %% 参数初始化
%     dim = variables_no;
%     population_size = pop_size;
%     min_pop_size = 4; % LSHADE 建议最小种群数
% 
%     memory_size = 5; 
%     memory_F = 0.5 * ones(memory_size, 1);
%     memory_CR = 0.5 * ones(memory_size, 1);
%     memory_pos = 1;
% 
%     % 初始化种群
%     population = unifrnd(lower_bound, upper_bound, [population_size, dim]);
%     fitness_values = zeros(population_size, 1);
%     for i = 1:population_size
%         fitness_values(i) = fobj(population(i, :));
%     end
% 
%     [best_fitness, best_idx] = min(fitness_values);
%     best_solution = population(best_idx, :);
% 
%     curve_LSADE = zeros(max_iter, 1);
% 
%     %% 主循环
%     for iter = 1:max_iter
%         success_F = [];
%         success_CR = [];
%         diff_fitness = [];
% 
%         trial_population = zeros(population_size, dim);
%         trial_fitness_values = zeros(population_size, 1);
% 
%         % 排序以支持 p-best 选择
%         [~, sorted_idx] = sort(fitness_values);
% 
%         for i = 1:population_size
%             % 选择内存索引
%             mem_idx = randi(memory_size);
%             mu_F = memory_F(mem_idx);
%             mu_CR = memory_CR(mem_idx);
% 
%             % 生成 F (柯西分布) 和 CR (正态分布)
%             CR = normrnd(mu_CR, 0.1);
%             CR = max(0, min(1, CR));
% 
%             while true
%                 % F 采用柯西分布: mu_F + 0.1 * tan(pi * (rand - 0.5))
%                 F = mu_F + 0.1 * tan(pi * (rand - 0.5));
%                 if F > 0, break; end
%             end
%             F = min(1, F);
% 
%             % 变异操作: DE/current-to-pbest/1
%             p_best_rate = 0.11; % 常用比例
%             p_best_idx = sorted_idx(randi(max(2, round(p_best_rate * population_size))));
%             p_best_vec = population(p_best_idx, :);
% 
%             % 选择 r1, r2
%             r = randperm(population_size, 2);
%             while any(r == i), r = randperm(population_size, 2); end
% 
%             mutant_vector = population(i, :) + ...
%                             F * (p_best_vec - population(i, :)) + ...
%                             F * (population(r(1), :) - population(r(2), :));
% 
%             % 边界检查
%             mutant_vector = max(min(mutant_vector, upper_bound), lower_bound);
% 
%             % 交叉操作
%             j_rand = randi(dim);
%             trial_vec = population(i, :);
%             for j = 1:dim
%                 if rand() <= CR || j == j_rand
%                     trial_vec(j) = mutant_vector(j);
%                 end
%             end
% 
%             trial_population(i, :) = trial_vec;
%             trial_fitness_values(i) = fobj(trial_vec);
% 
%             % 选择与成功参数记录
%             if trial_fitness_values(i) <= fitness_values(i)
%                 if trial_fitness_values(i) < fitness_values(i)
%                     success_F = [success_F; F];
%                     success_CR = [success_CR; CR];
%                     diff_fitness = [diff_fitness; fitness_values(i) - trial_fitness_values(i)];
%                 end
%                 population(i, :) = trial_population(i, :);
%                 fitness_values(i) = trial_fitness_values(i);
%             end
%         end
% 
%         % 更新全局最优
%         [min_val, min_idx] = min(fitness_values);
%         if min_val < best_fitness
%             best_fitness = min_val;
%             best_solution = population(min_idx, :);
%         end
% 
%         % 更新历史内存 (基于 Lehmer Mean)
%         if ~isempty(success_F)
%             weights = diff_fitness / sum(diff_fitness);
%             memory_F(memory_pos) = sum(weights .* (success_F.^2)) / sum(weights .* success_F);
%             memory_CR(memory_pos) = sum(weights .* success_CR);
% 
%             memory_pos = mod(memory_pos, memory_size) + 1;
%         end
% 
%         % 线性种群规模删减 (L-R)
%         new_pop_size = round(pop_size + (min_pop_size - pop_size) * (iter / max_iter));
%         if new_pop_size < population_size
%             [~, sorted_idx] = sort(fitness_values);
%             population = population(sorted_idx(1:new_pop_size), :);
%             fitness_values = fitness_values(sorted_idx(1:new_pop_size));
%             population_size = new_pop_size;
%         end
% 
%         curve_LSADE(iter) = best_fitness;
%     end
% end

function [best_solution, best_fitness, curve_LSADE] = LSHADE(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj)
    %% 1. 参数初始化
    dim = variables_no;
    population_size = pop_size;
    min_pop_size = 4; % LSHADE 建议最小种群数
    
    memory_size = 5; 
    memory_F = 0.5 * ones(memory_size, 1);
    memory_CR = 0.5 * ones(memory_size, 1);
    memory_pos = 1;
    
    % --- 修复：确保边界向量维度与种群矩阵 [M x N] 一致 ---
    % 将 1xN 的边界向量复制成 MxN 的矩阵
    LB_mat = repmat(lower_bound, population_size, 1); 
    UB_mat = repmat(upper_bound, population_size, 1);
    
    % 使用修正后的边界矩阵生成初始种群
    population = unifrnd(LB_mat, UB_mat);
    % ------------------------------------------------
    
    fitness_values = zeros(population_size, 1);
    for i = 1:population_size
        fitness_values(i) = fobj(population(i, :));
    end
    
    [best_fitness, best_idx] = min(fitness_values);
    best_solution = population(best_idx, :);
    
    curve_LSADE = zeros(max_iter, 1);
    
    %% 2. 主循环
    for iter = 1:max_iter
        success_F = [];
        success_CR = [];
        diff_fitness = [];
        
        % 排序以支持 p-best 选择
        [~, sorted_idx] = sort(fitness_values);
        
        for i = 1:population_size
            % 选择内存索引
            mem_idx = randi(memory_size);
            mu_F = memory_F(mem_idx);
            mu_CR = memory_CR(mem_idx);
            
            % 生成 CR (正态分布)
            CR = normrnd(mu_CR, 0.1);
            CR = max(0, min(1, CR));
            
            % 生成 F (柯西分布)
            while true
                F = mu_F + 0.1 * tan(pi * (rand - 0.5));
                if F > 0, break; end
            end
            F = min(1, F);
            
            % 变异操作: DE/current-to-pbest/1
            p_best_rate = 0.11; 
            p_best_idx = sorted_idx(randi(max(2, round(p_best_rate * population_size))));
            p_best_vec = population(p_best_idx, :);
            
            r = randperm(population_size, 2);
            while any(r == i), r = randperm(population_size, 2); end
            
            mutant_vector = population(i, :) + ...
                            F * (p_best_vec - population(i, :)) + ...
                            F * (population(r(1), :) - population(r(2), :));
            
            % 边界检查 (使用原始向量)
            mutant_vector = max(min(mutant_vector, upper_bound), lower_bound);
            
            % 交叉操作
            j_rand = randi(dim);
            trial_vec = population(i, :);
            for j = 1:dim
                if rand() <= CR || j == j_rand
                    trial_vec(j) = mutant_vector(j);
                end
            end
            
            trial_fit = fobj(trial_vec);
            
            % 选择与成功参数记录
            if trial_fit <= fitness_values(i)
                if trial_fit < fitness_values(i)
                    success_F = [success_F; F];
                    success_CR = [success_CR; CR];
                    diff_fitness = [diff_fitness; fitness_values(i) - trial_fit];
                end
                population(i, :) = trial_vec;
                fitness_values(i) = trial_fit;
            end
        end
        
        % 更新全局最优
        [min_val, min_idx] = min(fitness_values);
        if min_val < best_fitness
            best_fitness = min_val;
            best_solution = population(min_idx, :);
        end
        
        % 更新历史内存 (Lehmer Mean)
        if ~isempty(success_F)
            weights = diff_fitness / sum(diff_fitness);
            memory_F(memory_pos) = sum(weights .* (success_F.^2)) / sum(weights .* success_F);
            memory_CR(memory_pos) = sum(weights .* success_CR);
            memory_pos = mod(memory_pos, memory_size) + 1;
        end
        
        % 线性种群规模删减 (L-R)
        new_pop_size = round(pop_size + (min_pop_size - pop_size) * (iter / max_iter));
        if new_pop_size < population_size
            [~, s_idx] = sort(fitness_values);
            population = population(s_idx(1:new_pop_size), :);
            fitness_values = fitness_values(s_idx(1:new_pop_size));
            population_size = new_pop_size;
        end
        
        curve_LSADE(iter) = best_fitness;
    end
end