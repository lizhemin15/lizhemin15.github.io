---
title: "论文精读：'Feature Learning in Infinite-Width Neural Networks'"
date: "2025-06-24"
tags: ["Notes", "论文精读", "神经网络理论"]
keywords: ["Feature Learning", "NTK", "Theory", "Infinite-width neural networks"]
excerpt: "尽管NTK极限下得到了很漂亮的深度神经网络的近似，但是也同时失去了特征学习能力。这篇文章发现通过修改标准的参数化方式，就可以使得在无穷宽极限下进行特征学习，并使用 'Tensor Programs' 技术导出了这个极限的显式形式。Feature Learning 对于迁移学习非常重要，可以说，如果学不到特征，那么迁移学习都不存在可行性。"
visible: true
pinned: false
---

**论文来源**
Greg Yang 大神的 Tensor Program 系列第四篇，其它的系列作品有时间和需求时后续再进行更新补充。

# 前言

```figure
![US cities and states的Word2Vec 嵌入的PCA](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506241301504.png?imageSlim)
```

在NTK极限下，预训练学到的特征和随机初始化没什么区别(见<a href="#fig1">图1</a>的实验)。而特征学习本身在深度学习中很有影响力，这对于NTK理论用于神经网络实际分析时是很致命的。而这篇文章则发现可以通过修改标准的参数化达到过参数化模型也可以进行特征学习的目的。

## abc-Parametrizations
考虑一个 $L$-隐藏层的感知机：权重矩阵 $W^1\in\mathbb{R}^{n\times d}$ 且 $W^2,\ldots,W^L\in\mathbb{R}^{n\times n}$，且非线性项 $\phi:\mathbb{R}\rightarrow \mathbb{R}$，使得神经网络在输入 $\xi\in\mathbb{R}^d$上为 $h^1(\xi)=W^1\xi\in\mathbb{R}^n$，且

```equation
$$x^l(\xi)=\phi(h^l(\xi))\in\mathbb{R}^n, h^{l+1}(\xi)=W^{l+1}x^l(\xi)\in\mathbb{R}^n,\text{ for } l=1,\ldots,L-1$$
```

且网络的输出 (也称为 $logits(s)$) 是 $f(\xi)=W^{L+1}x^L(\xi)$ 对于 $W^{L+1}\in\mathbb{R}^{1\times n}$。一个 abc-parametrization 由系列数字 $\{a_l,b_l\}_l\cup \{c\}$ 使得：

(a) 我们参数化每个参数为 $W^l=n^{-a_l}w^l$ 对于实际的可训练参数 $w^l$
(b) 初始化 $w_{\alpha\beta}^l\sim\mathcal{N}(0,n^{-2b_l})$ 
(c) SGD 的学习率是 $\eta n^{-c}$ 对于一些宽度无关的 $\eta$ 。

**例**：
NTK 参数化 (NTP) 有着 $a_1=0$且 $a_l=1/2$对于$l\geq 2$；$b_l=0$ 对所有的 $l$；$c=0$。 当深度 $L=1$，平均场参数化 (MFP) 有 $a_1=0$， $a_2=1$；$b_l=0$ 对所有的 $l$；$c=-1$。标准参数化 (SP) 是 Pytorch的默认设定，有着 $a_l=0$ 对所有的 $l$；$b_1=0$ 且 $b_l=1/2$ 对所有的 $l\geq 2$；$c=0$。然而，我们会看到 $c$ 在SP中太小了。我们可以定义 abc-parametrization 并将我们的结果推广到任意神经网络结构 (附录 C)，但我们将在正文中主要聚焦 MLPs。

## 动力学二分
对任意 abc-parametrization，若 $c$ 太小了，SGD可能会导致预激活或logits爆炸；我们说这个参数化是*不稳定*的。实际上这就变成了数值问题，如果 $c$ 太大 (即学习率太小)，那么由网络计算得到的函数在有限的时间内没有改变；我们称这个参数化是*平凡*的。我们证明了我们称为 *Dynamical Dichotomy theorem*:

> Any nontrivial stable abc-parametrization 都有一个无穷宽的极限。这个极限要么 1) 允许嵌入 $x^L(\xi)$ 非平凡演化或是 2) 通过函数空间的核梯度下降描述，但并不能同时进行描述。

我们称前一种情况为 *feature learning limit* 后一种为 *kernel limit*。对于单隐藏层的MLPs，前一种会在MFP发生，而后一种则在NTP中发生。这个二分意味着一些函数动力学，如NTK动力学的高阶推广，都不是有效的无限宽极限。此外，任意特征学习极限的神经网络函数 $f$ 在初始化时必须等于$0$。

## 标准参数化(SP)不会学习特征
我们表明 SP (或NTP) 只能以 $O(1/width)$ (或$O(1)$) 的学习率 (即，$c=1$或$c=0$)，来避免爆炸，并取得核限制。相反的，我们提出有着 $\Theta(1)$ 最大学习率的参数化方式，能够最大程度上得到 feature learning：其允许每个参数都最大化的更新却不至于爆炸。我们称之为 *最大更新参数化 (Maximal Update Parametrization, MUP或$\mu P$)*。其通过 $a_1=-1/2,a_{L+1}=1/2$给出，且 $a_l=0$对所有的 $2\leq l\leq L$成立；$b_l=1/2$对所有的$l$成立；$c=0$。在单隐藏层的MLP，这就对应于MFP。这里的"feature learning limits"都指的是$\mu P$ limits。我们在<a href="#fig2">图2</a>中展示了实验验证的最大学习率在2 个隐藏层的 relu MLP 的最大学习率的预测，在CIFAR 10上使用平方损失进行训练。我们在每个子图中绘制出准确率随着学习率的变化情况。每个曲线代表着MLP有着特定的宽度。每个曲线的最右边代表着最大的学习率。对角线的子图代表着学习率随着网络宽度正确缩放了。即SP的的最大学习率是 1/width，而$\mu P$则是常数。

```figure
![$\mu$P和SP最大学习率验证](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506241535691.png?imageSlim){width=50%}
```

## Key Theoretical Idea: Tensor Programs
这个方法的主要 insight 是：
> 当宽度很大的时候，在训练**任何时间**，每个激活向量有大致的iid坐标，使用 *Tensor Programs* 可以递归计算坐标分布，进而理解神经网络的演化。

```figure
![一图看懂 NNGP, NTK, Feature Learning Limit](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506241646056.png?imageSlim){width=50%}
```

从<a href="#fig3">图3</a>可以知道，Neural Network-Gaussian Process (NNGP) 可以认为是第一次前向传播的随机初始化模型的极限；而NTK可以认为是第一次反向传播的极限；计算极限的机制是，1) 将相关神经网络的计算写成矩阵乘法与坐标非线性的原则性组合，称为 *Tensor Program* 2) 通过 *Master Theorem* 来递归的计算每个向量的坐标分布。在本文中，我们完全遵循相同的方法，在 1) 中我们直接写下整个 SGD 的训练而非只是第一步，更一般的来说，

> 为了导出**任意**神经计算的无穷宽极限，1) 将其表达为 *Tensor Program* 2) 机械的应用 *Master Theorem*

## 本文的贡献
1. 形式化了神经网络参数化的自然空间 (abc-parametrizations)
2. 证明了 *Dynamical Dichotomy*: 任意 nontrivial 的稳定 abc-parametrization 都有 feature learning 或 kernel limits，但不会同时出现。
3. 证明了 NTK和SP都有 kernel limits，并提出了 *Maximal Update Parametrization ($\mu P$)*，其允许在适当意义上进行最大的特征学习。
4. 使用 Tensor Programs 来导出$\mu P$的无穷宽极限，更一般的来说，是任意 abc-parametrization的极限。我们通过额外的实验验证了我们的理论。
5. 展示了 $\mu P$ 极限比 NNGP/NTK 两个baselines以及有限网络在 1) Word2Vec 以及 2) Omnniglot 少样本学习的优越性。

> **Tensor Programs Series**
> 这篇文章是自包含的，独立于前三篇TP工作，是首个系列工作的一个回报，这篇文章也是TP系列工作的最原始的动机。

# 相关工作
## Comparison with Mean Field Limits
对于单层的MLP，平均场极限等价于$\mu P$极限，一些工作还为更深的MLPs提出了不同版本的平均场框架。然而，他们并没有考虑典型的$\mathcal{N}(0,1/n)$随机初始化，其具有中心极限效应，而不是大数定律效应。

## 离散时间与连续时间的梯度下降
以前的工作在讨论神经网络训练动力学时，同时考虑了连续时间和大宽度，而在本文中只需大宽度限制，梯度下降保持离散时间。之前的连续时间的工作都可以通过添加限制得到，然而这种连续时间的限制是不自然的，如*实践方面* 1) 步长通常尽可能大以加速训练 2) 任务如强化学习就不好说是连续时间 3) 还有很多重要的超参数，如 batch size都被藏在了这个极限中。*理论方面*，连续时间极限会导致 1) 适定性 2) 所得 ODE/PDE 的存在性和唯一性的问题，尽管它们有时可以被证明成立，但它们是连续时间限制的产物，因为离散时间演化的相应问题是微不足道的，因此与真实网络的行为无关。

