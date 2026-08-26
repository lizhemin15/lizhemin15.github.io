---
title: "时空可组合之道——从Cordis范式到DeepSeek Harness工程实践"
date: "2026-08-26"
tags: [["读书笔记", "编程范式", "架构设计"]]
keywords: ["动态组合", "可逆效应", "响应式协效应", "上下文范式", "AI Agent"]
excerpt: "插件系统与自进化Agent之困，在于时空不可组合。此文先解Cordis理论，再析DeepSeek Harness源码，揭示可逆效应、响应式协效应如何落地为生产级框架。"
visible: true
pinned: false
---

## 缘起

丙午年七月初九，始研DeepSeek之作《A Programming Paradigm for Spatiotemporal Composability》。此文立意深远，欲解现代软件之根本困境——**动态组合**。

何谓动态组合？插件系统加载卸载，Agent harness自我演化，皆需运行时增删功能，而非重启重载。然今之实践，多赖粗粒度机制：进程重启、容器编排，弃运行时状态如敝屣。此乃权宜之计，非长久之道。

读完此文，又读其代码——DeepSeek Harness。理论如何落地？形式基础如何指导工程？此文即解此惑。

---

## 一、问题：时空不可组合之困

### 时间维度：卸载不可逆

VSCode插件一旦激活，便无法真正卸载；禁用或删除须重启整个扩展宿主，影响所有已加载插件。为何？因插件对环境之修改——注册事件、分配资源、改变状态——未被追踪，亦无逆操作可言。

> **时间可组合性**：组件卸载之时，其对共享环境之修改须完全可逆。

### 空间维度：依赖无契约

VSCode虽有`extensionDependencies`声明依赖，然前百大插件中仅7个使用，且交互通过`vscode.extensions.getExtension(...).exports`暴露，返回值类型为`any`，无结构化契约。插件趋向于宿主提供的固定扩展点，而非彼此依赖。

> **空间可组合性**：组件须能声明、发现、解析彼此依赖，且结构可验证。

经典效应系统与协效应系统，皆**静态之物**：效应追踪在词法固定作用域内，协效应标注在执行前验证。然动态组合要求这些保证对**运行时到达与离开的组件**成立，对**持续演化的上下文**成立。

故作者曰：**不若扩展静态类型系统加更多注解，而将效应与协效应之概念结构具体化，使运行时可直接操作之。**

---

## 二、理论：可逆效应与响应式协效应

### 可逆效应

效应建模为函数 `Γ → Γ × (Γ → Γ)`：作用于当前上下文，产出修改后上下文及**显式逆操作**。

- 提供逆操作→效应可逆
- 返回逆操作给运行时→效应可追踪

此即**可逆效应**。

给定上下文类型Γ，其效应上下文定义为：

```
∂Γ ≔ Γ × (Γ → Γ)
```

其中：
- `γ : Γ` 为当前上下文状态
- `φ : Γ → Γ` 为累积器，即已执行效应逆操作之复合，可将上下文恢复至初始状态

**追踪变换** `trackΓ`：应用效应时，更新状态并累积逆操作。

**恢复变换** `recoverΓ`：应用累积逆操作恢复状态，重置累积器。

**定理**：追踪是幺半群同态，保证序列效应可作为单一效应推理；恢复将上下文恢复至初始状态。

### 响应式协效应

协效应建模为**声明式依赖规范**，每次上下文变化相对于该规范分类：

- **激活**：满足依赖，组件应激活
- **停用**：不再满足，组件应停用
- **中性**：无关变化

此即**响应式协效应**。

### 上下文范式

效应上下文与协效应上下文合而为一：

```
C ≔ Γ × (Γ → Γ) × D
```

其中D为依赖注册表。

所有效应与协效应皆通过统一上下文中介。中介诱导**观察等价**：在此等价下，不同组件之效应交错而不互相干扰。

- **效应独立性**：组件A之效应不影响组件B之效应
- **协效应交换性**：组件A之协效应激活不影响组件B之协效应判断

由此，局部时空可组合性推广至全局。

---

## 三、实践：DeepSeek Harness如何落地

理论终须落地。DeepSeek Harness将Cordis五大核心概念工程化为支撑百万级Agent并发的生产框架。

### Context：服务注册与依赖注入的中枢

Cordis将Context定义为"动态组合演算"的载体——所有服务、插件、事件都通过Context进行组合。Context不是静态容器，而是随Fiber生命周期动态变化的代理对象。

```typescript
// vendor/cordis/src/context.ts
export class Context {
  readonly fiber: Fiber
  readonly events: EventsService
  readonly reflect: ReflectService
  readonly registry: RegistryService
}
```

