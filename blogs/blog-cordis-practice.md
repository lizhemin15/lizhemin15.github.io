---
title: "Cordis 范式实战：DeepSeek Harness 如何将理论落地为生产级 AI Agent 框架"
date: 2026-08-26
tags: [cordis, agent-framework, architecture, deepseek]
keywords: [Cordis, 可逆效应, 响应式协效应, 上下文范式, AI Agent, DeepSeek Harness]
excerpt: "Cordis 论文提出了一套优雅的理论框架，但理论如何落地？本文深入剖析 DeepSeek Harness 的源码，揭示 Cordis 五大核心概念如何在生产环境中被实现——从 Context 的服务注册到 Fiber 的可逆生命周期，从 Events 的响应式调度到 Scope 的隔离路由。"
visible: true
pinned: false
---

# Cordis 范式实战：DeepSeek Harness 如何将理论落地为生产级 AI Agent 框架

> **缘起**

上一篇《Cordis 范式解读》我们梳理了论文的理论脉络。但理论终究是纸上谈兵——可逆效应如何实现？响应式协效应如何调度？上下文范式如何保证隔离？

今天，我们走进 DeepSeek Harness 的源码，看看这套理论如何被工程化为一个支撑百万级 Agent 并发的生产框架。

---

## 一、Context：服务注册与依赖注入的中枢

### 论文思想

Cordis 将 Context 定义为"动态组合演算"的载体——所有服务、插件、事件都通过 Context 进行组合。Context 不是静态容器，而是随 Fiber 生命周期动态变化的代理对象。

### dsh 实现

```typescript
// vendor/cordis/src/context.ts
export class Context {
  readonly fiber: Fiber
  readonly events: EventsService
  readonly reflect: ReflectService
  readonly registry: RegistryService
  // ...
}
```

**关键设计**：

1. **Context 是 Proxy**：通过 `ReflectService.handler` 实现属性拦截，任何未显式声明的属性访问都会触发服务解析逻辑。

2. **继承链**：`ctx.extend()` 创建子上下文，继承父上下文的所有服务，但可以覆盖特定服务。这实现了论文中的"嵌套上下文"。

3. **Fiber 绑定**：每个 Context 绑定一个 Fiber，Fiber 的状态决定了 Context 的可用性。当 Fiber 进入 UNLOADING 状态时，Context 上的服务会自动失效。

**实践意义**：

- Agent 的 scoped context 通过 `createScope(loopCtx, this)` 创建，每个 Agent 拥有独立的服务视图
- 工具注册、事件监听、配置读取都通过 Context 进行，天然支持隔离

---

## 二、Fiber：可逆效应的执行单元

### 论文思想

可逆效应（Reversible Effects）要求副作用可以被撤销。Fiber 是 Cordis 中承载副作用的最小单元——它记录了所有注册的服务、监听的事件，并在销毁时反向执行这些操作。

### dsh 实现

```typescript
// vendor/cordis/src/fiber.ts
export class Fiber<T = any> extends Promise<T> {
  state: FiberState = FiberState.PENDING
  private disposers: DisposableList = new DisposableList()
  private hooks: Record<string, DisposableList> = {}
  
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

1. **DisposableList**：使用双向链表管理清理函数，确保注册顺序与销毁顺序相反（LIFO）。

2. **状态机**：`PENDING → RUNNING → SETTLED → UNLOADING → DISPOSED`，状态转换严格控制，防止重复销毁。

3. **Inertia**：`fiber.inertia` 允许异步清理完成后继续等待，确保所有派生资源都已释放。

**实践意义**：

- Agent 的 scoped context 对应一个 Fiber，Agent 销毁时自动清理所有注册的工具、事件监听、子插件
- 工具执行的 pre/post 钩子也通过 Fiber 管理，确保异常情况下也能正确清理

---

## 三、Events：响应式协效应的调度引擎

### 论文思想

响应式协效应（Reactive Coeffects）要求系统能够感知环境变化并做出响应。Events 是 Cordis 中实现响应式的核心——监听器随 Fiber 自动注册和销毁，事件分发支持多种策略。

### dsh 实现

```typescript
// vendor/cordis/src/events.ts
export type DispatchMode = 'emit' | 'parallel' | 'serial' | 'bail' | 'waterfall'

export class EventsService {
  _hooks: Record<keyof any, Hook[]> = {}
  