## 技术假设
之前的 neural tangent or mean field limits 假设许多正则条件，例如 1) 0th, 1st, and/or 2nd order smoothness on the nonlinearity or other related functions 2) the support boundedness, subgaussianity, and.or PDF smoothness of initialization distributions. 这些都很不自然，且很难去检验。在我们的工作中，唯一的用来得到无穷宽极限的假设是非线性项 $\phi$ 有着多项式有界的二阶导数，并且损失函数对于预测而言具有连续导数。特别的，当神经网络是一个单隐藏层的情况时，会得到离散时间版本的 mean field limit，我们涵盖了标准的高斯初始化；实际上，我们允许任何重尾初始化，它可以被写成伪 Lipschitz函数下的高斯的像，其有着 nonsmooth PDFs 和奇异分布。**这么宽松的假设是源于 Tensor Programs Master Theorem。**

## 训练时间
许多先前的工作导出了收敛到无穷宽极限的显式时间依赖性，使得更大的宽度可以允许网络更长时间地保持接近极限。在本文中，我们的结果只涉及与宽度无关的训练时间，因为我们的主要目标是研究极限本身及其特征学习能力。此外，最近的证据表明，给定固定的计算预算，在更短的时间内训练更大的模型总是更好的，这验证了我们的极限模式的实际相关性。此外，证明 *Tensor Programs Master Theorem* 的定量版本是有可能的，通过该版本，人们可以允许训练时间随着宽度而增加。

## 参数化的分类
在NTK中，参数几乎不动，而平均场中，参数变化很大。由于这个原因，前者被称为 *"lazy training"*，而后者被称为 *"active training"*，它们通过logit的乘法比例因子进行非严格分类(类似于本文中的$n^{-a_{L+1}}$)。虽然这些术语没有正式定义，但它们直观对应于我们论文中的kernel and feature learning regimes。从另一个角度来看，NTK和平均场极限可以被认为是平均场演化方程的短时间和长时间尺度范围。上述工作都没有尝试对神经网络的自然参数化进行正式分类。相对的，另一个工作研究了 a toy class of neural networks 由于初始化尺度 $\alpha$ 带来的隐式正则。他们将 $\alpha\rightarrow \infty$极限定义为"kernel regime"，把$\alpha\rightarrow 0$极限定义为"rich regime"。他们表明，前者隐式极小化了$\ell_2$风险，而后者极小化了$\ell_1$风险。他们声称宽度允许 toy model 更自然进入 kernel regime，但正如我们所看到的， kernel and feature learing regimes 在标准MLP的大宽度限制下都是允许的。和本文工作比较接近的是研究了 $L=1$ 情况下稳定 abc-parametrizations 空间的二维子空间。他们提出了一个稳定性概念，类似于本文中稳定性和非平凡性的组合，它们表明了神经正切核合适随时间演化，神经正切核被适当地推广到了任何参数化，并扮演者类似于本文特征核的角色。然而，为了简化证明，他们假设不同权重矩阵的梯度是使用不同的输入来估计的，这是一个非常不自然的条件。相反，我们的结果是应用于任意深度MLP的通常SGD算法，在所有上述工作和大多数现有文献中，与我们在这里的重点相反，没有太多关注神经网络在正确参数化中的特征学习论能力。注意到还有一个特例证明了在平均场极限下，而非NTK极限下，可以学到输入分布的低维线性结构，从而导致与环境维度无关的泛化边界。

## 其它相关工作
有工作提了toy model 来研究大的学习率如何在 $\Omega(\log(width))$ 的时间内走出 kernel regime。由于我们的二分结果只涉及到$O(1)$的时间训练，所以不存在矛盾。标准参数化还会导致不稳定的训练动力学，然后，在NTK参数化中注入常数，如 $\alpha/\sqrt{n}$ 而不是$1/\sqrt{n}$，并在生成的核中调整$\alpha$。经验表明，更宽的网络通过线性迁移学习实现更好的下游性能，即使在原始预训练任务上几乎没有差异。在这项工作中，我们固定了输入维度$d$，的那页可以考虑随着宽度$n$来改变$d$。在围绕NTK的文献中，参数化往往存在细微差异，导致结论的细微差异，而本文的abc框架封装了所有这样的参数化，并且可以通过等式很容易判断两个表面上不同的参数化。

# Feature Learning vs Kernel behavior
在本节中，我们给出了诱导特征学习与核行为的训练过程的特征；我们将在下面详细阐述我们所说的这两种行为的含义。首先我们通过回顾众所周知的浅层神经网络的切核和平均场极限来激发这一讨论。

## Motivating Examples: Neural Tangent Kernel and Mean Field Limits
为了简单起见，定义一个浅层网络 $f(\xi)$ 输入/输出维度为 1

```equation
$$f(\xi)=Vx(x)\in\mathbb{R},x(\xi)=\phi(h(\xi))\in\mathbb{R}^n,h(\xi)=U\xi \in\mathbb{R}^n.$$
```

如<a href="#eq1">公式(1)</a>的定义，我们参数化权重 $V=n^{-a_v}v\in\mathbb{R}^{1\times n}$ 且 $U=n^{-a_u}u\in\mathbb{R}^{n\times 1}$，其中宽度$n$应当趋于$\infty$，且$v,u$应当是实际可训练的参数。我们将采样 $v_\alpha\sim \mathcal{N}(0,n^{-2b_v}),u_\alpha\sim\mathcal{N}(0,n^{-2b_u})$对于$\alpha\in[n]$。学习率是$\eta n^{-c}$对于一些独立于$n$的$\eta$。

例如，在 *Neural Tangent Parametrization (简写为 NTP)* 中 $a_u=b_v=b_u=0,a_v=1/2,c=0$。而 *Mean Field Parametrization (MFP)* 则对应于 $a_v=1,a_u=b_u=b_v=0,c=-1$；然而，马上要解释的是我们将使用等价的形式 $a_u=-1/2,a_v=b_u=b_v=1/2,c=0$在这一节，因此 $c=0$ 对于NTP和MFP。我们注意到，GP极限，即仅训练无穷宽，随机初始化的网络的最后一层，是NTK极限的特例，其中第一层没有被训练。我们下面讨论的关于NTK极限的一切都适当的专门针对GP极限。

给定一个输入 $\xi$，$f$的梯度可以被写成：
$$
dx(\xi)=V,dh(\xi)=dx(\xi)\odot \phi'(h(\xi)),dv(\xi)=n^{-a_v}x(\xi),du(\xi)=n^{-a_u}dh(\xi)\xi
$$
其中 $d\bullet(\xi)$ 是$\nabla_\bullet f(\xi)$ 的简写 (然而，在 Deriving Feature Learning Inifinite-Width Limit 这一节以后，全部都代表 $n\nabla_\bullet f(\xi)$)。对于损失函数 $\mathcal{L}:\mathbb{R}\times \mathbb{R}\rightarrow \mathbb{R}$，$(\xi,y)$对上面的损失梯度给定为 $\mathcal{L}'(f(\xi),y)[dv(\xi),du(\xi)]$(其中$L'$代表第一个参数的导数)。

注意到通过改变$a_v,b_v$以改变梯度$dv$的强度可以保持函数$f$不变，保持$a_v+b_v$为常数；对于$du$也是类似的。因此，$f$的轨迹保持固定，若对任意的$\theta\in\mathbb{R}$，我们设置 $a_u\leftarrow a_u+\theta,a_v\leftarrow a_v+\theta,b_u\leftarrow b_u-\theta,b_v\leftarrow b_v-\theta,c\leftarrow c-2\theta$ (参见<a href="#eq5">公式(5)</a>) 当 $\theta=-1/2$时，这解释了为什么上述的两个MFP的形式时等价的。然后，对于NTP和MFP来说，我们将会考虑$f$在随机梯度下降下，学习率为$\eta=1$、batch size为1的动力学训练，其中网络在时刻$t$在对 $(\xi_t,y_t)$ 上面进行训练，从$t=0$开始训练。 这种简单性旨在说明我们下面的观点。

### Notation and Setup
以下，当我们说一个(随机)向量 $v\in\mathbb{R}^n$有*coordinate size* $O(n^a)$ (写作 $v=O(n^a)$)，意味着 $\sqrt{\left\|v\right\|^2/n}=O(n^a)$ 对于大的 $n$ 有很高的概率成立。直观的说，这意味着每个坐标都有着 $O(n^a)$ 的典型波动。如果 $O(n^a)$ 被替换成 $\Theta(n^a)$或 $\Omega(n^a)$也是类似的。

