## 5.0.0

### Breaking Changes

- 完全重构了API，将函数式风格改为面向对象风格
- 主要操作现在是Router类的方法，而不是独立函数
- 移除了导出的操作函数，如addRoute，findRoute等

### 新增功能

- 引入了Router类作为主要入口点
- 提供更简洁的链式API
- 内部实现优化，代码结构更清晰

### 迁移指南

从v4.x迁移到v5.0.0:

```diff
import 'package:routingkit/routingkit.dart';

- const router = createRouter();
+ final router = createRouter<String>();

- addRoute(router, 'get', '/path', 'data');
+ router.add('get', '/path', 'data');

- findRoute(router, 'get', '/path');
+ router.find('get', '/path');

- findAllRoutes(router, 'get', '/path');
+ router.findAll('get', '/path');

- removeRoute(router, 'get', '/path');
+ router.remove('get', '/path');
```

## 4.1.1

- **fix**: fix: remove named wildcard routes
- **chrome**: bump lints from 4.0.0 to 5.1.0

## v4.1.0

- **feat**: Support nullable method.

## v4.0.0

[compare changes](https://github.com/medz/routingkit/compare/v3.0.3...v4.0.0)

### 🩹 Fixes

- Find all ([7d1e06b](https://github.com/medz/routingkit/commit/7d1e06b))

### 💅 Refactors

- Done ([245ff49](https://github.com/medz/routingkit/commit/245ff49))

### ✅ Tests

- - ([1fbcb5c](https://github.com/medz/routingkit/commit/1fbcb5c))

### ❤️ Contributors

- Seven Du <shiweidu@outlook.com>