  dispatch(type: string, args: any[]) {
    const thisArg = typeof args[0] === 'object' ? args.shift() : null
    const name = args.shift()
    const filter = thisArg?.[Context.filter]
    return this._hooks[name]
      .filter(hook => hook.global || !filter || filter.call(thisArg, hook.ctx))
      .map(hook => hook.callback.bind(thisArg))
  }
}
```

**关键设计**：

1. **五种调度模式**：
   - `emit`：同步执行，不等待结果
   - `parallel`：并发执行，等待全部完成
   - `serial`：顺序执行，遇到 bail 值停止
   - `bail`：同步执行，返回第一个非空值
   - `waterfall`：洋葱模型，支持 next() 委托

2. **Context Filter**：通过 `thisArg[Context.filter]` 实现事件过滤。这是 dsh-scope 包的核心机制。

3. **Listener Auto-dispose**：监听器注册在当前 Fiber 上，Fiber 销毁时自动移除。

**实践意义**：

- 工具执行管道：`tools/pre-execute → tools/execute → tools/post-execute` 使用 waterfall 模式，支持权限检查、超时重试、结果替换
- Agent 状态变更：`agent/status` 使用 emit 模式，UI 层可以实时响应
- 会话事件：`turn/start`、`step/end` 等事件驱动 UI 更新

---

## 四、Scope：上下文隔离与事件路由

### 论文思想

上下文范式要求不同 Agent 的环境相互隔离，但有时需要向上传播事件（如监控组件观察多个 Agent）。Scope 实现了这种"向下继承、向上传播"的层级关系。

### dsh 实现

```typescript
// packages/core/scope/src/index.ts
export function createScope(ctx: Context, key: ScopeKey): Scope {
  const fiber = ctx.plugin(scope)
  const scoped: Context = fiber.ctx.extend({ [kScope]: key })
  return {
    ctx: scoped,
    rawDispose: fiber.dispose,
    dispose: () => quiesceFiber(fiber),
  }
}

export function scopeTarget<T>(base: T, key: ScopeKey): Scoped<T> {
  return {
    [Context.filter](ctx: Context): boolean {
      const tag = scopeOf(ctx)
      if (tag === undefined) return true
      // 事件向上传播：监听者可以接收后代 scope 的事件
      for (let cursor = key; cursor !== undefined; cursor = scopeParents.get(cursor)) {
        if (cursor === tag) return true
      }
      return false
    },
  }
}
```

**关键设计**：

1. **Scope Key**：每个 Scope 有一个唯一的 opaque identity，用于事件路由。

2. **Parent Link**：`scopeParents` WeakMap 维护父子关系，支持 cycle check。

3. **Event Routing**：`scopeTarget` 构建的 carrier 只匹配当前 scope 或其祖先 scope 的监听器。

**实践意义**：

- 每个 Agent 有自己的 scope，工具注册、事件监听都限定在该 scope 内
- 监控组件可以监听所有 Agent 的事件（因为它属于 root scope）
- 工具调用的 `exec.agent` 字段确保事件只路由到正确的 Agent

---

## 五、Registry：插件系统的动态组合

### 论文思想

动态组合演算要求系统能够在运行时加载、卸载、替换插件。Registry 是 Cordis 中管理插件生命周期的核心。

### dsh 实现

```typescript
// vendor/cordis/src/registry.ts
export type Plugin<T = any> =
  | Plugin.Function<T>
  | Plugin.Constructor<T>
  | Plugin.Object<T>

export interface Plugin.Runtime {
  name?: string
  fibers: DisposableList<Fiber>
  callback: globalThis.Function
  Config?: StandardSchemaV1
}

export class RegistryService {
  private _internal = new Map<Function, Plugin.Runtime>()
  