令 $f_t,h_t,x_t,U_t,V_t,dx_t,dh_t,dv_t,du_t$ 表示对应于时刻$t$的值，对于$t=0$则对应于随机初始化。我们还记 $x_t=x_t(\xi_t)$，即应用函数 $x_t$到第$t$个输入$\xi_t$；类似的，对于$f_t,h_t,dx_t,dh_t,dv_t,du_t$。这些符号将从不会独自出现来表示对应的函数，因此是不会造成困惑的。SGD有效的更新了$U$,$V$，通过
$$
U_{t+1}=U_t-\chi_t n^{-a_u} du_t,V_{t+1}=V_t-\chi_t n^{a_v} dv_t,
$$
其中 $\chi_t \stackrel{\text { def }}{=} \mathcal{L}'(f_t,y_t)$。最终，令$\Delta\bullet_t\stackrel{\text{def}}{=}\bullet_t-\bullet_0$，对任意 $\bullet\in\{f,h,x,U,V,dx,dv,du\}$. 举个例子，在一步 SGD更新后，我们对任意 $\xi\in\mathbb{R}$，
```equation
$$
\begin{aligned} \Delta h_{1}(\xi) & =h_{1}(\xi)-h_{0}(\xi)=-n^{-a_{u}} \chi_{0} \xi d u_{0}=-n^{-2 a_{u}} \chi_{0} \xi_{0} \xi d h_{0} \\ & =-n^{-2 a_{u}} \chi_{0} \xi_{0} \xi d x_{0} \odot \phi^{\prime}\left(h_{0}\right)\end{aligned}
$$
```

```equation
$$ \begin{aligned} \Delta f_{1}(\xi) & =V_{0} \Delta x_{1}(\xi)+\Delta V_{1} x_{1}(\xi)=V_{0} \Delta x_{1}(\xi)-n^{-a_{v}} d v_{0}^{\top} x_{1}(\xi) \\ & =V_{0} \Delta x_{1}(\xi)-n^{-2 a_{v}} x_{0}^{\top} x_{1}(\xi)\end{aligned} $$
```

## 主要观察
让我们在<a href="#eq2">公式(2)</a>列出NTK和MF limits的一些特性，然后在深度MLP的一般设置中讨论它们，我们将保持我们讨论的直观，以传达关键思想。

### Feature Evolution
对于一般的$\xi\in\mathbb{R}$，其嵌入向量 $x_0(\xi)$ 有着 $\Theta(1)$ 大小的坐标，在 NTP 和 MFP中。然而，对于任何 $t\geq 1$ 独立于 $n$，$\Delta x_t(\xi)$ 一般有着坐标大小 $\Theta(1/\sqrt{n})$ 在NTP，但是 $\Theta(1)$ 在MFP。

*$t=1$的例子*：通过<a href="#eq3">公式(3)</a>，我们有
$$
\Delta h_1(\xi)=n^{-2a_u}\chi_0\xi_0\xi dx_0\odot \phi'(h_0).
$$
对于 NTP 插入$a_u=0$。观测到 $\xi_0,\xi,\chi_0=\Theta(1)$，因此
$$
\Delta h_1(\xi)=\Theta(1)\cdot dx_0 \odot \phi'(h_0).
$$

此外，$\phi'(h_0)=\Theta(1)$因为$h_0=\Theta(1)$，因此
$$
\Delta h_1(\xi)=\Theta(1)\cdot dx_0\odot \Theta(1).
$$
最后，$dx_0=V_0=\Theta(1/\sqrt{n})$ 在NTP中。总的来说，有着
$$ \begin{aligned} \Delta h_{1}(\xi) & =\Theta(1 / \sqrt{n}) \\ \Longrightarrow \Delta x_{1}(\xi) \approx \phi^{\prime}\left(h_{0}(\xi)\right) \odot \Delta h_{1}(\xi) & =\Theta(1 / \sqrt{n}) \rightarrow 0, \quad \text { as } n \rightarrow \infty .\end{aligned} $$

从另一方面来说，在 MFP中，唯一不同的事情是 $a_u=-1/2$且 $dx_0=\Theta(1/n)$，有着
$$ \Delta h_{1}(\xi)=\Theta(n) \cdot \Theta(1 / n) \odot \Theta(1)=\Theta(1) \Longrightarrow \Delta x_{1}(\xi)=\Theta(1) $$

### Feature Kernel Evolution
因此*特征核* $F_t(\xi,\zeta)\stackrel{\text{def}}{=}x_t(\xi)^\top x_t(\zeta)/n$ 不会改变NTK极限，但不在MFL里，即对于任意固定的$t\geq 1$，
$$
\lim_{n\rightarrow \infty} F_t(\xi,\zeta)=\lim_{n\rightarrow \infty} F_0(\xi,\zeta)\quad\text{in NTP, but}\\
\lim_{n\rightarrow \infty} F_t(\xi,\zeta)\neq\lim_{n\rightarrow \infty} F_0(\xi,\zeta)\quad\text{in MFP, in general}.
$$
实际上，不管参数化方式是什么，我们都可以得到
$$ F_{t}(\xi, \zeta)=\frac{1}{n}\left[x_{0}(\xi)^{\top} x_{0}(\zeta)+\Delta x_{t}(\xi)^{\top} x_{0}(\zeta)+x_{0}(\xi)^{\top} \Delta x_{t}(\zeta)+\Delta x_{t}(\xi)^{\top} \Delta x_{t}(\zeta)\right] .$$
在 NTP, 由于 $\Delta x_t(\xi)=\Theta(1/\sqrt{n})$ 如上述所述,
$$ \frac{1}{n} \Delta x_{t}(\xi)^{\top} x_{0}(\zeta)=\frac{1}{n} \sum_{\alpha=1}^{n} \Delta x_{t}(\xi)_{\alpha} x_{0}(\zeta)_{\alpha}=\frac{1}{n} \sum_{\alpha=1}^{n} O\left(n^{-1 / 2}\right)=O\left(n^{-1 / 2}\right) ,$$
类似的，其他项包括 $\Delta x_t$ 将会随着 $n\rightarrow \infty$ 而消失. 但在 MFP中, $\Delta x_t(\xi)=\Theta(1)$ 将会通过 $x_0(\zeta)$ 进行矫正，使得 $\frac{1}{n}\sum_{\alpha=1}^n \Theta(1)=\Theta(1)$.

### 预训练和迁移学习
以上关于特征核 $K$ 的简单事实意味着 NTK 极限并不能执行线性迁移学习。通过线性迁移学习，我们指的是流形的迁移学习风格，其中丢失预训练的线性分类器层，并在固定的特征之上训练新的分类器层。事实上这是一个线性问题，因此仅取决于特征的内核。如果这个内核与初始化时的内核相同，那么预训练阶段对这个"迁移"学习的结果没有影响。

事实上，更复杂的推理表明，即使对整个网络而不仅仅是分类器层进行微调，NTK极限中的预训练也不比迁移学习的初始化好。如果我们用新的深度神经网络替换线性分类器层，这仍然是正确的。

在一些其它的设置中，如元学习的一些设置，如本文中的少样本学习任务，预训练网络的最后一层不会被丢弃，这叫做*适应*。那么NTK极限不会自动淡化迁移学习。然而，正如将在我们的实验中看到的，NTK极限仍然远远不如特征学习极限，这里的MFL就是例子。

### Kernel Gradient Descent in Function Space
在NTP中，随着 $n\rightarrow \infty,\left<\nabla_{U,V} f_0(\xi),\nabla_{U,V}f_0(\zeta)\right>$ 收敛到固定值 $K(\xi,\zeta)$ 使得 $K$ 成为一个核。然后，在这个极限下，如果学习率是$\eta$，函数$f$ 通过核梯度下降进行演化 $f_{t+1}(\xi)=f_t(\xi)-\eta K(\xi,\xi_t)\chi_t$。然而，这不应当是MFL。举个例子，如果$\phi$是单位映射，那么直觉上说 $f_{t+1}(\xi)-f_t(\xi)$ 应当是对$\eta$是二次的，而不是线性的，因为两层是一起更新的。

## abc-Parametrizations and Dynamical Dichotomy
在这一节，我们将范围扩大到更深MLPs的abc-parametrizations，定义为<a href="#eq1">公式(1)</a>，并有他们的无穷宽极限。<a href="#tab1">表1</a>总结了不同参数化方法的特性对比。

```assumption 平滑性假设
我们在这一节的主要结果将会假设$\phi$要么是$tanh$，要么是一个 $relu$ 的光滑版本，称为$\sigma$-gelu，对于充分小的$\sigma>0$。
```

注意到这一假设只是在 abc-paramitrizations 中需要。为了导出无限宽限制，可以用弱得多的假设。我们相信我们在这里的结果将适用于一般的非线性，但使其精确超出了我们的范围。

### Symmetries of abc-Parametrizations
综上所述，如果我们在固定$f$的同时，可以任意缩放参数梯度 $\nabla_{w_l}f$，如果我们在固定$a_l+b_l$的同时变化$a_l,b_l$：$\nabla_{w^l}f$ 通过 $n^{-\theta}$ 缩放，如果 $a_l\leftarrow a_l+\theta,b_l\leftarrow b_l-\theta$。换句话说，以这种方式改变$a_,b_l$有效的给$w^l$一个逐层的学习率。如果我们以学习率$\eta n^{-c}$应用于梯度，那么$W^l$的改变缩放为$\eta n^{-c-2\theta}$。因此，如果$c\leftarrow c-2\theta$，那么$W^l$不受$a_,b_l$影响。综上所述，
```equation
$$
\forall \theta\in \mathbb{R}: f_t(\xi) \text{ 对所有的 } t,\xi \text{ 保持固定，若我们设置 } a_l \leftarrow a_l+\theta, b_l \leftarrow b_l-\theta, c \leftarrow c-2\theta.
$$
```

