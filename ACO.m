% 
% function [bestf,bestx,BestCost]=ACO(nPop,MaxIt,VarMin,VarMax,nVar,CostFunction)
% %% Problem Definition
% % VarMin= Decision Variables Lower Bound
% % VarMax= Decision Variables Upper Bound
% % MaxIt= Maximum Number of Iterations
% % nPop=Population Size (Archive Size)
% VarSize=[1 nVar];   % Variables Matrix Size
% nSample=40;         % Sample Size
% q=0.5;              % Intensification Factor (Selection Pressure)
% zeta=1;             % Deviation-Distance Ratio
% %% Initialization
% % Create Empty Individual Structure
% empty_individual.Position=[];
% empty_individual.Cost=[];
% % Create Population Matrix
% pop=repmat(empty_individual,nPop,1);
% % Initialize Population Members
% for i=1:nPop
% 
%     % Create Random Solution
% %     pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
%      pop(i).Position=initialization(1,nVar,VarMax,VarMin);
%     % Evaluation
%     pop(i).Cost=CostFunction(pop(i).Position);
% 
% end
% % Sort Population
% [~, SortOrder]=sort([pop.Cost]);
% pop=pop(SortOrder);
% % Update Best Solution Ever Found
% BestSol=pop(1);
% % Array to Hold Best Cost Values
% BestCost=zeros(MaxIt,1);
% % Solution Weights
% w=1/(sqrt(2*pi)*q*nPop)*exp(-0.5*(((1:nPop)-1)/(q*nPop)).^2);
% % Selection Probabilities
% p=w/sum(w);
% %% ACOR Main Loop
% for it=1:MaxIt
% 
%     % Means
%     s=zeros(nPop,nVar);
%     for l=1:nPop
%         s(l,:)=pop(l).Position;
%     end
% 
%     % Standard Deviations
%     sigma=zeros(nPop,nVar);
%     for l=1:nPop
%         D=0;
%         for r=1:nPop
%             D=D+abs(s(l,:)-s(r,:));
%         end
%         sigma(l,:)=zeta*D/(nPop-1);
%     end
% 
%     % Create New Population Array
%     newpop=repmat(empty_individual,nSample,1);
%     for t=1:nSample
% 
%         % Initialize Position Matrix
%         newpop(t).Position=zeros(VarSize);
% 
%         % Solution Construction
%         for i=1:nVar
% 
%             % Select Gaussian Kernel
%             l=RouletteWheelSelection(p);
% 
%             % Generate Gaussian Random Variable
%             newpop(t).Position(i)=s(l,i)+sigma(l,i)*randn;
% 
%         end
% 
%         % Evaluation
%         newpop(t).Cost=CostFunction(newpop(t).Position);
% 
%     end
% 
%     % Merge Main Population (Archive) and New Population (Samples)
%     pop=[pop
%          newpop]; %#ok
% 
%     % Sort Population
%     [~, SortOrder]=sort([pop.Cost]);
%     pop=pop(SortOrder);
% 
%     % Delete Extra Members
%     pop=pop(1:nPop);
% 
%     % Update Best Solution Ever Found
%     BestSol=pop(1);
% 
%     % Store Best Cost
%     BestCost(it)=BestSol.Cost;
% 
%     % Show Iteration Information
% %     disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% 
% end
% %% Results
% bestf = BestCost(end);
% bestx = BestSol.Position;
% end
% function j=RouletteWheelSelection(P)
%     r=rand;
% 
%     C=cumsum(P);
% 
%     j=find(r<=C,1,'first');
% end

function [best_solution, best_fitness, curve_ACO] = ACO(pop_size, max_iter, lower_bound, upper_bound, variables_no, fobj)
    %% 1. 参数对齐与初始化
    nPop = pop_size;              % 存档大小 (Archive Size)
    MaxIt = max_iter;             % 最大迭代次数
    VarMin = lower_bound;         % 下限
    VarMax = upper_bound;         % 上限
    nVar = variables_no;          % 变量维度
    CostFunction = fobj;          % 目标函数
    
    VarSize = [1 nVar];           % 变量矩阵大小
    nSample = 40;                 % 每一代生成的样本数量
    q = 0.5;                      % 强化因子（选择压力）
    zeta = 1;                     % 偏离距离比（控制收敛速度）

    % 创建空个体结构体
    empty_individual.Position = [];
    empty_individual.Cost = [];

    % 初始化种群矩阵
    pop = repmat(empty_individual, nPop, 1);

    % 初始化种群成员
    for i = 1:nPop
        % 随机产生初始解 (兼容标量和向量边界)
        pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
        % 计算适应度
        pop(i).Cost = CostFunction(pop(i).Position);
    end

    % 排序并记录初始最优
    [~, SortOrder] = sort([pop.Cost]);
    pop = pop(SortOrder);
    BestSol = pop(1);

    % 初始化收敛曲线数组
    curve_ACO = zeros(MaxIt, 1);

    % 计算解的权重 (基于高斯分布)
    w = 1/(sqrt(2*pi)*q*nPop) * exp(-0.5 * (((1:nPop)-1)/(q*nPop)).^2);
    % 选择概率
    p = w / sum(w);

    %% 2. ACOR 主循环
    for it = 1:MaxIt
        
        % 提取当前存档中的所有位置信息 (用于计算均值)
        s = zeros(nPop, nVar);
        for l = 1:nPop
            s(l,:) = pop(l).Position;
        end
        
        % 计算每个解在每一维上的标准差 sigma
        sigma = zeros(nPop, nVar);
        for l = 1:nPop
            D = 0;
            for r = 1:nPop
                D = D + abs(s(l,:) - s(r,:));
            end
            sigma(l,:) = zeta * D / (nPop - 1);
        end
        
        % 生成新样本 (New Population)
        newpop = repmat(empty_individual, nSample, 1);
        for t = 1:nSample
            newpop(t).Position = zeros(VarSize);
            
            % 构造解：对每一维单独进行高斯采样
            for i = 1:nVar
                % 轮盘赌选择一个基准解 (高斯核)
                l = RouletteWheelSelection_ACO(p);
                % 基于所选解生成高斯随机变量
                newpop(t).Position(i) = s(l,i) + sigma(l,i) * randn;
            end
            
            % 边界处理
            newpop(t).Position = max(min(newpop(t).Position, VarMax), VarMin);
            
            % 计算新解的适应度
            newpop(t).Cost = CostFunction(newpop(t).Position);
        end
        
        % 合并旧存档与新生成的样本
        pop = [pop; newpop]; %#ok
         
        % 重新排序
        [~, SortOrder] = sort([pop.Cost]);
        pop = pop(SortOrder);
        
        % 截断：只保留前 nPop 个最优秀的解进入下一代存档
        pop = pop(1:nPop);
        
        % 更新当前历史最优
        BestSol = pop(1);
        
        % 存储收敛曲线数据
        curve_ACO(it) = BestSol.Cost;
    end

    %% 3. 输出赋值
    best_solution = BestSol.Position;
    best_fitness = BestSol.Cost;
end

%% 辅助函数：轮盘赌选择
function j = RouletteWheelSelection_ACO(P)
    r = rand;
    C = cumsum(P);
    j = find(r <= C, 1, 'first');
    % 容错处理
    if isempty(j)
        j = randi(numel(P));
    end
end