**关键设计**：

1. **Context是Proxy**：通过`ReflectService.handler`实现属性拦截，任何未显式声明的属性访问都会触发服务解析逻辑。

2. **继承链**：`ctx.extend()`创建子上下文，继承父上下文的所有服务，但可以覆盖特定服务。这实现了论文中的"嵌套上下文"。

3. **Fiber绑定**：每个Context绑定一个Fiber，Fiber的状态决定了Context的可用性。当Fiber进入UNLOADING状态时，Context上的服务会自动失效。

**实践意义**：Agent的scoped context通过`createScope(loopCtx, this)`创建，每个Agent拥有独立的服务视图；工具注册、事件监听、配置读取都通过Context进行，天然支持隔离。

### Fiber：可逆效应的执行单元

可逆效应要求副作用可以被撤销。Fiber是Cordis中承载副作用的最小单元——它记录了所有注册的服务、监听的事件，并在销毁时反向执行这些操作。

```typescript
// vendor/cordis/src/fiber.ts
export class Fiber<T = any> extends Promise<T> {
  state: FiberState = FiberState.PENDING
  private disposers: DisposableList = new DisposableList()
  
  async dispose(): Promise<void> {
    if (this.state === FiberState.DISPOSED) return
    this.setState(FiberState.UNLOADING)
    // 反向执行所有注册的清理函数
    await this.disposers.dispose()
    this.setState(FiberState.DISPOSED)
  }
}
```

**关键设计**：

1. **DisposableList**：使用双向链表管理清理函数，确保注册顺序与销毁顺序相反（LIFO）。这正是论文中"累积逆操作"的工程实现。

2. **状态机**：`PENDING → RUNNING → SETTLED → UNLOADING → DISPOSED`，状态转换严格控制，防止重复销毁。

3. **Inertia**：`fiber.inertia`允许异步清理完成后继续等待，确保所有派生资源都已释放。

**实践意义**：Agent的scoped context对应一个Fiber，Agent销毁时自动清理所有注册的工具、事件监听、子插件；工具执行的pre/post钩子也通过Fiber管理，确保异常情况下也能正确清理。

### Events：响应式协效应的调度引擎

响应式协效应要求系统能够感知环境变化并做出响应。Events是Cordis中实现响应式的核心——监听器随Fiber自动注册和销毁，事件分发支持多种策略。

```typescript
// vendor/cordis/src/events.ts
export type DispatchMode = 'emit' | 'parallel' | 'serial' | 'bail' | 'waterfall'
```

**五种调度模式**：

| 模式 | 行为 | 典型场景 |
|------|------|----------|
| `emit` | 同步执行，不等待结果 | UI状态更新 |
| `parallel` | 并发执行，等待全部完成 | 多文件读写 |
| `serial` | 顺序执行，遇到bail值停止 | 权限检查链 |
| `bail` | 同步执行，返回第一个非空值 | 配置查找 |
| `waterfall` | 洋葱模型，支持next()委托 | 工具执行管道 |

**Context Filter**：通过`thisArg[Context.filter]`实现事件过滤。这是dsh-scope包的核心机制，实现了论文中的"协效应规范"——组件声明所需依赖，运行时据此分类上下文变化。

**Listener Auto-dispose**：监听器注册在当前Fiber上，Fiber销毁时自动移除。这正是响应式协效应的体现：组件停用时，其监听自动注销。

### Scope：上下文隔离与事件路由

上下文范式要求不同Agent的环境相互隔离，但有时需要向上传播事件（如监控组件观察多个Agent）。Scope实现了这种"向下继承、向上传播"的层级关系。

```typescript
// packages/core/scope/src/index.ts
export function scopeTarget<T>(base: T, key: ScopeKey): Scoped<T> {
  return {
    [Context.filter](ctx: Context): boolean {
      const tag = scopeOf(ctx)
      if (tag === undefined) return true
      // 事件向上传播：监听者可以接收后代scope的事件
      for (let cursor = key; cursor !== undefined; cursor = scopeParents.get(cursor)) {
        if (cursor === tag) return true
      }
      return false
    },
  }
}
```

**关键设计**：

1. **Scope Key**：每个Scope有一个唯一的opaque identity，用于事件路由。

2. **Parent Link**：`scopeParents` WeakMap维护父子关系，支持cycle check。

3. **Event Routing**：`scopeTarget`构建的carrier只匹配当前scope或其祖先scope的监听器。