  plugin<P extends Plugin>(plugin: P, ...args: any[]): Fiber {
    const runtime = this._internal.get(plugin as Function) ?? this.register(plugin)
    const fiber = runtime.fibers.push(new Fiber())
    // ... 执行插件
    return fiber
  }
}
```

**关键设计**：

1. **三种插件形态**：函数、类、对象（带 apply 方法），满足不同复杂度需求。

2. **Config Validation**：通过 Standard Schema 验证配置，在插件启动前捕获错误。

3. **Dependency Injection**：`plugin.inject` 声明依赖的服务，Registry 自动等待这些服务就绪。

**实践意义**：

- Agent Loop 是一个大型插件，负责创建和管理 Agent
- Tools 包也是一个插件，提供工具注册和执行管道
- System Prompt 包组装提示词，通过事件与其他模块协作

---

## 六、Tool Calls：工具调用的并发调度

### 论文思想

AI Agent 的核心能力是调用外部工具。Cordis 要求工具调用支持并发、取消、重试，并且结果必须有序提交给模型。

### dsh 实现

```typescript
// packages/core/agent-loop/src/tool-calls.ts
export async function executeToolCalls(
  ctx: Context, turn: number, step: number,
  toolCalls: ToolCallBlock[], signal: AbortSignal,
  acceptContext: (context: UserMessage) => void,
): Promise<{ concluded: boolean }> {
  const planned = toolCalls.map(block => ({
    block,
    exec: { callId: block.id, name: block.name, arguments: parseArguments(block.arguments), agent, signal },
  }))
  
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
}
```

**关键设计**：

1. **并发模式分类**：`executionMode()` 根据工具声明决定并发策略（exclusive vs parallel）。

2. **Bounded Pool**：并行调用使用有界池，`maxParallelToolCalls` 限制同时执行的调用数。

3. **Ordered Commit**：即使并发执行，结果也按模型顺序提交，确保日志一致性。

4. **Abort Handling**：取消时记录合成错误结果，保证重放有效性。

**实践意义**：

- 多个文件读写可以并行执行，提升效率
- 网络请求可以设置超时，避免长时间阻塞
- 用户可以中途取消，系统优雅处理已开始的调用

---

## 七、Session：会话持久化的不可变日志

### 论文思想

会话历史是 AI Agent 的核心状态。Cordis 要求会话日志是不可变的，支持 fork 和 resume，并且能够序列化为 JSON。

### dsh 实现

```typescript
// packages/core/session/src/index.ts
export interface SessionEvent {
  type: string
  data: any
  seq: number
}

export class Session {
  readonly id: SessionId
  private events: SessionEvent[] = []
  private seq = 0
  
  append(event: Omit<SessionEvent, 'seq'>): SessionEvent {
    const fullEvent = { ...event, seq: this.seq++ }
    this.events.push(fullEvent)
    this.emit('session/append', fullEvent)
    return fullEvent
  }
  
  snapshot(): SessionSnapshot {
    return {
      header: { id: this.id, createdAt: this.createdAt, seedLength: this.seedLength },
      events: structuredClone(this.events),
    }
  }
}
```

**关键设计**：

1. **Append-Only**：事件只能追加，不能修改或删除，保证历史完整性。

2. **Sequence Number**：每个事件有唯一序列号，支持增量同步。

3. **Snapshot & Resume**：快照可以序列化为 JSON，恢复时重建完整状态。

4. **Fork Support**：`fork()` 复制历史前缀，创建新的会话分支。

**实践意义**：

- 会话可以持久化到数据库，支持断点续聊
- 多轮对话的历史可以完整回放
- fork 机制支持实验性探索，不影响主会话

---

## 八、结语：理论与实践的统一

Cordis 论文提出的五大核心概念——可逆效应、响应式协效应、上下文范式、动态组合演算、结构化效果——在 DeepSeek Harness 中得到了完整的工程实现：

| 理论概念 | dsh 实现 | 关键文件 |
|---------|---------|---------|
| 可逆效应 | Fiber + DisposableList | `vendor/cordis/src/fiber.ts` |
| 响应式协效应 | Events + Context Filter | `vendor/cordis/src/events.ts` |
| 上下文范式 | Scope + scopeTarget | `packages/core/scope/src/index.ts` |
| 动态组合演算 | Registry + Plugin | `vendor/cordis/src/registry.ts` |
| 结构化效果 | Tool Calls + Session | `packages/core/agent-loop/src/tool-calls.ts` |

这不是简单的"参考论文实现"，而是真正理解了理论精髓后的工程化表达。每一个设计决策背后都有理论支撑，每一个优化都有明确的数学基础。

正如论文所言："形式化不是为了证明正确性，而是为了指导设计。" DeepSeek Harness 证明了这一点——当理论足够深刻时，它可以自然地演化为优雅的工程实践。

---

*丙午年七月初九，于钱塘江畔*
