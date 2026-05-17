% 
% 
% % ----------------------- README ------------------------------------------
% %     最后一次修改     ：2024/7/20
% %                         欢迎关注₍^.^₎♡
% %                    ------------
% %     项目             ：JADE算法
% %                    ------------
% %     参考文献         ：J. Zhang and A. C. Sanderson, "JADE: adaptive differential evolution
% %                       with optional external archive," IEEE Trans. Evolut. Comput., vol. 13,
% %                       no. 5, pp. 945-958, 2009.
% %     微信公众号/CSDN/知乎/B站 ：KAU的云实验台
% %     定制或答疑加微信 : KAUsysyt
% %     付费代码(更全)   ：https://mbd.pub/o/author-a2iWlGtpZA==
% %     免费代码         ：公众号后台回复"资源"
% % -------------------------------------------------------------------------
% 
% function [fitnessBestP,bestP,Convergence_curve]=JADE(SearchAgents_no,Gmax,lb,ub,dim,fobj)
% 
% 
% 
% G=0;%设置迭代器（当前迭代代数）
% % lu = [lb * ones(1, dim); ub * ones(1, dim)];
% lu = [lb .* ones(1, dim); ub .* ones(1, dim)];
% lb = lb .* ones(1, dim);
% ub = ub .* ones(1, dim);
% c = 1/10;% 控制因子
% p = 0.05;
% top=p*SearchAgents_no;%每代中最优的top个
% A=[];%初始归档种群为空集
% t=1;%记录归档种群A中的个体个数
% 
% % 初始 CR F
% uCR=0.5;%初始化交叉概率
% uF=0.5;%初始化缩放因子
% 
% % 种群初始化
% P = repmat(lu(1, :), SearchAgents_no, 1) + rand(SearchAgents_no, dim) .* (repmat(lu(2, :) - lu(1, :), SearchAgents_no, 1));
% fitnessP=zeros(1,SearchAgents_no);
% for i=1:SearchAgents_no
%     fitnessP(i)=fobj(P(i,:));
% end
% 
% % 主迭代
% while G < Gmax
% 
%     Scr=[];%初始成功参加变异的个体的交叉概率为空集
%     Sf=[];%初始成功参加变异的个体的缩放因子为空集
%     n1=1;%记录Scr中的元素个数
%     n2=1;%记录Sf中的元素个数
% 
%     % 更新适应度和CR F
%     for i=1:SearchAgents_no
%         fitnessP(i)=fobj(P(i,:));
%         % 更新
%         CR(i)=0.5;
%         F(i)=0.5;
%         while (CR(i)>1||CR(i)<0)
%             CR(i)=normrnd(uCR,0.1);
%         end
%         if (F(i)>1)
%             F(i)=1;
%         end
%         while (F(i)<=0)
%             F(i)=cauchyrnd(uF,0.1);
%         end
%     end
% 
%     % 获得种群前p个个体，方便后面随机选择
%     [fitnessBestP,indexBestP]=min(fitnessP);
%     bestP=P(indexBestP,:);
%     [~,indexSortP]=sort(fitnessP);
%     for i=1:top
%         bestTopP(i,:)=P(indexSortP(i),:);
%     end
% 
%     % 变异操作
%     for i=1:SearchAgents_no
%         %从top个个体中随机选出一个作为Xpbest
%         k0=randperm(top,1);
%         Xpbest=bestTopP(k0,:);
% 
%         %从当前种群P中随机选出P1
%         k1=randi(SearchAgents_no);
%         P1=P(k1,:);
%         while (k1==i||k1==k0)
%             k1=randi(SearchAgents_no);
%             P1=P(k1,:);
%         end
% 
%         %从P∪A中随机选出P2
%         PandA=[P;A];
%         [num,~]=size(PandA);
%         k2=randi(num);
%         P2=PandA(k2,:);
%         while (k2==i||k2==k0||k2==k1)
%             k2=randi(num);
%             P2=PandA(k2,:);
%         end
% 
%         % DE/current-to-pbest/1
%         V(i,:)=P(i,:)+F(i).*(Xpbest-P(i,:))+F(i).*(P1-P2);
%     end
% 
%     % 交叉操作
%     for i=1:SearchAgents_no
%         jrand=randi([1,dim]);
%         for j=1:dim
%             k3=rand;
%             if(k3<=CR(i)||j==jrand)
%                 U(i,j)=V(i,j);
%             else
%                 U(i,j)=P(i,j);
%             end
%         end
%     end
% 
%     % 边界处理
%     for i=1:SearchAgents_no
%         for j=1:dim
%             while (U(i,j)>ub(j) || U(i,j)<lb(j))
%                 U(i,j)=(ub(j)-lb(j))*rand+lb(j);
%             end
%         end
%     end
% 
%     % 选择操作
%     for i=1:SearchAgents_no
%         fitnessU(i)=fobj(U(i,:));
%         if(fitnessU(i)<fitnessP(i))
%             A(t,:)=P(i,:);% 淘汰的个体放在A
%             P(i,:)=U(i,:);% 更新
%             fitnessP(i)=fitnessU(i);
%             Scr(n1)=CR(i);
%             Sf(n2)=F(i);
%             t=t+1;
%             n1=n1+1;
%             n2=n2+1;
%             if(fitnessU(i)<fitnessBestP)
%                 fitnessBestP=fitnessU(i);
%                 bestP=U(i,:);
%             end
%         end
%     end
% 
%     %判断归档种群A的规模是否在NP之内，若大于，则随机移除个体使其规模保持NP
%     [tA,~]=size(A);
%     if tA>SearchAgents_no
%         nRem=tA-SearchAgents_no;
%         k4=randperm(tA,nRem);
%         A(k4,:)=[];
%         [tA,~]=size(A);
%         t=tA+1;
%     end
% 
%     %自适应参数，更新uCR和uF
%     [~,ab]=size(Scr);
%     if ab~=0
%         newSf=(sum(Sf.^2))/(sum(Sf));
%         uCR=(1-c)*uCR+c.*mean(Scr);
%         uF=(1-c)*uF+c.*newSf;
%     end
% 
% 
% 
%     G=G+1;
%     Convergence_curve(G) = fitnessBestP;
% end
% 
% end
% 