### Stable abc-Parametrizations
我们将只考虑 abc-parametrization 例如，当$n\rightarrow \infty$， 1) 预激活 $\{h^l\}_l$ 以及激活 $\{x^l\}_l$ 有着 $\Theta(1)$ 大小，在初始化的情况下， 2) 这些大小和 logits $f(\xi)$ 都保持 $O(1)$ 在整个SGD过程中。否则，它们倾向于随着$n$变成$\infty$，最终超越浮点范围。事实上，这是现代深度学习中常见的一个尖锐而真实的问题，其中 float16 是训练大模型所必须的。我们称这样的参数化是稳定的，因此不稳定的参数化没有实际意义。

```table 不同参数化下神经网络特性对比

|| Definition | SP (w/ LR $\frac{1}{n}$) | NTP | MFP ($L=1$) | $\mu\mathrm{P}$ (ours) |
|---|------------|-------------------------|-----|-------------|----------------------|
| $a_l$ | $W^l=n^{-a_l}w^l$ | 0 | $\begin{cases}0 & l=1 \\ 1/2 & l \geq 2\end{cases}$ | $\begin{cases}0 & l=1 \\ 1 & l=2\end{cases}$ | $\begin{cases}-1/2 & l=1 \\ 0 & 2 \leq l \leq L \\ 1/2 & l=L+1\end{cases}$ |
|$b_l$| $w_{\alpha\beta}^l \sim \mathcal{N}(0, n^{-2b_l})$ | $\begin{cases}0 & l=1 \\ 1/2 & l \geq 2\end{cases}$ | 0 | 0 | 1/2 |
|$c$| $LR=\eta n^{-c}$ | 1 | 0 | -1 | 0 |
|$r$| Definition 3.2 | 1/2 | 1/2 | 0 | 0 |
| | $2a_{L+1}+c$ | 1 | 1 | 1 | 1 |
| | $a_{L+1}+b_{L+1}+r$ | 1 | 1 | 1 | 1 |
| | Nontrivial? | ✓ | ✓ | ✓ | ✓ |
| | Stable? | ✓ | ✓ | ✓ | ✓ |
| | Feature Learning? |  |  | ✓ | ✓ |
| | Kernel Regime? | ✓ | ✓ |  |  |

```

事实证明，稳定的 abc-parametrizations 可以由 $\{a_l,b_l\}\cup \{c\}$的一组不等式来刻画。为了简洁的呈现这些不等式，可以定义

```definition r
对任意 abc-parametrization，我们记以下的量为$r$
$$
r\stackrel{\text{def}}{=}\min (a_{L+1}+b_{L+1},2a_{L+1}+c)+c-1+\min_{l=1}^L [2a_l+\mathbb{I}(l=1)].
$$
```
举个例子，在NTP中，$r=1/2$，尽管在MFP中($L=1,r=0$)。直观来说，$r$是使得 $\Delta x_t^L(\xi)=\Theta(n^{-r})$的指数。因此，为了避免激活函数膨胀，我们希望$r\geq 0$；为了进行特征学习，我们想要$r=0$。

```theorem 稳定性
一个 abc-parametrization 是稳定的当且仅当以下所有都是对的：
```

1. (pre)activations $x_0^l,h_0^l$ 在初始化时是 $\Theta(1)$ 且 logits $f_0$ 是 $O(1)$ 
```equation
$$
a_1+b_1=0;a_l+b_l=1/2,\forall l\in [2,L]; a_{L+1}+b_{L+1}\geq 1/2.
$$
```
2. 特征不会爆炸，即 $\Delta x_t^l=O(1)$ 对所有的 $l$ 成立
```equation
$$
r\geq 0
$$
```
3. logits 在训练过程中不会爆炸，即 $\Delta W_t^{L+1}x_t^L,W_0^{L+1}\Delta x_t^L=O(1)$
```equation
$$
2a_{L+1}+c\geq 1; a_{L+1}+b_{L+1}+r\geq 1.
$$
```

---

### Nontrivial abc-Parametrizations
通过稳定的 abc-parametrizations，在无穷宽极限下 $f$ 在整个训练过程中不发生改变。我们说这样的参数化是 trival 的。我们的二分法结果只适用于 nontrival 的稳定 abc-parametrizations。

Nontrival abc-parametrizations 可以通过方程在$\{a+l,b_l\}\cup \{c\}$的解耦合来描述（几何上，它们对应于 stable abc-parametrizations 多面体两个面的并集）。

```theorem nontrivial stable abc-parametrization
A stable abc-parametrizations is nontrivial iff $a_{L+1}+b_{L+1}+r=1$ or $2a_{L+1}+c=1$.
```

### Feature Learning
以下，为了简单起见，我们说 *training routine* 是同时指代学习率$\eta n^{-c}$，训练序列 $\{(\xi_t,y_t)\}_{t\geq 0}$，以及损失函数 $\mathcal{L}(f(\xi),y)$ 再模型$f(\xi)$的预测连续可微。如上所述，我们使用$\bullet_t$来表示目标$\bullet$在$t$步SGD后的值。

```definition feature learning
我们说 abc-parametrization 是 *feature learning* (即通过 feature kernel 演化)如果，随着 $n\rightarrow \infty$，$\Delta x_t^L(\xi)$ 有着 $\Omega(1)$ 大小($\frac{1}{n} (x_t^L(\xi)^\top x_t^L(\zeta)-x_0^L(\xi))$) 对某些训练路径，时间 $t\geq 1$和输入$\xi$。
```

MFP 在单隐藏层的例子中，是一个特征学习参数化例子。

直观来说，特征核的演化实现了特征学习，但是已知的是，可能在有些时候虽然发生了特征学习，但是却没有发生特征核的演化，例如得到了一些旋转后的特征。如果是这样，那么就线性迁移学习而言，预训练最终没有好处。

```theorem nontrivial stable abc-parametrization admits feature learning
iff it evolves the feature kernel iff $r=0$.
```

### Kernel Regime 
尽管这里定义的特征学习是通过查看输入$\xi$的嵌入来定义的，我们也可以查看由神经网络标识的*函数*的动力学。

```definition abc-parametrization in kernel regime
我们称一个 abc-parametrization 在 *kernel regime* 若存在一个半正定核 $K$ 使得对于任意训练过程，时间$t\geq 0$和输入$\xi$，在$n\rightarrow\infty$的极限下，
```
```equation
$$
f_{t+1}(\xi)=f_t(\xi)-\eta K(\xi,\xi_t)\mathcal{L}'(f_t(\xi_t),y_t),\forall t\geq 0.
$$
```
换句话说，SGD退化为核梯度下降，在大的$n$极限下。

---

```theorem nontrivial stable abc-parametrization in kernel regime
iff $r>0$. NTP 是一个典型的例子，其中 $r=1/2$ 且 $K$ 由NTK 给出。
```

### Dynamical Dichotomy
由<a href="#eq7">公式(7)</a>，一个 stable abc-parametrization 要么 $r=0$要么 $r>0$：

```corollary 动态二分
一个 nontrivial 的stable abc-parametrization 要么在 *feature learning* 要么在 *kernel regime*，但不会同时在二者同时出现。
```

注意到 *kernel regime* 没有被定义为 *lack of feature learning*，因此<a href="#cor1">推论 1</a>成立。例如，如果$\phi$ 是线性的，那么这个二分法就不成立，因为一个单隐藏层线性网络其中只有第一层被训练，将会同时在 feature learning 和 kernel regime。

动态二分法的一个有趣结果是

```corollary nontrivial stable feature learning abc-parametrization 性质
任何 *nontrivial stable* 特征学习 *abc-parametrization* 必须有 $\lim_{n\rightarrow} f_0(\xi)=0$对所有的$\xi$，其中极限是几乎确定的。
```
<a href="#thm3">定理 3</a>，<a href="#thm4">定理 4</a>，<a href="#cor1">推论 1</a> 会得到后续更一般的 **Theorem H.13**，其额外表明：1) 在第 $l$ 层进行特征学习同样会应用到层 $l,\ldots,L$ 2) 在任意 feature learning parametrization 下， $f_t$ 在大的$n$极限下变成确定的，因此与贝叶斯观点都不相容(与NNGP极限相反)。

浅层感知机的动态二分通过 NTK(<a href="#thm4">定理 4</a>)和MFL(<a href="#thm3">定理 3</a>)来揭示。我们在<a href="#fig4">图 4</a> 表达了一个简化的图景。

```figure
![abc参数化的夸张图示：非平凡稳定参数构成高维多面体。其部分边界上的参数可实现特征学习，其余则处于核机制。$\mu\mathrm{P}$位于前者顶点，而NTP属于后者。](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506262345114.png?imageSlim){width=50%}
```

