---
title: "论文精读：'Feature Learning in Infinite-Width Neural Networks'"
date: "2025-06-24"
tags: ["Notes", "论文精读", "神经网络理论"]
keywords: ["Feature Learning", "NTK", "Theory", "Infinite-width neural networks"]
excerpt: "尽管NTK极限下得到了很漂亮的深度神经网络的近似，但是也同时失去了特征学习能力。这篇文章发现通过修改标准的参数化方式，就可以使得在无穷宽极限下进行特征学习，并使用 'Tensor Programs' 技术导出了这个极限的显式形式。Feature Learning 对于迁移学习非常重要，可以说，如果学不到特征，那么迁移学习都不存在可行性。"
visible: true
---

## 论文来源
Greg Yang 大神的 Tensor Program 系列第四篇，其它的系列作品有时间和需求时后续再进行更新补充。

## 前言
![图1: US cities and states的Word2Vec 嵌入的PCA](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506241301504.png?imageSlim)

在NTK极限下，预训练学到的特征和随机初始化没什么区别(见图1的实验)。而特征学习本身在深度学习中很有影响力，这对于NTK理论用于神经网络实际分析时是很致命的。而这篇文章则发现可以通过修改标准的参数化达到过参数化模型也可以进行特征学习的目的。

### abc-Parametrizations
考虑一个 $L$-隐藏层的感知机：权重矩阵 $W^1\in\mathbb{R}^{n\times d}$ 且 $W^2,\ldots,W^L\in\mathbb{R}^{n\times n}$，且非线性项 $\phi:\mathbb{R}\rightarrow \mathbb{R}$，使得神经网络在输入 $\xi\in\mathbb{R}^d$上为 $h^1(\xi)=W^1\xi\in\mathbb{R}^n$，且
$$
x^l(\xi)=\phi(h^l(\xi))\in\mathbb{R}^n, h^{l+1}(\xi)=W^{l+1}x^l(\xi)\in\mathbb{R}^n,\text{ for } l=1,\ldots,L-1,
$$
且网络的输出 (也称为 $logits(s)$) 是 $f(\xi)=W^{L+1}x^L(\xi)$ 对于 $W^{L+1}\in\mathbb{R}^{1\times n}$。一个 abc-parametrization 由系列数字 $\{a_l,b_l\}_l\cup \{c\}$ 使得：

(a) 我们参数化每个参数为 $W^l=n^{-a_l}w^l$ 对于实际的可训练参数 $w^l$
(b) 初始化 $w_{\alpha\beta}^l\sim\mathcal{N}(0,n^{-2b_l})$ 
(c) SGD 的学习率是 $\eta n^{-c}$ 对于一些宽度无关的 $\eta$ 。

**例**：
NTK 参数化 (NTP) 有着 $a_1=0$且 $a_l=1/2$对于$l\geq 2$；$b_l=0$ 对所有的 $l$；$c=0$。 当深度 $L=1$，平均场参数化 (MFP) 有 $a_1=0$， $a_2=1$；$b_l=0$ 对所有的 $l$；$c=-1$。标准参数化 (SP) 是 Pytorch的默认设定，有着 $a_l=0$ 对所有的 $l$；$b_1=0$ 且 $b_l=1/2$ 对所有的 $l\geq 2$；$c=0$。然而，我们会看到 $c$ 在SP中太小了。我们可以定义 abc-parametrization 并将我们的结果推广到任意神经网络结构 (附录 C)，但我们将在正文中主要聚焦 MLPs。

### 动力学二分
对任意 abc-parametrization，若 $c$ 太小了，SGD可能会导致预激活或logits爆炸；我们说这个参数化是*不稳定*的。实际上这就变成了数值问题，如果 $c$ 太大 (即学习率太小)，那么由网络计算得到的函数在有限的时间内没有改变；我们称这个参数化是*平凡*的。我们证明了我们称为 *Dynamical Dichotomy theorem*:

> Any nontrivial stable abc-parametrization 都有一个无穷宽的极限。这个极限要么 1) 允许嵌入 $x^L(\xi)$ 非平凡演化或是 2) 通过函数空间的核梯度下降描述，但并不能同时进行描述。

我们称前一种情况为 *feature learning limit* 后一种为 *kernel limit*。对于单隐藏层的MLPs，前一种会在MFP发生，而后一种则在NTP中发生。这个二分意味着一些函数动力学，如NTK动力学的高阶推广，都不是有效的无限宽极限。此外，任意特征学习极限的神经网络函数 $f$ 在初始化时必须等于$0$。

