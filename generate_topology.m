
clc;
clear;
close all;


AREA_SIZE = 1000;          % m, 1 km x 1 km
NUM_BS = 15;
NUM_TASK = 5;
MAX_DISTANCE = 1000;       % m



    max_try = 1e6;
    success = false;

    for trial = 1:max_try

  
        BS = AREA_SIZE * rand(NUM_BS, 2);


        Task = AREA_SIZE * rand(NUM_TASK, 2);

  
        Distance = zeros(NUM_TASK, NUM_BS);

        for i = 1:NUM_TASK
            for j = 1:NUM_BS
                Distance(i,j) = norm(Task(i,:) - BS(j,:));
            end
        end


        if max(Distance(:)) <= MAX_DISTANCE
            success = true;
            break;
        end
    end

%========================
Distance = zeros(NUM_TASK, NUM_BS);

for i = 1:NUM_TASK
    for j = 1:NUM_BS
        Distance(i,j) = norm(Task(i,:) - BS(j,:));
    end
end


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