```remark 函数空间图景
 kernel regime 极限仅存在于 *function space picture*，即 $f$ 在任何时刻的演化仅由函数值 $\{\lim f_t(\zeta)\}_\zeta,\eta,\mathcal{L},(\xi_t,y_t)$ 本身所决定。直观的说，对于 feature learning limit，这不可能是真的，因此，至少非正式的，动态二分法也是关于圈定训练演化函数空间图景的充分性的一种二分法：我们可以构造两种设定其中$\{\lim f_t(\zeta)\}_\zeta,\eta,\mathcal{L}$和$(\xi_t,y_t)$都一样，但是$f_{t+1}$不同。 1) 第一种设定是 $t=0$，其中 $\lim f_t(\zeta)=0$对任意输入$\zeta$。这里一个典型的SGD将会改变 $f$。 2) 在第二种设定中，假设$\phi$是 relu。设计系列输入使得以很大的学习率进行MLP的训练将会使得所有的 relu 神经元都在 0 区域饱和。那么 $f$ 是处处为0，SGD步不会改变这一点。
```

```remark 不是所有的动力学都是无穷宽极限
因此，非线性函数空间动力学不能是某些 abc-parametrization 的有效的无穷宽极限。通过 *非线性性*，我们说 $f_{t+1}(\xi)-f_t(\xi)$ 在 $\mathcal{L}'(f_t(\xi_t),y_t)$ 是非线性的。例如，任意 <a href="#eq9">公式 (9)</a> 的自然高阶推广就不是一个有效的极限。
```

### Pretraining and Transfer Learning
在所有的浅层例子中，<a href="#cor1">推论 1</a> 认为任意 kernel regime parametrization (包括NTP) 在无穷宽极限下使得预训练和迁移学习是平凡的。

通过计算标准参数化(standard parametrization, SP)的$r$，我们可以很容易看到，他不能在不变的不稳定的前提下得到特征学习。然而，在之后的章节，我们会手动分析在SP下的MLP的训练动力学来给出为什么是这种情况的直觉。反过来，我们提出了SP的简单修改，Maximal Update Parametrization (MUP或是$\mu P$)，其允许特征学习，事实上，在适当意义上*最大*限度这样做。本着教学精神，我们将专注于关键的见解，强调正确的启发式，而非停留在形式层面。

# Standard Parametrization
在这一节，我们给出为什么神经网络的梯度下降在 standard parametrization (SP) 将会在1步后导致logits爆炸，如果学习率是 $\omega(1/n)$，其中 $n$ 是宽度。此外，我们将看为什么使用学习率 $)(1/n)$，SP在 kernel regime。我们首先考虑最简单的例子，然后在这一节末尾给出一般的结果。

为了揭示神经网络的一般原则，考虑一个网络中间$n\times n$矩阵的行为是很重要的。因此，最简单的一个例子是一个两层隐藏层的线性MLP，即 <a href="#eq1">公式 (1)</a> 有着 $L=2$ 且 $\phi=id$。因此标准的参数化通过以下给出：
$$
a_l=0 \forall l, b_1=0,b_l=1/2 \forall l\geq 2.
$$

我们考虑1步在单个数据对$(\xi,y)$上有着学习率$n^{-c}$的SGD。那么我们可以明确的抑制对$\xi$的显示以来，并记
```equation
$$
f=V\bar{h},\bar{h}=Wh,h=U\xi,
$$
```
其中$U_{\alpha\beta}\sim \mathcal{N}(0,1)$和$W_{\alpha\beta},V_{\alpha\beta}\sim \mathcal{N}(0,1/n)$ 都是可训练参数。如<a href="#sec4"></a>，我们使用$\bullet_t$来表示量$\bullet$在SGD$t$步以后的量的大小。因为我们只关注 SGD 一步后的结果，我们简记记号 $\bullet=\bullet_0$。

## 初始化
由于 $U,W,V$ 是独立采样的，一个标准中心极限表明 $h,\bar{h},f$ 的各个分量可以大致认为是方差为 $\Theta(1)$ 的独立同分布的高斯变量。

## 第一步梯度
现在让我们考虑$f$在数据对$(\xi,y)$上的的梯度，通过下式给出
```equation
$$ 
\begin{aligned} d \bar{h} & =V^{\top}, & d h & =W^{\top} d \bar{h}, \\ d V & =\bar{h}, & d W & =d \bar{h} h^{\top}=V^{\top} h^{\top},\end{aligned} \quad d U=d h \xi^{\top}.
$$
```
为了简单起见，假设我们只以学习率$n^{-c}$更新$W$(且让$U,V$不变)；我们的结论将在更一般的训练了所有层的情况下保持不变。那么用$\chi$记为损失函数的导数$\mathcal{L}'(f,y)$，我们可以写成
$$
W_1=W-n^{-c}\chi dW.
$$
我们将会证明 $c\geq 1$ 或是 $f_1$ 在SGD步后宽度$n$会爆炸。

## 一步 SGD 后
在$t=1,h_1=h$由于我们没有更新$U$，但是
```equation
$$ \bar{h}_{1}=W_{1} h=\bar{h}-n^{-c} \chi d W h=\bar{h}-n^{-c} \chi \cdot V^{\top} h^{\top} h $$
```

```equation
$$ f_{1}=V \bar{h}_{1}=f-n^{-c} \chi V V^{\top} h^{\top} h. $$
```

现在，由上述所提到的，$h$有着 iid 的 $\Theta(1)$ 大小，因此 $h^\top h=\Theta(n)\in\mathbb{R}$。类似的，$V\in\mathbb{R}^{1\times n}$有着高斯方差量级为 $\Theta(1/n)$，因此 $VV^\top \Theta(1)\in\mathbb{R}$。最后，对于典型的损失函数 $\mathcal{L}$ 像 MSE 或交叉熵，$\chi=\mathcal{L}'(f,y)$的阶数为$\Theta(1)$由于$f$在数量级$\Theta(1)$上进行波动。总的来说，
$$
f_1=f-\Theta(n^{1-c}).
$$
因此，对于 $f_1$ 保持 $O(1)$，我们必须有$c\geq 1$，即学习率为$O(1/n)$。

## Kernel Regime and Lack of Feature Learning
因此，如果希望 logits 值不爆炸，网络在大宽度极限下无法学习特征。实际上，这个只更新$W$的SGD的版本可视为以下极限，
$$
a_1=\theta,b_1=-\theta,a_2=0,b_2=1/2,a_3=\theta,b_3=-\theta+1/2,\theta\rightarrow \infty.
$$
在$c=1$时，这种参数化是稳定和nontrivial的，由<a href="#thm1"></a>,<a href="#thm2"></a> 可以检查得到。那么我们得到 $r=1/2> 0$，因此通过<a href="#cor1"></a>，这个参数化在 kernel regime 且没有得到特征学习。我们可以从 <a href="#eq12"></a> 得到：
$$
\bar{h}_1-\bar{h}=O(n^{1-c})V^\top =O(1)V^\top
$$
其中大小为 $O(n^{-1/2})$由于$V$的大小，因此就没有特征学习(至少在第一步)。最后，从<a href="eq13"></a> 由于$VV^\top\rightarrow 1$ 且 $n^{-c}h^\top h=n^{-1}h^\top h\rightarrow \|\xi\|^2$,我们得到
$$
f_1-f\rightarrow -\chi K(\xi,\xi)\stackrel{\text{def}}{=}-\chi \|\xi\|^2,
$$
即 $f$ 通过核梯度下降来演化。我们的推导仅仅展示了展示了SGD的第一步，但是同理可证SGD的所有步骤都能得到相同的结论。

我们把更一般的情形总结如下，这从 <a href="#thm1"></a> 和 <a href="#cor1"></a> 可以自然得到。

```theorem Kernel Regime
一个$L$隐藏层的MLP在*标准参数化*下(<a href="tab1"></a>)可以在只允许 SGD 学习率为 $O(1/n)$，如果我们需要 $\lim_{n\rightarrow \infty}\mathbb{E} f_t(\xi)^2<\infty$ 对任意的训练路径，时间$t$，和输入$\xi$。在这种情形下，这在核regime，且没有特征学习。
```


# Maximal Update Parametrization
正如之前的章节所示，标准的参数化在不使 logits 爆炸的前提下得到特征学习。这里我们提出对标准参数化进行简单的修改来使得在保持稳定性的同时可以 1) 能够 feature learning, 这只需要将 logits 除以 $\sqrt{n}$ 且使用 $\Theta(1)$ 的学习率即可，即，设置 $a_{L+1}=1/2,c=0$ 2) 允许每一层都有 feature learning,我们应当进一步设置 $a_1=-1/2,b_1=1/2$。我们将会看到这意味着我们在不导致logits或激活值爆炸的前提下，尽可能更新每个权重矩阵，因此，我们称之为 Maximal Update Parametrization (MUP, $\mu$ P)。

## Dividing Logits by $\sqrt{n}$
例如，在2层隐藏层的线性MLP例子中，网络将会计算
```equation
$$ f(\xi)=\frac{1}{\sqrt{n}} v \bar{h}(\xi), \quad \bar{h}(\xi)=W h(\xi), \quad h(\xi)=U \xi $$
```
其中 $U_{\alpha\beta}\sim\mathcal{N}(0,1)$和$W_{\alpha\beta},v_{\alpha\beta}\sim\mathcal{N}(0,1/n)$ 是训练参数。比起 <a href="#eq10"></a>，$h(\xi),\bar{h}(\xi)$保持一致；只有logits$f(\xi)$是缩放的。再一次，为了简化记号，我们简写$\bullet=\bullet_0$并抑制对$\xi$的显示依赖。这有两个后果

