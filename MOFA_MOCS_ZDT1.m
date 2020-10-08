function MOFA_MOCS_ZDT1
    %多策略协同多目标萤火虫算法
    %Programmed by Kevin Kong
    %测试问题ZDT-1
    clc;
    global NP N T_MAX gamma beta0 epsilon M V
    NP = 100;%种群大小
    T_MAX = 500;%最大迭代次数
    N = 100;%外部档案规模
    gamma = 1;%光吸收系数
    beta0 = 1;%最大吸引力
    M = 2;%目标函数个数
    V = 30;%决策变量个数
    t = 1;%迭代次数
    epsilon = get_epsilon();
    %变量范围在[0,1]
    min_range = zeros(1,V);
    max_range = ones(1,V);
    pop = init(NP,M,V,min_range,max_range);%初始化种群
    Arc = pop(non_domination_sort(pop,M,V),:);%非支配排序
    while(t <= T_MAX)
        plot(pop(:,V+1),pop(:,V+2),'*');
        str = sprintf("第%d代",t);
        title(str);
        drawnow;
        offspring = pop;%子代
        for i = 1:NP
            for j = 1:NP
                domination = get_domination(pop(i,:),pop(j,:),M,V);
                if(domination ~= -1)
                    %i和j之间存在支配关系
                    g = Arc(1+fix((size(Arc,1)-1)*rand(1)),:);%从Arc里随机选取一个个体作为g*
                    if(domination == 0)
                        %i支配j
                        offspring(j,1:V) = firefly_move(pop(i,:),pop(j,:),V,beta0,gamma,true,g);
                        offspring(j,1:V) = outbound(offspring(j,1:V),V,min_range,max_range);
                    else
                        %j支配i
                        offspring(i,1:V) = firefly_move(pop(j,:),pop(i,:),V,beta0,gamma,true,g);
                        offspring(i,1:V) = outbound(offspring(i,1:V),V,min_range,max_range);
                    end
                else
                    %i和j之间不存在支配关系
                    g = Arc(1+fix((size(Arc,1)-1)*rand(1)),:);%从Arc里随机选取一个个体作为g*
                    res = firefly_move(pop(i,:),pop(j,:),V,beta0,gamma,false,g);
                    offspring(i,1:V) = res(1,:);
                    offspring(i,1:V) = outbound(offspring(i,1:V),V,min_range,max_range);
                    offspring(j,1:V) = res(2,:);
                    offspring(j,1:V) = outbound(offspring(j,1:V),V,min_range,max_range);
                end
            end
        end
        pop = offspring;%更新萤火虫位置
        for i = 1:N
            pop(i,V+1:V+M) = evaluate_objective(pop(i,:));%评估萤火虫个体
        end
        Arc = update_Arc(pop,Arc,N,M,V,epsilon);%利用ε-三点最短路径方法维持Arc档案
        t = t + 1;
    end
end
%% 
function f = init(N,M,V,min,max)
    %初始化种群，随机生成个体并计算其适度值
    %N:种群大小
    %M:目标函数数量
    %V:决策变量数
    %min:变量范围下限
    %max：变量范围上限
    f = [];%存放个体和目标函数值,1:V是决策变量，V+1:V+2是目标函数值
    for j = 1:V
        delta(j) = (max(j) - min(j))/N;%将决策变量x(j)的区间均匀划分成N等分;
        lamda = min(j):delta(j):max(j);%得到N个子区间
        for i = 1:N
            %从N个子区间中随机选择一个
            [~,n] = size(lamda);%获得子区间个数n
            rand_n = 1 + fix((n-2)*rand(1));%随机位置
            min_range = lamda(rand_n);%获得子区间的下限
            max_range = lamda(rand_n+1);%获得子区间的上限
            f(i,j) = min_range + (max_range - min_range)*rand(1);%随机生成
            lamda(rand_n) = [];%删除该子区间
        end
    end
    %计算个体的适度值
    for i = 1:N
        f(i,V+1:V+M) = evaluate_objective(f(i,:));%计算目标函数值
    end
end
%%
function f = evaluate_objective(x)
    %根据目标函数计算适度值，测试方法：ZDT-1
    global V 
    f = [];
    f(1) = x(1);%目标函数1
    g = 1;
    g_tmp = 0;
    for i = 2:V
        g_tmp = g_tmp + x(i);
    end
    g = g + 9*g_tmp/(V-1);
    f(2) = g*(1-sqrt(x(1)/g));%目标函数2
end
%%
function f = non_domination_sort(x,M,V)
    %非支配排序,得到非支配解集
    %M:目标函数数量
    %V:决策变量数
    [N,~] = size(x);%获取种群个体数
    rank = 1;%pareto等级
    F(rank).f = [];%非支配解集
    pop = [];%种群
    for i = 1:N
        %得到最高等级个体和个体间的支配关系
        pop(i).np = 0;%被支配数
        pop(i).sp = [];%支配个体集合
        for j = 1:N
            %个体支配规则：对任意的目标函数，均有fk(x1)<=fk(x2)，且存在fk(x1)<fk(x2)
            domination = get_domination(x(i,:),x(j,:),V,M);%获得i和j之间的支配关系
            if(domination == 0)
                %i支配j
                pop(i).sp = [pop(i).sp j];%把个体j的索引加入支配集合中
            elseif(domination == 1)
                %i被j支配
                pop(i).np = pop(i).np + 1;%i的被支配数+1
            end
        end
        if(pop(i).np == 0)
            x(i,V+3) = rank;%rank等级最高，为1
            F(rank).f = [F(rank).f i];%把个体i加入到非支配解集中
        end
    end
    f = F(rank).f;
