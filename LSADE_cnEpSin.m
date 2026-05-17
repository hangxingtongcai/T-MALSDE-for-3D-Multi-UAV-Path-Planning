function [best_solution, best_fitness, convergence_curve] = LSADE_cnEpSin(pop_size, max_iter, lb, ub, dim, fobj)

% ================= 初始化 =================
X = lb + (ub - lb) .* rand(pop_size, dim);
fitness = zeros(pop_size, 1);

for i = 1:pop_size
    fitness(i) = fobj(X(i, :));
end

[best_fitness, idx] = min(fitness);
best_solution = X(idx, :);

convergence_curve = zeros(max_iter, 1);

% 自适应参数初始化
CRm = 0.5;
Fm = 0.5;

% ================= 主循环 =================
for t = 1:max_iter

    X_new = X;

    for i = 1:pop_size

        % ===== EpSin 参数 =====
        F = Fm + 0.3 * sin(2*pi*t / max_iter);
        F = max(0.1, min(0.9, F));

        CR = CRm + 0.1 * sin(2*pi*t / max_iter + pi/2);
        CR = max(0.1, min(0.9, CR));

        % ===== 策略选择 =====
        if rand < 0.5
            % DE/rand/1
            idxs = randperm(pop_size, 3);
            r1 = idxs(1); r2 = idxs(2); r3 = idxs(3);
            V = X(r1,:) + F * (X(r2,:) - X(r3,:));
        else
            % current-to-best/1
            idxs = randperm(pop_size, 2);
            r1 = idxs(1); r2 = idxs(2);
            V = X(i,:) + F * (best_solution - X(i,:)) + F * (X(r1,:) - X(r2,:));
        end

        % ===== 交叉 =====
        U = X(i,:);
        j_rand = randi(dim);

        for j = 1:dim
            if rand < CR || j == j_rand
                U(j) = V(j);
            end
        end

        % ===== 边界处理 =====
        U = max(U, lb);
        U = min(U, ub);

        % ===== 选择 =====
        fit_U = fobj(U);

        if fit_U < fitness(i)
            X_new(i,:) = U;
            fitness(i) = fit_U;

            % 更新最优
            if fit_U < best_fitness
                best_fitness = fit_U;
                best_solution = U;
            end
        end
    end

    % 更新种群
    X = X_new;

    % ===== 参数自适应 =====
    CRm = 0.9 * CRm + 0.1 * CR;
    Fm = 0.9 * Fm + 0.1 * F;

    convergence_curve(t) = best_fitness;

end

end