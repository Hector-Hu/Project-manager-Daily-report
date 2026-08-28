# AI 项目管理日报/周报系统

通过 **Jira / Confluence 多源采集 + Deepseek LLM 智能生成 + SMTP 邮件发送**，自动化完成项目日报/周报的生成与分发，解放 PM 生产力。

---

## 功能特性

| 模块 | 能力 |
|------|------|
| **多源采集** | Jira / Confluence（复用 `atlassian-python-api`），统一标准化数据模型 |
| **AI 生成** | Deepseek LLM（摘要/归纳/风险识别）+ 审阅 Agent 打分 |
| **模板可配置** | 内置日报/周报模板，支持 API/文件自定义，按项目配置 |
| **定时与触发** | 每日/每周定时（APScheduler）+ API/CLI 手动触发 |
| **多渠道发送** | SenderAdapter 抽象 + SenderFactory 工厂，首期 SMTP，可扩展 Webhook/Slack |
| **HTML 邮件样式** | 对齐 SEC 智服参考图：KPI 仪表板 + Jira 进展表（状态徽章/优先级/风险天数高亮） |
| **质量报表模板** | 四类报表（Block问题/Coverity/Feature_DI汇总/DI值汇总），对齐中国区质量报表样式 |
| **历史归档** | SQLite 结构化存储 + Markdown/HTML 文件输出，多条件检索 |
| **skill 复用** | SkillBridge 桥接 tc8000-daily-report skill（可选） |

---

## 技术选型

| 工具 | 说明 |
|------|------|
| Jira API / Confluence API | 数据源（`atlassian-python-api`） |
| Deepseek | AI 能力（摘要、归纳、风险识别） |
| SMTP | 发送通道（adapter 化） |
| tc8000-daily-report skill | 复用报告生成逻辑（SkillBridge） |
| FastAPI / VScode | Web 服务 / 开发工具 |

---

## 快速开始

```bash
cd ai_report

# 1. 安装依赖
pip install -r requirements.txt

# 2. 配置 .env（Deepseek / Jira / SMTP，未配置则用模拟数据）
cp .env.example .env

# 3. 初始化数据库
python run.py --init-db

# 4. 启动 Web 服务（Swagger UI: http://localhost:8000/docs）
python run.py

# 5. 手动生成报告
python run.py --daily     # 日报
python run.py --weekly    # 周报

# 6. 运行测试
python -m pytest tests/ -v
```

---

## 目录结构

```
ai_report/
├── run.py                  # 启动入口
├── requirements.txt        # 依赖
├── pytest.ini              # 测试配置
├── .env.example            # 环境变量模板
├── src/
│   ├── config.py           # 配置中心
│   ├── models.py           # ORM 模型
│   ├── collectors.py       # Jira/Confluence 采集器
│   ├── generator.py        # Deepseek 生成 + 审阅 Agent
│   ├── templates.py        # Jinja2 模板引擎
│   ├── senders/            # 发送通道适配器
│   │   ├── base.py         #   SenderAdapter 抽象
│   │   ├── email_adapter.py#   EmailAdapter (SMTP)
│   │   └── __init__.py     #   SenderFactory 工厂
│   ├── skill_bridge.py     # tc8000 skill 桥接
│   ├── scheduler.py        # 定时调度
│   ├── storage.py          # 存储与查询
│   └── api.py              # FastAPI 接口
├── tests/                  # 55 个测试用例
├── docs/                   # 需求/部署/测试/用户手册
└── output/reports/         # 生成报告输出
```

---

## MCP Agent 周报工具（mini-harness 架构）

基于 **Mini-Harness MCP Agent 脚手架架构**（四层防线：Rules → Skills → Agents + Handoff → Scripts）开发的自包含 Agent 工具，自动化完成日报/周报的采集、生成、审阅、发送、归档：

```bash
cd tools/weekly-report

# 全流程自动推进（周报/日报）
python run.py run --type weekly --project PROJ
python run.py run --type daily --project PROJ

# 分步执行
python run.py collect --project PROJ
python run.py generate --type weekly
python run.py review
python run.py send --project PROJ
python run.py archive
python run.py status

# 运行测试
python tests/test_state.py     # 状态机测试（9 用例）
python tests/test_verify.py    # 校验脚本测试（4 用例）
```

详见 `tools/weekly-report/README.md`

---

## 质量报表（Block/Coverity/Feature_DI/DI值汇总）

系统支持生成四种对齐中国区质量报表参考图样式的报表：

| 报表 | 说明 | 表头特征 |
|------|------|----------|
| **Block 问题** | 部门 × Block 问题分布 | 未解决/待回归分组 + ASSIGNED/SCCB 等状态列 |
| **Coverity** | 部门 × 静态扫描 | S/A 等级问题数与解决率，100% 高亮 |
| **Feature DI 汇总** | Feature × DI 流转 | Assigned/Ready to Test/待回归/已关闭 DI |
| **DI 值汇总** | 接口人 × DI 值 | OpenDI/总DI/标准DI/解决率 + 部门小计 |

### 生成报表

```bash
# API 方式
curl -X POST http://localhost:8000/api/reports/metric \
  -H "Content-Type: application/json" \
  -d '{"report_type":"block","project_key":"PROJ","period":"2026-08"}'
# report_type 可选: block | coverity | feature_di | di_summary
```

### 数据源说明

- 当前从 Jira 自定义字段映射 DI/SCCB/Coverity 指标（未配置时回退示例数据）
- 已预留外部 DI/Coverity 平台 API Key 接口（`.env` 中 `DI_API_URL/DI_API_KEY/COVERITY_API_URL/COVERITY_API_KEY`），配置 `METRIC_SOURCE=external` 后走真实数据源
- 示例报表生成：`python scripts/generate_metric_samples.py`（输出到 `output/metric_samples/`）

---

## 文档索引

| 文档 | 内容 |
|------|------|
| `docs/FR_SPECIFICATION.md` | 需求规格说明书 + 数据字典 |
| `docs/DATA_SOURCE_CONFIG.md` | Jira/Confluence 对接配置 |
| `docs/DEPLOYMENT.md` | 部署 + 运维手册 |
| `docs/USER_MANUAL.md` | 用户手册 + 模板配置指引 |
| `docs/TEST_PLAN.md` | 测试方案与用例 |
| `docs/TC8000_SKILL_INTEGRATION.md` | skill 对接说明 |
| `docs/SENDER_ADAPTER_GUIDE.md` | 发送通道扩展指南 |
| `docs/samples/` | 样例日报 / 周报 |
| `tools/weekly-report/README.md` | MCP Agent 周报工具说明 |