### Logites at Initialization Converge to $0$
由于$f$有着$\Theta(1/n)$的方差 （比起MLP在SP初始化的GP极限）

### $\Theta(1)$ Learning Rate and Feature Learning
尽管$f\rightarrow 0$，损失的导数 $\chi=\mathcal{L}'(f,y)$保持$\Theta(1)$若$y\neq 0$。当我们重新做 <a href="#eq12"></a> 的计算，我们得到
```equation
$$ \begin{aligned} \bar{h}_{1} & =\bar{h}-n^{-c-1 / 2} \chi v^{\top} h^{\top} h=\bar{h}-\Theta\left(n^{-c+1 / 2}\right) v^{\top} \\ f_{1} & =f-n^{-c-1} \chi v v^{\top} h^{\top} h=f-\Theta\left(n^{-c}\right) .\end{aligned} $$
```
由于 $v$ 有着大小 $\Theta(n^{-1/2})$，我们发现$\bar{h}$和$f$都改变$\Theta(1)$若$c=0$(即学习率是$\Theta(1)$)。这直接揭示了1步SGD以后的特征学习。对于更一般的MLPs，我们将会检查 $a_{L+1}=1/2,c=0$，并因此得到 <a href="#thm4"></a>。

### Kernel Behavior or Lack Thereof
这里我们举的是只训练线性MLP的中间层的例子，实际上在 kernel regime。这和<a href="#cor1"></a> 并不冲突，然而，其有<a href="#asmp1"></a>。如果，举个例子，我们有$tanh$非线性，那么很容易看到$\mu P$ SGD的动力学不会有核极限：如果是，那么 $f_1-f$是在学习率为$\eta$的情况下线性的。但是注意到$\bar{h}_1-\bar{h}$是$\Theta(1)$的随着$n\rightarrow \infty$且在$\eta$是线性的，正如 <a href="#eq15"></a>类似导出的。因为 $tanh$ 是有界的，这不可能发生。与SP或NTP相对的，其中$\bar{h}_1-\bar{h}$是$\Theta(1/\sqrt{n})$且因此“位于$tanh$的线性区域”，允许通过$\eta$进行完美的缩放。

此外，就算是在一个线性的MLP，如果我们训练中间的层和最后一层，那么直观上，权重的动力学就会变成二次的，因此不会有该极限。与SP或NTP不同，它们由于学习率较小且采用一阶泰勒展开启发式方法，抑制了这些高阶交互作用。

### How is this different from standard parametrization with learning rate $1/\sqrt{n}$?
如以上所示，logits $f$ 增大了 $\Theta(\sqrt{n})$ 在SP的一步学习率为$\Theta(1/\sqrt{n})$的 SGD 后，但是在我们的参数化下依然是$\Theta(1)$。这两种参数化看着相似的原因是因为在一步，权重得到了相同的更新$\chi=\mathcal{L}'(f,y)$。因此，$x_1^L-x^L$和$h_1^L-h^L$在所有的情况下都是$\Theta(1)$的。然而，这更新使得$x_1^L$和$W_1^{L+1}$相关，因此$W_1^{L+1}x_1^L$(和$f_1$)缩放为$\Theta(n^{1-a_{L+1}-b_{L+1}})$由于大叔定律。因此只有在我们的参数化下($a_{L+1}=b_{L+1}=1/2$)是$\Theta(1)$，尽管在SP($a_{L+1}=0,b_{L+1}=1/2$)其增长为$\Theta(\sqrt{n})$。对比起其在初始化的表现，其中$W^{L+1}$和$x^L$都独立且零均值，因此$W^{L+1}x^L$缩放为$\Theta(n^{1/2-a_{L+1}-b_{L+1}})$通过中心极限定理。

## 第一层参数化
尽管现在可以进行 feature learning 了，第一层的预激活 $h$ 在整个训练过程中保持了固定，如果我们训练$U$。举个例子，如果我们在线性MLP例子 <a href="#eq14"></a>，然后通过<a href="#eq11"></a>，
$$ \begin{array}{l}U_{1}=U-n^{-c} \chi d U=U-n^{-c} \chi d h \xi^{\top} \\ h_{1}=U_{1} \xi=h-n^{-c} \chi d h \xi^{\top} \xi=h-\Theta\left(n^{-c}\right) d h\end{array} $$
由于$\xi^\top\xi,\chi=\Theta(1)$。现在$dh=W^top d\bar{h}=W^\top \frac{1}{\sqrt{n}}v^\top$ 有iid 的高斯坐标，每个的大小为 $\Theta(1/n)$，由于$\frac{1}{\sqrt{n}}v^\top$有着相同的坐标大小。因此，甚至$c=0,h$会被最多$(1/n)$大小改变，其被其初始化的值所主导。这个$O(1/n)$的改变同样在$f$得到了$O(1/n)$的改变，其将会被$\Theta(1)$的改变所主导，由于$W$的演化，见<a href="#eq15"></a>。

我们因此提出设置<a href="#sec6-1"></a>中的参数化：$a_1=-1/2,b_1=1/2$。这意味着$f$的前向传播保持不变，但是$U$的梯度会通过$n$缩放，因此$h$现在会改变$\Theta(1)$的大小。总的来说，我们定义
```definition (定义 5.1)
*Maxinal Upate Parametrization (MUP, $\mu P$)* 在一个$L$-隐层层的MLP中，给定为
$$ c=0, \quad b_{l}=1 / 2 \forall l, \quad a_{l}=\left\{\begin{array}{ll}-1 / 2 & l=1 \\ 0 & 2 \leq l \leq L \\ 1 / 2 & l=L+1\end{array}\right. $$
注意到$\mu P$对于一个单隐藏层的感知机等价于通过<a href="#eq5"></a>的平均场参数化。我们在附录同样描述了各种结构的$\mu$P。
```

## $\mu P$ 在最大化些什么？
出于技术原因，我们对本节的形式结果再次采用<a href="#asmp1"></a>。

在 abc-parametrization 下，权重$W=W_t^l$对任意$l\geq 2$由于学习率$n^{-c}$为$\delta W\stackrel{\text{def}}{=}-n^{-c}\cdot n^{-2a} dh x^\top$ 我们缩写为 $x=x_t^{l-1},h=h_t^l,a=a_l$。(我们将会使用$\delta$来标识一步的变化，但是$\Delta$表示 lifetime change)。在之后的前向传播，$\delta W$的贡献为$\delta W \bar{x}=-n^{1-c-2a}(x%\top \bar{x}/n)dh$，其中$\bar{x}$ 是由于之前层权重的改变得到的新的激活。一般来说，$x$和$\bar{x}$是强相关的。那么$x^\top \bar{x}/n\rightarrow R$对某些$R\neq 0$通过大数定律(因为在stable parametrization 下有着 $\Theta(1)$ 大小)。可以启发式的看到$dh$在最后一层的权重有着相同的大小，其为 $\Theta(n^{-(a_{L+1}+b_{L+1})}+n^{-(2a_{L+1}+c)})$(其中第一个和数从$W_0^{L+1}$来，另一个从$\Delta W_t^{L+1}$来)。因此，$\delta W\bar{x}$ 是一个向量；若$r_l<0$，那么$\delta W \bar{x}$会爆炸。对于$l=1$，我们在考虑了$\xi$的维度后，得到了类似的见解。

```definition (定义 5.2)
对于$l\in [L]$，我们说$W^l$是最大限度更新的，如果$\Delta W_t^l x_t^{l-1}(\xi)$ 有 $\Theta(1)$的大小，对于某些训练路径，时间$t\geq 1$，以及输入$\xi$。
```


```proposition (5.3)
在 stable abc-parametrization 下，对于任意的 $l\in [L]$，$W^l$ 是最大化更新的 当且仅当
$$
r_l\stackrel{\text{def}}{=}\min(a_{L+1}+b_{L+1},2a_{L+1}+c)+c-1+2a_l+\mathbb{I}(l=1)=0.
$$
```

注意到<a href="#def1"></a> 在所有的$l$中最小的$r_l$。在$\mu P$，我们可以计算$r_l=0$对所有的$l\in [L]$，因此所有的$W^l,l\in [L]$，都 *updated maximally*。换一种说法，最后的嵌入$x^L(\xi)$ 将会从 $\Delta W^l$ 对所有$l$得到非零 (非线性)贡献。这些贡献导致 logit $f(\xi)$ 在和$W_0^{L+1}$ 和 $\Delta W_0^{L+1}$ 交互的时候发生改变。如果$W_0^{L+1}$和$\Delta W_0^{L+1}$太小，那么 logit对其初始值就是固定的，因此所有的特征学习都是无用的。也有可能一个贡献消失，但是另一个没有，但在 $\mu P$ 中都有贡献。

