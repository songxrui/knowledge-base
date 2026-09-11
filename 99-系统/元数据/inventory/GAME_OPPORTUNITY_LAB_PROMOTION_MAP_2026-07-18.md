# Game Opportunity Lab 文件提升映射

> 建立日期：2026-07-18  
> 状态：promoted-verified

## 映射

| 原路径 | 目标路径 | 字节数 | SHA-256 | 状态 |
|---|---|---:|---|---|
| `01-项目/game-opportunity-lab/00-缓冲区/开发过程/simulation/run.mjs` | `01-项目/game-opportunity-lab/simulation/run.mjs` | 9012 | `A2D9F526BF7B8F43CF87170ACD39EF3DCEF5EB094626F805FD2D4F01E879E9B6` | promoted-verified |
| `01-项目/game-opportunity-lab/00-缓冲区/开发过程/simulation/solver.mjs` | `01-项目/game-opportunity-lab/simulation/solver.mjs` | 16558 | `27B035F9EE9AC4019790010917C770130D3A6FF7CB6C40BB4C3399D0D30219B3` | promoted-verified |

## 验收条件

- [x] 两个目标文件哈希与本表一致。
- [x] 原 simulation 缓冲目录不再存在。
- [x] `package.json`、测试和文档只引用正式路径。
- [x] `npm test` 失败数为0。