end
%%
function res = get_domination(x1,x2,V,M)
    %获得两个个体的支配关系，x1支配x2返回0，x2支配x1返回1，否则返回-1
    less = 0;%小于
    equal = 0;%等于
    more = 0;%大于
    for k = 1:M
        %遍历每一个目标函数
        if(x1(V+k) < x2(V+k))
            less = less + 1;
        elseif(x1(V+k) == x2(V+k))
            equal = equal + 1;
        else
            more = more + 1;
        end
    end
    if(more == 0 && equal ~= M)
        %i支配j
        res = 0;
    elseif(less == 0 && equal ~= M)
        %i被j支配
        res = 1;
    else
        res = -1;
    end
end
%%
function new_x = firefly_move(x1,x2,V,beta0,gamma,domination,g)
    %萤火虫x1向x2移动
    %V:决策变量数
    %beta0:最大吸引度
    %gamma:光吸收系数
    %当x1、x2之间存在支配关系时，omega = omega0，omega0为[0,1]之间的随机数
    %当x1、x2之间不存在支配关系，omega = 1-omega0
    %g为精英个体
    global NP
    r = get_distance(x1(1:V),x2(1:V),V);%获得x1和x2之间的距离
    beta = get_attraction(r,beta0,gamma);%获得x1和x2之间的吸引力
    s = levy_flights();%莱维飞行获得随机扰动
    omega0 = rand(1);
    if(domination == true)
        %存在支配关系
        r_g = get_distance(x2(1:V),g(1:V),V);%获得x2与精英个体g之间的距离
        beta_g = get_attraction(r_g,beta0,gamma);%获得x2和g之间的吸引力
        new_x = x1(1:V) + omega0*beta.*(x1(1:V)-x2(1:V)) + (1-omega0)*beta_g.*(g(1:V)-x2(1:V));
    else
        %不存在支配关系
        new_x = [];
        r_g = get_distance(x1(1:V),g(1:V),V);%获得x1与精英个体g之间的距离
        beta_g = get_attraction(r_g,beta0,gamma);%获得x2和g之间的吸引力
        new_x(1,:) = omega0.*x1(1:V) + (1-omega0)*beta_g.*(g(1:V)-x1(1:V));
        r_g = get_distance(x2(1:V),g(1:V),V);%获得x2与精英个体g之间的距离
        beta_g = get_attraction(r_g,beta0,gamma);%获得x2和g之间的吸引力
        new_x(2,:) = omega0.*x2(1:V) + (1-omega0)*beta_g.*(g(1:V)-x2(1:V));
    end
end
%%
function beta = get_attraction(r,beta0,gamma)
    %获得萤火虫x1和x2之间的吸引力
    %r:两萤火虫之间的距离
    %beta0:最大吸引力
    %gamma:光吸收系数
    beta = beta0*exp(-1*gamma*r^2);
end
%%
function distance = get_distance(x1,x2,V)
    %获得萤火虫x1和x2之间的距离
    distance = norm(x1(1:V)-x2(1:V));
end
%%
function s = levy_flights()
    %莱维飞行产生随机扰动
    beta = 1.5;%beta为(0,2]之间的常数，一般取值为1.5
    sigma_u = ((gamma(1+beta)*sin(pi*beta/2))/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);%0.6966
    sigma_v = 1;
    u = normrnd(0,sigma_u);%产生均值为0，标准差为sigma_u的正态分布随机数 0<u≤0.5232
    v = normrnd(0,sigma_v);%产生均值为0，标准差为sigma_v的正态分布随机数 0<v≤0.3989
    s = u/abs(v)^(1/beta);
end
%%
function x = outbound(x,V,lb,ub)
    %越界处理
    for i = 1:V
        if(x(i)<lb(i))
            x(i) = lb(i);
        elseif(x(i)>ub(i))
            x(i) = ub(i);
        end
    end
end
%%
function epsilon = get_epsilon()
    %获取ε-占优分别在两个目标函数中的参数
    global N
    %epsilon = (MAX-MIN)/N
    epsilon = [];
    %ZDT-1问题下，f1(x)∈[0,1]
    %f2(x)∈[0,10]
    epsilon(1) = (1-0)/N;
    epsilon(2) = (10-0)/N;
end
%%
function res = update_Arc(pop,Arc,N,M,V,epsilon)
    %更新外部档案
    %pop:种群
    %Arc:外部档案
    %N:外部档案大小
    %M:目标函数数
    %V:决策变量数
    %epsilon:
    solutions = pop(non_domination_sort(pop,M,V),:);%非支配解集
    [n1,~] = size(solutions);%得到当前种群中非支配解的个数
    [n2,~] = size(Arc);%得到当前外部档案中非支配解的个数
    res = [];
    solutions(:,V+1) = solutions(:,V+1).*(1+epsilon(1));%扩大支配区域
    solutions(:,V+2) = solutions(:,V+2).*(1+epsilon(2));%扩大支配区域
    %n = 0;%记录档案中个体数
    for i = 1:n1
        dominate = 0;
        j = 1;
        while (j <= n2) && (n2 > 0)
            if(get_domination(solutions(i,:),Arc(j,:),V,M) == 0)
                %solutions(i)ε支配Arc(j)
                dominate = dominate + 1;
                Arc(j,:) = [];
                n2 = n2 - 1;
            end
            j = j + 1;
        end
        if(dominate > 0)
            res = [res;solutions(i,:)];%把该解加入到外部档案中
        end
    end
    res = [res;Arc];
end