```definition (定义 5.4)
我们称 $W^{L+1}$ 是 *updated maximally* (*initialized maximally*) 的如果 $\Delta W_t^{L+1}x_t^L(\xi)=\Theta(1)$ ($W_t^{L+1}\Delta x_t^L(\xi)=\Theta(1)$) 对于一些训练路径，时间$t\geq 1$以及输入$\xi$。
```

注意到 <a href="#def6"></a> 和<a href="#def5"></a> 很像，除了 $\Delta W_t^{L+1}x_t^L(\xi)\in\mathbb{R}$以及$\Delta W_t^lx_t^{l-1}(\xi)\in\mathbb{R}^n$。


```proposition (Proposition 5.5)
在 stable abc-parametrization 中，$W^{L+1}$ 是 1) updated maximally iff $2a_{L+1}+c=1$，且 2) initialized maximally iff $a_{L+1}+b_{L+1}+r=1$。
```

```theorem (定理 5.6)
在$\mu P$，$W^l$对每个$l\in [L+1]$ *upated maximally*，且$W^{L+1}$被 initialized maximally。 $\mu P$ 在这种性质下是唯一 stable abc-parametrization。 
```

# Deriving Feature Learning Infinite-Width Limit: Intuition and Examples
我们提出 *Tensor Programs technique* 用于得到任何 abc-parametrization 的无穷宽极限。这最终只需要研究人员机械的将一组规则应用于SGD下的计算图。然而，尽管操作简单，这个程序在开始看起来“太神奇”了。在这一节，通过一系列的例子，我们试图建立对这个过程自动化的直觉。然后，在下一节中，我们正式描述 Tensor Programs 框架。

**Setup and Notation**
为了简单的把这件事情讲清楚，我们只考虑输入维度$d=1$以及学习率$\eta=1$，但是泛化到$d>1,\eta\neq 1$是直接点。我们考虑 单例小批次 SGD $\{(\xi_t,y_t)\}$ 在时间 $t=0,1,2,\ldots$，其中$\xi_t$ 是网络的输入且 $y_t$ 是标签。我们记$W_t^l$ 为矩阵$W^l$ 在$t$步这样的训练以后。对于任意的网络输入$\xi\in\mathbb{R}$，我们记 $x_t^l(\xi)$ ($h_t^l(\xi)$,$f_t(\xi)$) 对于激活 $x^l$ (preactivation $h^l$, logits $f$) 在$t$步SGD的网络。我们记缩放的梯度 $n\nabla_{x_{t}^l} f_t(\xi)$ ($n \nabla_{h_t^l} f_t(\xi)$) 通过 $d x_t^l(\xi)$ ($d h_t^l(\xi)$)。为了简洁起见，我们滥用符号并使用 $x_t^l$ (没有用到$\xi$) 来表示向量 $x_t^l(\xi_t)$；类似的，对于$h_t^l,d h_t^l,d x_t^l,f_t$。我们将不会使用 $x_t^l$ 来记函数 $\xi \mapsto x_t^l(\xi)$ 使其不会造成混淆。损失函数记为 $\mathcal{L}$ 损失的导数 $\mathcal{L}'(logit,target)$ 是对第一个参数的。我们记 $\chi_t\stackrel{\text{def}}{=}\mathcal{L}'(f_t,y_t)$。

## 1-Hidden-Layer MLP
如之前所提到的，对于单隐藏层，无穷宽$\mu P$的极限和平均场极限一样。此外，我们还提出了一个稍微不同的推导，更符合张量程序的哲学。在输入$\xi\in \mathbb{R}$ 的网络给定为
```equation
$$
f(\xi)=V x(\xi), \quad x(\xi)=\phi(h(\xi)), \quad h(\xi)=U \xi,
$$
```
对于$U\in \mathbb{R}^{n\times 1},V\in\mathbb{R}^{1\times n}$被参数化为 $U=\sqrt{n}u,V=\frac{1}{\sqrt{n}}v$且初始化$u_{\alpha\beta},v_{\alpha\beta}\sim\mathcal{N}(0,1/n)$。那么$U_0$($U$的初始值)有着 iid $\mathcal{N}(0,1)$ 的数值。将这样的坐标分布表征为随机变量$Z^{U_0}\stackrel{\text{def}}{=}\mathcal{N}(0,1)$是最方便的。类似的，令$Z^{n V_0}\stackrel{\text{def}}{=}\mathcal{N}(0,1)$，独立于 $Z^{U_0}$，表示 $n V_0$ 的坐标分布。在陈述一般情况之前，我们手动导出了第一次前向和后向传播的 $\mu P$ 极限。为了简化符号，我们隐去了$t=0$的下标($U=U_0,h=h_0,f=f_0$)，因为我们将在第一个SGD步骤上花更多时间。

**第一步前向传播** 在随机初始化后，预激活 $h=h(\xi)$ (其中$\xi=\xi_0\in\mathbb{R}$是第一个输入)有着 iid coordinates，每个从 $Z^x\stackrel{\text{def}}{=} \phi(Z^h)$。最后，$f=Vx=\frac{1}{n}\sum_{\alpha=1}^n (nV)_\alpha x_\alpha\rightarrow \stackrel{\circ}{f} \stackrel{\text { def }}{=} \mathbb{E} Z^{nV}Z^x$ 通过大数定律随着 $n\rightarrow \infty$得到。特别的，$f$在极限下变成确定的$0$，由于$V$和$U$是独立的。对于典型的损失函数$\mathcal{L}$，损失的导数$\chi\stackrel{\text{def}}{=} \mathcal{L}'(f,y)$ 也变成了确定的，$\chi\rightarrow \stackrel{\circ}{\chi}\stackrel{\text{def}}{=}\mathcal{L}'(\stackrel{\circ}{f},y)$。

**第一步后向传播** 类似的，$dx=n V^\top$ (回顾 $d x_t\stackrel{\text{def}}{=} n\nabla_{x_t}f_t$)有着坐标分布如$Z^{dx}\stackrel{\text{def}}{=}Z^{nV}$ 以及 $dh= dx \odot \phi'(h)$ 有着坐标分布 $Z^{dh}=\stackrel{def}{=}Z^{dx} \phi'(Z^h)=Z^{nV}\phi'(Z^h)$。那么SGD以$1$学习率有以下更新
$$ \begin{array}{lll}v_{1}=v-\chi x / \sqrt{n} & \Longrightarrow & V_{1}=V-\chi x / n \\ u_{1}=u-\chi \xi d h / \sqrt{n} & \Longrightarrow & U_{1}=U-\chi \xi d h .\end{array} $$
由于$\chi$收敛到特定的极限$\stackrel{\circ}{\chi}$，这些更新的坐标大致是iid的，对应于$Z$随机变量的更新：
$$ Z^{n V_{1}}=Z^{n V}-\stackrel{\circ}{\chi} Z^{x}, \quad Z^{U_{1}}=Z^{U}-\stackrel{\circ}{\chi} \xi Z^{d h} .$$

**第二次前向传播** 因此 $V_1$ 和 $U_1$在1步SGD后是大致 iid 坐标。那么，在第二步前向传播后，$h_1$有
$$
Z^{h_{1}} \stackrel{\text { def }}{=} \xi_{1} Z^{U_{1}}=\xi_{1} Z^{U}-\xi_{1} \stackrel{\circ}{\chi} \xi Z^{d h}=\xi_{1} Z^{U}-\xi_{1} \stackrel{\circ}{\chi} \xi Z^{n V} \phi^{\prime}\left(Z^{h}\right),
$$
$x_1$有着大小 $Z^{x_1}\stackrel{\text{def}}{=}\phi(Z^{h_1})$，且输出为
```equation
$$ f_{1}=\frac{1}{n} \sum_{\alpha=1}^{n}\left(n V_{1}\right)_{\alpha} x_{\alpha} \rightarrow \stackrel{\circ}{f_{1}} \stackrel{\text { def }}{=} \mathbb{E} Z^{n V_{1}} Z^{x_{1}}=\mathbb{E}\left(Z^{n V}-\stackrel{\circ}{\chi} Z^{x}\right) Z^{x_{1}} $$
```
随着$n\rightarrow \infty$。那么$\chi_1\stackrel{\text{def}}{=}\mathcal{L}'(f_1,y_1)\rightarrow \stackrel{\circ}{\chi_1}\stackrel{\text{def}}{=}\mathcal{L}'(\stackrel{\circ}{f_1},y_1)$变成确定的。梯度向量通过相似的logic有着大致 iid的 coordinates。

第$t$步**迭代** 重复上述推理表明，在任何时间$t$(独立于$n$)，我们有