### 标准参数化(SP)不会学习特征
我们表明 SP (或NTP) 只能以 $O(1/width)$ (或$O(1)$) 的学习率 (即，$c=1$或$c=0$)，来避免爆炸，并取得核限制。相反的，我们提出有着 $\Theta(1)$ 最大学习率的参数化方式，能够最大程度上得到 feature learning：其允许每个参数都最大化的更新却不至于爆炸。我们称之为 *最大更新参数化 (Maximal Update Parametrization, MUP或$\mu P$)*。其通过 $a_1=-1/2,a_{L+1}=1/2$给出，且 $a_l=0$对所有的 $2\leq l\leq L$成立；$b_l=1/2$对所有的$l$成立；$c=0$。在单隐藏层的MLP，这就对应于MFP。这里的"feature learning limits"都指的是$\mu P$ limits。我们在**下图**中展示了实验验证的最大学习率在2 个隐藏层的 relu MLP 的最大学习率的预测，在CIFAR 10上使用平方损失进行训练。我们在每个子图中绘制出准确率随着学习率的变化情况。每个曲线代表着MLP有着特定的宽度。每个曲线的最右边代表着最大的学习率。对角线的子图代表着学习率随着网络宽度正确缩放了。即SP的的最大学习率是 1/width，而$\mu P$则是常数。

![$\mu$P和SP最大学习率验证{width=50%}](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506241535691.png?imageSlim)

### Key Theoretical Idea: Tensor Programs
这个方法的主要 insight 是：
> 当宽度很大的时候，在训练**任何时间**，每个激活向量有大致的iid坐标，使用 *Tensor Programs* 可以递归计算坐标分布，进而理解神经网络的演化。

![一图看懂 NNGP, NTK, Feature Learning Limit {width=50%}](https://picgo-1317104440.cos.ap-nanjing.myqcloud.com/202506241646056.png?imageSlim)

从上图可以知道，Neural Network-Gaussian Process (NNGP) 可以认为是第一次前向传播的随机初始化模型的极限；而NTK可以认为是第一次反向传播的极限；计算极限的机制是，1) 将相关神经网络的计算写成矩阵乘法与坐标非线性的原则性组合，称为 *Tensor Program* 2) 通过 *Master Theorem* 来递归的计算每个向量的坐标分布。在本文中，我们完全遵循相同的方法，在 1) 中我们直接写下整个 SGD 的训练而非只是第一步，更一般的来说，

> 为了导出**任意**神经计算的无穷宽极限，1) 将其表达为 *Tensor Program* 2) 机械的应用 *Master Theorem*

### 本文的贡献
1. 形式化了神经网络参数化的自然空间 (abc-parametrizations)
2. 证明了 *Dynamical Dichotomy*: 任意 nontrivial 的稳定 abc-parametrization 都有 feature learning 或 kernel limits，但不会同时出现。
3. 证明了 NTK和SP都有 kernel limits，并提出了 *Maximal Update Parametrization ($\mu P$)*，其允许在适当意义上进行最大的特征学习。
4. 使用 Tensor Programs 来导出$\mu P$的无穷宽极限，更一般的来说，是任意 abc-parametrization的极限。我们通过额外的实验验证了我们的理论。
5. 展示了 $\mu P$ 极限比 NNGP/NTK 两个baselines以及有限网络在 1) Word2Vec 以及 2) Omnniglot 少样本学习的优越性。

> **Tensor Programs Series**
> 这篇文章是自包含的，独立于前三篇TP工作，是首个系列工作的一个回报，这篇文章也是TP系列工作的最原始的动机。
















---
## 参考文献
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
  abstract = 	 {As its width tends to infinity, a deep neural network's behavior under gradient descent can become simplified and predictable (e.g. given by the Neural Tangent Kernel (NTK)), if it is parametrized appropriately (e.g. the NTK parametrization). However, we show that the standard and NTK parametrizations of a neural network do not admit infinite-width limits that can *learn* features, which is crucial for pretraining and transfer learning such as with BERT. We propose simple modifications to the standard parametrization to allow for feature learning in the limit. Using the *Tensor Programs* technique, we derive explicit formulas for such limits. On Word2Vec and few-shot learning on Omniglot via MAML, two canonical tasks that rely crucially on feature learning, we compute these limits exactly. We find that they outperform both NTK baselines and finite-width networks, with the latter approaching the infinite-width feature learning performance as width increases.}
}
```