% function [fitnessBestP, bestP, Convergence_curve] = JADE(SearchAgents_no, Gmax, lb, ub, dim, fobj)
function [ bestP,fitnessBestP, Convergence_curve] = JADE(SearchAgents_no, Gmax, lb, ub, dim, fobj)

    % JADE: Adaptive Differential Evolution with Optional External Archive
    
    % --- 参数初始化 ---
    G = 0; 
    % 确保边界为矩阵形式
    if scalar(lb) && scalar(ub)
        lb = lb * ones(1, dim);
        ub = ub * ones(1, dim);
    end
    
    c = 1/10; % 自适应参数更新权重
    p = 0.05; % 前 p*100% 的精英个体
    % 关键修复：确保 top 为正整数且至少为 1
    top = max(1, round(p * SearchAgents_no)); 
    
    A = []; % 外部存档 A
    % uCR = 0.5; % 平均交叉概率
    % uF = 0.5;  % 平均缩放因子
     uCR = 0.8; % 平均交叉概率
    uF = 0.2;  % 平均缩放因子
    % --- 种群初始化 ---
    % 使用 repmat 确保维度匹配
    P = repmat(lb, SearchAgents_no, 1) + rand(SearchAgents_no, dim) .* (repmat(ub - lb, SearchAgents_no, 1));
    fitnessP = zeros(1, SearchAgents_no);
    for i = 1:SearchAgents_no
        fitnessP(i) = fobj(P(i,:));
    end
    
    % 记录初始最优
    [fitnessBestP, indexBestP] = min(fitnessP);
    bestP = P(indexBestP, :);
    Convergence_curve = zeros(1, Gmax);

    % --- 主迭代循环 ---
    while G < Gmax
        G = G + 1;
        Scr = []; % 成功更新个体的 CR 集合
        Sf = [];  % 成功更新个体的 F 集合
        
        CR = zeros(1, SearchAgents_no);
        F = zeros(1, SearchAgents_no);
        V = zeros(SearchAgents_no, dim);
        U = zeros(SearchAgents_no, dim);

        % 生成变异和交叉参数
        for i = 1:SearchAgents_no
            % 生成 CR (正态分布，截断在 [0,1])
            CR(i) = normrnd(uCR, 0.1);
            CR(i) = max(0, min(1, CR(i)));
            
            % 生成 F (柯西分布，截断在 (0,1])
            % 使用 tan(pi*(rand-0.5)) 模拟 cauchyrnd
            while F(i) <= 0
                F(i) = uF + 0.1 * tan(pi * (rand - 0.5));
            end
            if F(i) > 1
                F(i) = 1;
            end
        end

        % 排序以获取前 top 个个体
        [~, indexSortP] = sort(fitnessP);
        bestTopP = P(indexSortP(1:top), :);

        % --- 变异操作 ---
        for i = 1:SearchAgents_no
            % 随机选择前 p-best 中的一个
            k0 = randi(top); 
            Xpbest = bestTopP(k0, :);
            
            % 随机选择 r1 (从当前种群)
            r1 = randi(SearchAgents_no);
            while r1 == i
                r1 = randi(SearchAgents_no);
            end
            P1 = P(r1, :);
            
            % 随机选择 r2 (从 P ∪ A)
            PandA = [P; A];
            num_PandA = size(PandA, 1);
            r2 = randi(num_PandA);
            while r2 == i || r2 == r1
                r2 = randi(num_PandA);
            end
            P2 = PandA(r2, :);
            
            % DE/current-to-pbest/1 策略
            V(i, :) = P(i, :) + F(i) * (Xpbest - P(i, :)) + F(i) * (P1 - P2);
        end

        % --- 交叉操作 ---
        for i = 1:SearchAgents_no
            jrand = randi(dim);
            for j = 1:dim
                if rand <= CR(i) || j == jrand
                    U(i, j) = V(i, j);
                else
                    U(i, j) = P(i, j);
                end
            end
        end

        % --- 边界处理与选择操作 ---
        for i = 1:SearchAgents_no
            % 边界检查：若越界则随机重置（或设为边界值）
            for j = 1:dim
                if U(i, j) > ub(j) || U(i, j) < lb(j)
                    U(i, j) = lb(j) + rand * (ub(j) - lb(j));
                end
            end
            
            % 计算新个体适应度
            fitnessU = fobj(U(i, :));
            
            % 贪婪选择
            if fitnessU < fitnessP(i)
                % 将被淘汰的旧个体放入存档 A
                A = [A; P(i, :)]; 
                
                % 更新个体
                P(i, :) = U(i, :);
                fitnessP(i) = fitnessU;
                
                % 记录成功的参数用于更新 uCR 和 uF
                Scr = [Scr, CR(i)];
                Sf = [Sf, F(i)];
                
                % 更新全局最优
                if fitnessU < fitnessBestP
                    fitnessBestP = fitnessU;
                    bestP = U(i, :);
                end
            end
        end

        % --- 维护存档 A 的规模 ---
        if size(A, 1) > SearchAgents_no
            idx = randperm(size(A, 1), size(A, 1) - SearchAgents_no);
            A(idx, :) = [];
        end

        % --- 自适应参数更新 ---
        if ~isempty(Scr)
            uCR = (1 - c) * uCR + c * mean(Scr);
            % 使用 Lehmer Mean 更新 uF
            uF = (1 - c) * uF + c * (sum(Sf.^2) / sum(Sf));
        end
        
        Convergence_curve(G) = fitnessBestP;
    end
end

% 辅助函数：判断标量
function out = scalar(x)
    out = isscalar(x);
end