```theorem (定理 6.1)
考虑一个单隐藏层MLP在 $\mu P$(<a href="#eq16"></a>) 且任何训练过程有着学习率$1$。假设$\phi'$是伪-Lipschitz的。那么随着$n\rightarrow \infty$，对于任何输入$\xi$，$f_t(\xi)$几乎一定收敛到 $\stackrel{\circ}{f_t}(\xi)$ 定义如下：
```
```equation
$$ f_{t}(\xi) \xrightarrow{\text { a.s. }} f_{t}(\xi) \xlongequal{\text { def }} \mathbb{E} Z^{n V_{t}} Z^{x_{t}(\xi)}, \quad Z^{x_{t}(\xi)} \xlongequal{\text { def }} \phi\left(Z^{h_{t}(\xi)}\right), \quad Z^{h_{t}(\xi)} \xlongequal{\text { def }} \xi Z^{U_{t}} $$
```
```equation
$$ \stackrel{\circ}{\chi}_{t} \stackrel{\text { def }}{=} \mathcal{L}^{\prime}\left(\stackrel{\circ}{f}_{t}, y_{t}\right), \quad Z^{n V_{t+1}} \stackrel{\text { def }}{=} Z^{n V_{t}}-\stackrel{\circ}{\chi}_{t} Z^{x_{t}}, \quad Z^{U_{t+1}} \stackrel{\text { def }}{=} Z^{U_{t}}-\stackrel{\circ}{\chi}_{t} \xi_{t} Z^{n V_{t}} \phi^{\prime}\left(Z^{h_{t}}\right) $$
```
由初始化条件，$Z^{U_0}$和$Z^{n V_0}$是独立的标准高斯，其中在<a href="#eq19"></a> 我们简写 $\stackrel{\circ}{f_t}=\stackrel{\circ}{f_t}(\xi)$, $x_t=x_t(\xi_t)$, $h_t=h_t(\xi_t)$。

如之前所示，这是离散时间，小批次的MFL版本。当$\phi$ 是单位的，这很容易看到$Z^{n V_t}$和$Z^{U_t}$ 总是$Z^{n V_0}$和$Z^{U_0}$的线性组合，即$Z^{n V_t}=A_t Z^{n V_0}+B_t Z^{U_0}$和$Z^{U_t}=C_t Z^{n V_0}+D_t Z^{U_0}$。然后极限$\stackrel{\circ}{f_t}$仅依赖于 $A_t,B_t,C_t,D_t$。通过追踪这些演化，我们得到了如下的极大简化后的形式，对于一个无穷宽的 $\mu P$线性网络。

```corollary (推论 6.2)
考虑一个单隐藏层的线性MLP在$\mu P$ (<a href="#eq16"></a>)且任何训练过程有着学习率$1$。随着$n\rightarrow \infty$，对于每个输入 $\xi$， $f_t(\xi)$ 几乎一定收敛到如下定义的$\stackrel{\circ}{f_t(\xi)}$：
$$ \begin{aligned} \dot{f}_{t}(\xi) & =\left(A_{t} C_{t}+B_{t} D_{t}\right) \xi, \quad \dot{\chi}_{t}=\mathcal{L}^{\prime}\left(\dot{f}_{t}, y_{t}\right), \\ \left(A_{t+1}, B_{t+1}\right) & =\left(A_{t}, B_{t}\right)-\dot{\chi}_{t} \xi_{t}\left(C_{t}, D_{t}\right), \\ \left(C_{t+1}, D_{t+1}\right) & =\left(C_{t}, D_{t}\right)-\dot{\chi}_{t} \xi_{t}\left(A_{t}, B_{t}\right),\end{aligned} $$
以初始化条件 $A_0=D_0=1,B_0,C_0=0$。
```

这很容易泛化到大的输入和输出维度。简而言之，这样的无穷宽 $\mu P$ 线性网络有着输入维度$d$以及输出维度$d_o$ 是等价于一个宽度为 $d+d_o$ 大的线性网络，有着相同的输入/输出维度，但是是“对角”的，而不是随机，初始化的。我们的 Word2Vec 和 MAML 实验将会关键地依赖于这种简化地观察。我们注意到，与我们的方法相反，这样的观察被之前工作的偏微分方程视角所覆盖。

## 2-Hidden-Layer MLP: SGD with Partially Decoupled Backpropagation
一个 2-hidden-layer MLP 通过以下给出
$$ f(\xi)=V \bar{x}(\xi), \quad \bar{x}(\xi)=\phi(\bar{h}(\xi)), \quad \bar{h}(\xi)=W x(\xi), \quad x(\xi)=\phi(h(\xi)), \quad h(\xi)=U \xi,$$ 
对于 $U\in\mathbb{R}^{n\times 1},W\in\mathbb{R}^{n\times n}$ 参数化为$U=\sqrt{n}u,V=\frac{1}{\sqrt{n}}v$且有着初始化 $u_{\alpha\beta},W_{\alpha\beta},v_{\alpha\beta}\sim\mathcal{N}(0,1/n)$。$n\times n$的矩阵$W$存在("$\infty\times \infty$"，相对于$U$的"$\infty\times \text{finite}$",或是$V$的"$\text{finite}\times \infty$")是新的且对无穷宽的训练动力学有两个主要影响： 1) 从随机高斯$W$的中心极限效应 2) $W$和$W^\top$ 的相关效应。 我们通过分析一个稍微不同的反向传播版本(它与正常的反向传播有不同的限制)来隔离第一种效应，然后再下一届讨论第二种效应。我们滥用符号，缩写$W=W_0$。

**Partially Decoupled Backpropagation** 在这一节，我们分析SGD的版本，其反向传播的权重与前向传播权重部分解耦合。这里，我们认为$\Delta W_t$是可训练的权重，初始化为$0$，并将高斯$W$认为是不可训练的“常数”。前向传播正常时$W_t=W+\Delta W_t$。但是我们采样并固定 iid $W^\top$ 的拷贝 $\tilde{W}$在训练钱，在反向传播计算
```equation
$$ d x_{t}=\left(\widetilde{W}+\Delta W_{t}^{\top}\right) d \bar{h}_{t} \quad \text{instead of} \quad d x_{t}=\left(W^{\top}+\Delta W_{t}^{\top}\right) d \bar{h}_{t}=W_{t}^{\top} d \bar{h}_{t} .$$
```

特别的，在初始化时，我们有 $d x_0=\tilde{W}d \bar{h}_0$ 而不是 $d x_0=W^\top d\bar{h}_0$。在反向传播中，其它一切都保持不变。最后，每个权重都依然可以通过SGD的外积来更新：以$\chi_t\stackrel{\text{def}}{=}\mathcal{L}'(f_t,y_t)$，
```equation
$$ v_{t+1}=v_{t}-\chi_{t} \bar{x}_{t}^{\top} / \sqrt{n}, \quad \Delta w_{t+1}=\Delta w_{t}-\chi_{t} d \bar{h}_{t} x_{t}^{\top} / n, \quad u_{t+1}=u_{t}-\chi_{t} \xi_{t} d h_{t}^{\top} / \sqrt{n}. $$
```
由于 $V=v/\sqrt{n},W=w,U=\sqrt{n}u$对于每个 $\mu P$，这导致以下$W$的改变：
```equation
$$ V_{t+1}=V_{t}-\chi_{t} \bar{x}_{t}^{\top} / n, \quad \Delta W_{t+1}=\Delta W_{t}-\chi_{t} d \bar{h}_{t} x_{t}^{\top} / n, \quad U_{t+1}=U_{t}-\chi_{t} \xi_{t} d h_{t}^{\top} $$
```
注意到我们是在更新$\Delta w,\Delta W$而非$w,W$。

**Why This Decoupled SGD?** 
我们讨论这个版本的SGD的原因是其隔离了在反向传播有 Gaussian $n\times n$ 高斯矩阵 $\tilde{W}$，我们可以用中心极限导出其无穷宽极限。在正常版本的SGD中，$\tilde{W}$会等于$W^\top$，且其和$W$的相关性造成了无穷宽动力学的额外项，它们自己解释的更好。

同样，在陈述一般情况前，我们通过几次前向和后向传播来获得对无穷宽极限的直觉。










# 参考文献
```bib
@InProceedings{pmlr-v139-yang21c,
  title = 	 {Tensor Programs IV: Feature Learning in Infinite-Width Neural Networks},
  author =       {Yang, Greg and Hu, Edward J.},
  booktitle = 	 {Proceedings of the 38th International Conference on Machine Learning},
  pages = 	 {11727--11737},
  year = 	 {2021},
  editor = 	 {Meila, Marina and Zhang, Tong},
  volume = 	 {139},
  series = 	 {Proceedings of Machine Learning Research},
  month = 	 {18--24 Jul},
  publisher =    {PMLR},
  pdf = 	 {http://proceedings.mlr.press/v139/yang21c/yang21c.pdf},
  url = 	 {https://proceedings.mlr.press/v139/yang21c.html},
  abstract = 	 {As its width tends to infinity, a deep neural network's behavior under gradient descent can become simplified and predictable (e.g. given by the Neural Tangent Kernel (NTK)), if it is parametrized appropriately (e.g. the NTK parametrization). However, we show that the standard and NTK parametrizations of a neural network do not admit infinite-width limits that can *learn* features, which is crucial for pretraining and transfer learning such as with BERT. We propose simple modifications to the standard parametrization to allow for feature learning in the limit. Using the *Tensor Programs* technique, we derive explicit formulas for such limits. On Word2Vec and few-shot learning on Omniglot via MAML, two canonical tasks that rely crucially on feature learning, we computed these limits exactly. We find that they outperform both NTK baselines and finite-width networks, with the latter approaching the infinite-width feature learning performance as width increases.}
}
```