**实践意义**：每个Agent有自己的scope，工具注册、事件监听都限定在该scope内；监控组件可以监听所有Agent的事件（因为它属于root scope）；工具调用的`exec.agent`字段确保事件只路由到正确的Agent。

### Tool Calls：工具调用的并发调度

AI Agent的核心能力是调用外部工具。Cordis要求工具调用支持并发、取消、重试，并且结果必须有序提交给模型。

```typescript
// packages/core/agent-loop/src/tool-calls.ts
let next = 0
while (next < planned.length) {
  const mode = ctx.tools.executionMode(first.exec).kind
  const group = mode === 'parallel' ? planned.slice(next) : [first]
  const outcome = await runGroup(ctx, turn, step, group, mode, signal, acceptContext)
  next += outcome.consumed
  if (outcome.aborted) {
    // 记录跳过的调用，保持模型顺序
    for (const call of planned.slice(next)) appendSkippedToolCall(session, turn, step, call.block)
    return { concluded: outcome.concluded }
  }
}
```

**关键设计**：

1. **并发模式分类**：`executionMode()`根据工具声明决定并发策略（exclusive vs parallel）。

2. **Bounded Pool**：并行调用使用有界池，`maxParallelToolCalls`限制同时执行的调用数。

3. **Ordered Commit**：即使并发执行，结果也按模型顺序提交，确保日志一致性。

4. **Abort Handling**：取消时记录合成错误结果，保证重放有效性。

### Session：会话持久化的不可变日志

会话历史是AI Agent的核心状态。Cordis要求会话日志是不可变的，支持fork和resume，并且能够序列化为JSON。

```typescript
// packages/core/session/src/index.ts
export class Session {
  append(event: Omit<SessionEvent, 'seq'>): SessionEvent {
    const fullEvent = { ...event, seq: this.seq++ }
    this.events.push(fullEvent)
    this.emit('session/append', fullEvent)
    return fullEvent
  }
}
```

**关键设计**：

1. **Append-Only**：事件只能追加，不能修改或删除，保证历史完整性。

2. **Sequence Number**：每个事件有唯一序列号，支持增量同步。

3. **Snapshot & Resume**：快照可以序列化为JSON，恢复时重建完整状态。

4. **Fork Support**：`fork()`复制历史前缀，创建新的会话分支。

---

## 四、映射：理论到实践的统一

Cordis论文提出的五大核心概念，在DeepSeek Harness中得到了完整的工程实现：

| 理论概念 | dsh实现 | 关键文件 |
|---------|---------|---------|
| 可逆效应 | Fiber + DisposableList | `vendor/cordis/src/fiber.ts` |
| 响应式协效应 | Events + Context Filter | `vendor/cordis/src/events.ts` |
| 上下文范式 | Scope + scopeTarget | `packages/core/scope/src/index.ts` |
| 动态组合演算 | Registry + Plugin | `vendor/cordis/src/registry.ts` |
| 结构化效果 | Tool Calls + Session | `packages/core/agent-loop/src/tool-calls.ts` |

这不是简单的"参考论文实现"，而是真正理解了理论精髓后的工程化表达。每一个设计决策背后都有理论支撑，每一个优化都有明确的数学基础。

---

## 五、悟

读完此文与此代码，有三悟：

**其一，抽象之力量。** 效应与协效应本为静态分析工具，作者将其提升为运行时机制，赋予动态组合之形式基础。此乃**从静态到动态之范式跃迁**。

**其二，逆操作之妙。** 可逆效应之精髓，在于每个副作用携带逆操作，运行时累积之。卸载时应用累积逆操作，即可恢复环境。Fiber的DisposableList正是此思想的工程实现——LIFO清理，确保资源释放顺序与分配顺序相反。

**其三，响应式之智。** 协效应本为静态标注，作者将其变为响应式依赖规范。上下文变化时，运行时分类并通知相关组件。Events的五种调度模式与Context Filter机制，让响应式协效应在实践中灵活而高效。

正如论文所言：**"形式化不是为了证明正确性，而是为了指导设计。"** DeepSeek Harness证明了这一点——当理论足够深刻时，它可以自然地演化为优雅的工程实践。

---

## 结语

此文先解Cordis理论，再析DeepSeek Harness源码，揭示可逆效应、响应式协效应如何落地为生产级框架。

理论与实践，本为一体两面。理论提供形式基础，实践验证理论价值。二者相辅，方得大道。

吾辈研此，当思：**静态分析之工具，如何提升为运行时机制？形式基础如何指导工程实践？** 此乃理论与实践交汇之处，值得深究。

---

*丙午年七月初九，于钱塘江畔*
