%% generate_paper_topology_1km.m
% 按论文仿真设置生成任务节点和 BS 位置
%
% 论文设置：
%   1) 区域：1 km x 1 km
%   2) BS 数量：15
%   3) 任务位置数量：5
%   4) BS 和任务位置：二维区域内均匀随机部署
%   5) UE 按 Task1 -> Task2 -> ... -> Task5 顺序移动
%   6) UE 到达每个任务位置时生成一个计算任务
%
% 额外约束：
%   任意任务节点到任意 BS 的距离 <= 1000 m
%
% 默认使用一组已经生成并检查通过的固定坐标，保证实验可复现。
% 若需要重新随机生成，把 USE_FIXED_COORDS 改成 false。

clc;
clear;
close all;

%% ============================================================
% 1. 基本参数
% =============================================================
AREA_SIZE = 1000;          % m, 1 km x 1 km
NUM_BS = 15;
NUM_TASK = 5;
MAX_DISTANCE = 1000;       % m
RANDOM_SEED = 2026;

USE_FIXED_COORDS = true;

%% ============================================================
% 2. 一组固定且满足约束的坐标
% =============================================================
if USE_FIXED_COORDS

    % 每一行：[x, y]，单位 m
    BS = [
        179, 640;
        467, 371;
        355, 791;
        905, 177;
        653, 298;
        967, 920;
        636, 753;
        515, 826;
        448, 339;
        278, 226;
        526, 431;
        663,  13;
        448, 365;
        195, 595;
        435, 300
    ];

    Task = [
        209, 875;
        797, 607;
        345, 947;
        563, 433;
        900, 319
    ];

else

    %% ========================================================
    % 3. 按论文要求重新随机生成
    %    均匀分布 + 拒绝采样保证最远距离 <= 1 km
    % =========================================================
    rng(RANDOM_SEED);

    max_try = 1e6;
    success = false;

    for trial = 1:max_try

        % 15 个 BS 在 1 km x 1 km 区域内均匀随机部署
        BS = AREA_SIZE * rand(NUM_BS, 2);

        % 5 个任务位置在同一区域内均匀随机生成
        Task = AREA_SIZE * rand(NUM_TASK, 2);

        % 计算 5 x 15 距离矩阵
        Distance = zeros(NUM_TASK, NUM_BS);

        for i = 1:NUM_TASK
            for j = 1:NUM_BS
                Distance(i,j) = norm(Task(i,:) - BS(j,:));
            end
        end

        % 只有所有 Task-BS 距离都不超过 1 km 才接受
        if max(Distance(:)) <= MAX_DISTANCE
            success = true;
            fprintf('第 %d 次随机生成满足条件。\n', trial);
            break;
        end
    end

    if ~success
        error('在最大尝试次数内未生成满足约束的拓扑。');
    end
end

%% ============================================================
% 4. 计算任务节点到所有 BS 的距离矩阵
% =============================================================
Distance = zeros(NUM_TASK, NUM_BS);

for i = 1:NUM_TASK
    for j = 1:NUM_BS
        Distance(i,j) = norm(Task(i,:) - BS(j,:));
    end
end

%% ============================================================
% 5. 严格检查约束
% =============================================================
max_distance = max(Distance(:));

fprintf('\n最大 Task-BS 距离 = %.3f m\n', max_distance);

if max_distance > MAX_DISTANCE
    error('存在 Task-BS 距离超过 1 km！');
else
    fprintf('检查通过：所有任务节点到所有 BS 的距离均 <= 1 km。\n');
end

% 每个任务节点对应的最近和最远 BS 距离
minDist = min(Distance, [], 2);
maxDist = max(Distance, [], 2);

fprintf('\n每个任务位置的最近/最远 BS 距离：\n');
for i = 1:NUM_TASK
    fprintf('Task %d: min = %.3f m, max = %.3f m\n', ...
        i, minDist(i), maxDist(i));
end

%% ============================================================
% 6. 输出坐标
% =============================================================
fprintf('\nBS positions [ID, X, Y] (m):\n');
disp([(1:NUM_BS)', BS]);

fprintf('\nTask positions [ID, X, Y] (m):\n');
disp([(1:NUM_TASK)', Task]);

%% ============================================================
% 7. 保存数据
% =============================================================
BS_data = [(1:NUM_BS)', BS];
Task_data = [(1:NUM_TASK)', Task];

writematrix(BS_data, 'BS_positions.txt', 'Delimiter', 'tab');
writematrix(Task_data, 'Task_positions.txt', 'Delimiter', 'tab');
writematrix(Distance, 'Task_BS_distances.txt', 'Delimiter', 'tab');

save('paper_topology_1km.mat', ...
    'BS', 'Task', 'Distance', 'minDist', 'maxDist');

%% ============================================================
% 8. 绘制论文场景拓扑图
% =============================================================
figure('Color','w');
hold on;
box on;
grid on;
axis equal;

xlim([0 AREA_SIZE]);
ylim([0 AREA_SIZE]);

% BS
scatter(BS(:,1), BS(:,2), 70, '^', 'filled', ...
    'DisplayName', 'BS');

% Task locations
scatter(Task(:,1), Task(:,2), 80, 'o', 'filled', ...
    'DisplayName', 'Task location');

% UE 顺序移动轨迹
plot(Task(:,1), Task(:,2), '--', 'LineWidth', 1.5, ...
    'DisplayName', 'UE trajectory');

% 标号
for j = 1:NUM_BS
    text(BS(j,1)+10, BS(j,2), sprintf('BS%d',j), ...
        'FontSize', 8);
end

for i = 1:NUM_TASK
    text(Task(i,1)+10, Task(i,2)+15, sprintf('T%d',i), ...
        'FontSize', 10, 'FontWeight', 'bold');
end

xlabel('X (m)');
ylabel('Y (m)');
legend('Location','bestoutside');
title('ISAC-assisted MEC simulation topology');

hold off;
