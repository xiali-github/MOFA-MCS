## 多策略协同多目标萤火虫算法
#### 一、为什么要提出这种算法？
原始的多目标萤火虫算法只是从算法的局部而未从算法整体改善其性能，因此提出这种多策略协同的多目标萤火虫算法++提升其求解复杂多目标优化问题的性能++
#### 二、提出的策略
- 均匀化与随机化相结合的方式初始化种群
- 利用莱维飞行产生随机扰动
- 档案精英解引导萤火虫的移动
- ε-三点最短路径维持外部档案的大小
#### 三、初始化种群策略
>种群规模为NP，决策向量的维数为n，各决策变量的界限xj (j∈[1,n])的区间为[aj,bj]
1. 将决策变量的区间划分成NP等分:
∆j=(bj−aj)/NP
2. 将决策变量的区间划分成NP个子区间:
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/QQ20201008-171040.png)
3. 随机挑选一个子区间，并在这个子区间内随机生成一个基因值赋给xj
4. 删除这个子区间，重复步骤3

**最后基因值在区间内的分布：**
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/aa.png)
**这为算法在全局空间内的搜索提供了良好的开端**
#### 四、利用莱维飞行产生随机扰动
> 为什么需要改成莱维飞行产生随机扰动？

因为在原始的FA移动公式中：

![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/eq3.png)

αεj会随着迭代次数的增加而越来越小，这会导致每只萤火虫的步长差别越来越小，不利于求解复杂的多目标问题
##### 莱维飞行的随机步长：
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/eq4.png)

其中 ，u，v均服从正态分布 ，u\~N(0,σu)，v\~N(0,σv)，而σu和σv满足公式:
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/eq5.png)

其中Γ是标准的 Gamma函数
#### 五、档案精英解引导萤火虫的移动
> 通过档案精英解的引导来加快算法的收敛速度，但萤火虫的移动分以下两种情况

- ##### 当两只萤火虫之间不存在支配关系时
1. 随机从外部档案中挑选一个精英解g*
2. 两只萤火虫都要向着这只精英解g*移动，假定两只萤火虫分别为xi和xj
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/eq6.png)
- ##### 当两只萤火虫之间存在支配关系时
1. 随机从外部档案中挑选一个精英解g*
2. 被支配的萤火虫基于精英解g*向着支配解萤火虫移动，假定xi支配xj
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/eq7.png)
> 其中ω0为定义在区间[0,1]上均匀分布的随机数，r为欧氏距离，s为莱维飞行随机扰动，⨂为内积运算
β为萤火虫之间的吸引力

#### 六、ε-三点最短路径维持外部档案的大小
> ε-三点最短路径策略是将ε-占优策略和三点最短路径方法相结合，以更好地维护档案群体的多样性
##### 1、ε-占优策略
ε-占优策略(又称ε-支配)，是在Pareto支配基础上引入ε参数，扩大了支配区域
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/eq8.png)

如果满足上式，我们称xa ε支配xb
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic2.png)
##### 2、ε-三点最短路径策略
如下图，点b、d、f此时要进入外部档案，它们的支配区域如图所示
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic-3.png)

将它们支配区域内的其它解删除
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic-4.png)
#### 七、流程图
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic5.png)
#### 八、尚未解决的问题
> 测试问题：ZDT1<br>
> 参数设置：<br>NP:100<br>T_MAX:500(最大迭代次数)
><br>外部档案规模N:100

正确的结果：
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic7.png)

但是得到的结果为：
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic6.png)

究其本质，我发现问题出在萤火虫移动公式上，萤火虫在移动后得到这样的新解：
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic8.png)

在ZDT1中，决策变量的取值范围是[0,1]，而从图中看出决策变量全部处于越界的状况。我们在进一步分析后，发现产生越界问题的主要原因是移动公式中的随机扰动：
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic9.png)

在断点调试中，得到的欧氏距离r已经是超出了ZDT1中决策变量的范围:
![image](http://fanrenkong.oss-cn-hangzhou.aliyuncs.com/%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%90/pic10.png)
##### 目前的处理办法是通过删除随机扰动来解决的，如果各位有什么办法解决的话，欢迎[与我交流](mailto:kevin@fanrenkong.com)

[论文链接](http://www.ejournal.org.cn/CN/abstract/abstract11502.shtml)
