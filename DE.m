% % 定制代码和答疑加微信：shudongyouma        
% % 更多代码关注微信公众号：优码漩涡
% % 唯一店铺下载链接：https://mbd.pub/o/author-bGaXk25tZA==
% % 禁止倒卖，侵权必究！！！
% 
% % 差分进化算法（Differential Evolution): DE
% 
% function [BestScore,BestPos,BestCost]=DE(nPop,MaxIt,VarMin,VarMax,nVar,CostFunction)
% 
% %% Problem Definition
% 
% % CostFunction=@(x) Sphere(x);    % Cost Function
% 
% % nVar=20;            % Number of Decision Variables
% 
% VarSize=[1 nVar];   % Decision Variables Matrix Size
% 
% % VarMin=-5;          % Lower Bound of Decision Variables
% % VarMax= 5;          % Upper Bound of Decision Variables
% 
% %% DE Parameters
% 
% % MaxIt=1000;      % Maximum Number of Iterations
% 
% % nPop=50;        % Population Size
% 
% beta_min=0.2;   % Lower Bound of Scaling Factor
% beta_max=0.8;   % Upper Bound of Scaling Factor
% 
% pCR=0.2;        % Crossover Probability
% 
% %% Initialization
% 
% empty_individual.Position=[];
% empty_individual.Cost=[];
% 
% BestSol.Cost=inf;
% 
% pop=repmat(empty_individual,nPop,1);
% 
% for i=1:nPop
% 
%     pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
% 
%     pop(i).Cost=CostFunction(pop(i).Position);
% 
%     if pop(i).Cost<BestSol.Cost
%         BestSol=pop(i);
%     end
% 
% end
% 
% BestCost=zeros(MaxIt,1);
% 
% %% DE Main Loop
% 
% for it=1:MaxIt
% 
%     for i=1:nPop
% 
%         x=pop(i).Position;
% 
%         A=randperm(nPop);
% 
%         A(A==i)=[];
% 
%         a=A(1);
%         b=A(2);
%         c=A(3);
% 
%         % Mutation
%         %beta=unifrnd(beta_min,beta_max);
%         beta=unifrnd(beta_min,beta_max,VarSize);
%         y=pop(a).Position+beta.*(pop(b).Position-pop(c).Position);
%         y = max(y, VarMin);
% 		y = min(y, VarMax);
% 
%         % Crossover
%         z=zeros(size(x));
%         j0=randi([1 numel(x)]);
%         for j=1:numel(x)
%             if j==j0 || rand<=pCR
%                 z(j)=y(j);
%             else
%                 z(j)=x(j);
%             end
%         end
% 
%         NewSol.Position=z;
%         NewSol.Cost=CostFunction(NewSol.Position);
% 
%         if NewSol.Cost<pop(i).Cost
%             pop(i)=NewSol;
% 
%             if pop(i).Cost<BestSol.Cost
%                BestSol=pop(i);
%             end
%         end
% 
%     end
% 
%     % Update Best Cost
%     BestCost(it)=BestSol.Cost;
%     BestScore=BestSol.Cost;
%     BestPos=BestSol.Position;
%     % Show Iteration Information
% %     disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
% 
% end
% 
% end
% %% Show Results
% 
% % figure;
% % %plot(BestCost);
% % semilogy(BestCost, 'LineWidth', 2);
% % xlabel('Iteration');
% % ylabel('Best Cost');
% % grid on;


function [BestPos, BestScore, BestCost] = DE(nPop, MaxIt, VarMin, VarMax, nVar, CostFunction)
    %% 1. 参数定义
    VarSize = [1 nVar];   
    beta_min = 0.2;   % 缩放因子下限
    beta_max = 0.8;   % 缩放因子上限
    pCR = 0.2;        % 交叉概率

    % 确保边界是行向量，防止减法报错
    VarMin = VarMin(:)'; 
    VarMax = VarMax(:)';

    %% 2. 初始化
    empty_individual.Position = [];
    empty_individual.Cost = [];
    BestSol.Cost = inf;
    BestSol.Position = [];
    
    pop = repmat(empty_individual, nPop, 1);
    
    for i = 1:nPop
        % 随机初始化位置
        pop(i).Position = VarMin + rand(VarSize) .* (VarMax - VarMin);
        % 计算初始成本
        pop(i).Cost = CostFunction(pop(i).Position);
        
        % 更新全局最优
        if pop(i).Cost < BestSol.Cost
            BestSol = pop(i);
        end
    end
    
    % 用于存储每一代的最优值
    BestCost = zeros(MaxIt, 1);

    %% 3. DE 主循环
    for it = 1:MaxIt
        for i = 1:nPop
            x = pop(i).Position;
            
            % 变异操作: 选择三个不同的随机个体
            A = randperm(nPop);
            A(A == i) = [];
            a = A(1); b = A(2); c = A(3);
            
            beta = unifrnd(beta_min, beta_max, VarSize);
            y = pop(a).Position + beta .* (pop(b).Position - pop(c).Position);
            
            % 边界检查 (边界裁剪)
            y = max(y, VarMin);
            y = min(y, VarMax);
            
            % 交叉操作
            z = x;
            j0 = randi([1, nVar]);
            for j = 1:nVar
                if j == j0 || rand <= pCR
                    z(j) = y(j);
                end
            end
            
            % 选择操作
            NewSol.Position = z;
            NewSol.Cost = CostFunction(NewSol.Position);
            
            if NewSol.Cost < pop(i).Cost
                pop(i) = NewSol;
                
                % 更新全局最优
                if pop(i).Cost < BestSol.Cost
                    BestSol = pop(i);
                end
            end
        end
        
        % 记录当前迭代的最优得分
        BestCost(it) = BestSol.Cost;
    end
    
    %% 4. 输出赋值
    % 严格确保 BestScore 是标量，BestPos 是向量
    BestPos = BestSol.Position;  % 1 x nVar 向量
    BestScore = BestSol.Cost;    % 1 x 1 标量
end