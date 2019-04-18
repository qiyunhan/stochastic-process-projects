clear;
clc;

%超参数设定
lambda_1 = 1;
lambda_2 = 1;
miu_1 = 0.2;
miu_2 = 0.2;
M_1 = 3;
M_2 = 3;
L_1 =20;
L_2 = 20;

prob = [];
test_num = 1000;
map = zeros(10,10);

%ime1 = get_time1(miu_1,5000,M_1);

for lambda_1 = 0.1:0.1:1
for lambda_2 = 0.1:0.1:1
    times = test_num;
    for k = 1:1:test_num
        first_1 = count(miu_1,miu_2,lambda_2,L_1,L_2,M_1,M_2);
        result_1 = first_1;
        %disp('先去1：'),disp(result_1);
        first_2 = count(miu_2,miu_1,lambda_1,L_2,L_1,M_2,M_1);
        result_2 = first_2;
        %disp('先去2：'),disp(result_2);
        if result_1 < result_2
            times(k) = 1;
        else
            times(k) = 0;
        end
    end
    times = sum(times > 0, 2)*1.0/test_num;
    disp(times)
    prob = [prob,times];
    %disp(miu_1/0.1);
    %disp(miu_2/0.1);
    map(int32(lambda_1/0.1),int32(lambda_2/0.1)) = times;
    %map(L_1/5+1,L_2/5+1) = times;
end
end
%L_1 = 1:1:100;
%M_1 = 1:1:10;
%M_2 = 2:1:10;
%L_2 = 0:1:50;
%lambda_1 = 0.01:0.05:2.01;
%figure;
%plot(L_2,prob);
%axis([min(L_2),max(L_2),0,1]);
map = map > 0.5;
figure;
pcolor(map);
ylabel('L_1');
xlabel('L_2');


function time = count(miu_1,miu_2,lambda,L_1,L_2,M_1,M_2)
    time1 = get_time1(miu_1,L_1,M_1);%得到在地点1排队的时间T
    num2 = get_num2(lambda,miu_2,L_2,M_2,time1);%模拟在T时间内地点2队伍变化
    if num2 >= 0    %如果地点2的队列长度大于0
        time2 = get_time1(miu_2,num2,M_2);
    else            %如果地点2没有人排队
        time2 = exprnd(1/miu_2);
    end
    time = time1 + time2;%总用时为两个地点用时之和
end

function num = get_num2(lambda,miu,L,M,time)
    t = 0;          %时间
    len = L;        %队列长度
    flag = 0;       %记录是新来顾客还是服务结束走一个顾客
    while(t < time) 
        if len >= 0 %当队列长度大于0，说明所有柜台都在服务
            cus_t = exprnd(1/lambda);
            serve_t = exprnd(1/miu/M);
        elseif len >= -M && len < 0 %当队列长度为负数，即有柜台空闲，服务效率会变化
            cus_t = exprnd(1/lambda);
            serve_t = exprnd(1/miu/(M+len));%更新参数后的分布
        end
        seed = cus_t < serve_t; 
        if seed == 1        %新来顾客所用时间小于服务所用时间时，队列长度+1
            flag = 1;
            len = len + 1;
            t = t + cus_t;
        else                %%新来顾客所用时间大于服务所用时间时，队列长度+1
            flag = 2;
            len = len - 1;
            t = t + serve_t;
        end
    end
    %因为是while循环，因此会多+1或-1，因此需要修正
    if flag == 1
        len = len - 1;
    else
        len = len + 1;
    end
    num = len;
end

function time = get_time1(miu,L,M)
    num = M + L + 1;%当前地点1的总人数
    t = 0;          %时间
    for i = 1:1:num %对每一位顾客进行操作
        t = t + exprnd(1/miu/M);
    end
    time = t;
end


function time = get_time(miu,L,M)
    serve = zeros(M,200);
    for i = 1:1:M %初始化
        serve(i,1) = exprnd(1/miu);
    end
    serve_L_t = exprnd(miu,1,L+1);%生成队列中每一个人所需要的服务时间
    flag = -1; %用于记录第L+1个人所在行号
    for i = 1:1:length(serve_L_t)
        serve_sum = sum(serve,2); %按行求和
        [m,min_index] = min(serve_sum); %求得行的最小值和序号
        add_index = sum(serve(min_index,:)>0);  %确定新加入元素的列序号
        serve(min_index,add_index+1) = serve_L_t(i);%将队列第一个人放入服务矩阵
        if i == length(serve_L_t)
            flag = min_index;
        end
    end
    sum_t = sum(serve,2);%按航求和
    time = sum_t(flag); %求得第L+1个人所用时间
end








