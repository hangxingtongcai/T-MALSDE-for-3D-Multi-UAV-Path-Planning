function [best_solution, best_fitness, curve_GA] = GA(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj)
    %% 1. 参数对齐与初始化
    popsize = pop_size;        % 种群规模
    lenchrom = variables_no;    % 变量维度
    maxgen = max_iter;         % 进化次数
    lb = lower_bound;
    ub = upper_bound;
    fun = fobj;                % 适应度函数
    
    pc = 0.8;                  % 设置交叉概率
    pm = 0.05;                 % 设置变异概率
    
    % 确保边界为向量格式
    if(max(size(ub)) == 1)
       ub = ub .* ones(1, lenchrom);
       lb = lb .* ones(1, lenchrom);  
    end
    bound = [lb', ub'];        % 变量范围矩阵 [min, max]
    
    %% 2. 产生初始种群
    GApop = zeros(popsize, lenchrom);
    fitness = zeros(popsize, 1);
    for i = 1:popsize
        % 随机产生个体
        GApop(i,:) = Code(lenchrom, bound);       
        % 计算适应度
        fitness(i) = fun(GApop(i,:));            
    end
    
    % 初始化最优记录
    [bestfitness, bestindex] = min(fitness);
    zbest = GApop(bestindex,:);   % 全局最佳位置
    fitnesszbest = bestfitness;   % 全局最佳适应度值
    
    % 个体历史最优（GA主要依靠种群演化，此处保留用于逻辑兼容）
    gbest = GApop;                
    fitnessgbest = fitness;       
    
    curve_GA = zeros(1, maxgen);

    %% 3. 迭代寻优
    for i = 1:maxgen
        % 3.1 选择操作
        GApop = Select2(GApop, fitness, popsize);
        
        % 3.2 交叉操作
        GApop = Cross(pc, lenchrom, GApop, popsize, bound);
        
        % 3.3 变异操作
        GApop = Mutation(pm, lenchrom, GApop, popsize, [i maxgen], bound);
        
        % 3.4 评价与更新
        for j = 1:popsize
            % 计算新个体适应度
            fitness(j) = fun(GApop(j,:));
            
            % 个体最优更新
            if fitness(j) < fitnessgbest(j)
                gbest(j,:) = GApop(j,:);
                fitnessgbest(j) = fitness(j);
            end
            
            % 全局最优更新
            if fitness(j) < fitnesszbest
                zbest = GApop(j,:);
                fitnesszbest = fitness(j);
            end
        end
        
        % 记录收敛曲线
        curve_GA(i) = fitnesszbest;     
    end
    
    % 输出参数赋值
    best_score = fitnesszbest;
    best_pos = zbest;
    
    % 适配接口命名的最终赋值
    best_fitness = best_score;
    best_solution = best_pos;
end

%% --- 子函数：选择 (轮盘赌) ---
function ret = Select2(individuals, fitness, sizepop)
    % 适应度转换（求最小值问题，将小值映射为大权重）
    % 增加极小量防止除以0
    fit_weights = 1 ./ (fitness + 1e-10);
    sumfitness = sum(fit_weights);
    sumf = fit_weights ./ sumfitness;
    
    index = [];
    for i = 1:sizepop
        pick = rand;
        while pick == 0, pick = rand; end
        for j = 1:sizepop
            pick = pick - sumf(j);
            if pick < 0
                index = [index j];
                break;
            end
        end
    end
    
    % 防止索引为空的容错处理
    if isempty(index)
        ret = individuals;
    else
        ret = individuals(index, :);
    end
end

%% --- 子函数：交叉 ---
function ret = Cross(pcross, lenchrom, chrom, sizepop, bound)
    for i = 1:sizepop 
        pick = rand(1,2);
        while prod(pick) == 0, pick = rand(1,2); end
        index = ceil(pick .* sizepop);
        
        if rand > pcross, continue; end
        
        flag = 0;
        while flag == 0
            pos = ceil(rand * lenchrom); 
            pick_val = rand; 
            v1 = chrom(index(1), pos);
            v2 = chrom(index(2), pos);
            
            % 线性交叉
            chrom(index(1), pos) = pick_val * v2 + (1 - pick_val) * v1;
            chrom(index(2), pos) = pick_val * v1 + (1 - pick_val) * v2; 
            
            % 检查可行性
            if test(lenchrom, bound, chrom(index(1), :)) && test(lenchrom, bound, chrom(index(2), :))
                flag = 1;
            end
        end
    end
    ret = chrom;
end

%% --- 子函数：变异 ---
function ret = Mutation(pmutation, lenchrom, chrom, sizepop, iter_info, bound)
    for i = 1:sizepop  
        if rand > pmutation, continue; end
        
        flag = 0;
        while flag == 0
            pos = ceil(rand * lenchrom);
            if pos <= 0, pos = 1; end
            
            v = chrom(i, pos);
            v1 = v - bound(pos, 1);
            v2 = bound(pos, 2) - v;
            
            pick = rand; 
            % 非均匀变异：随迭代次数增加变异范围逐渐减小
            if pick > 0.5
                delta = v2 * (1 - rand^((1 - iter_info(1) / iter_info(2))^2));
                chrom(i, pos) = v + delta;
            else
                delta = v1 * (1 - rand^((1 - iter_info(1) / iter_info(2))^2));
                chrom(i, pos) = v - delta;
            end
            
            if test(lenchrom, bound, chrom(i, :)), flag = 1; end
        end
    end
    ret = chrom;
end

%% --- 子函数：边界检查 ---
function flag = test(lenchrom, bound, code)
    flag = 1;
    for i = 1:lenchrom
        if code(i) < bound(i, 1) || code(i) > bound(i, 2)
            flag = 0;
            break;
        end
    end
end

%% --- 子函数：初始化编码 ---
function ret = Code(lenchrom, bound)
    flag = 0;
    while flag == 0
        pick = rand(1, lenchrom);
        ret = bound(:, 1)' + (bound(:, 2) - bound(:, 1))' .* pick;
        if test(lenchrom, bound, ret), flag = 1; end
    end
end