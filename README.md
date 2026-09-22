# sdd-pipeline

把「規格驅動開發」(Spec-Driven Development / SDD) 打包成 Claude Code 的 Skill 與 Agent，讓你在對話中直接跑完 OpenAPI 3.1 契約設計、Mock Server、SDK/Stub 生成、契約測試與規格漂移稽核的完整循環。

## 這個套件包含什麼

```
sdd-pipeline/
├── skills/
│   ├── sdd-pipeline/              執行版：實際跑一遍 SDD 四大步驟
│   └── spec-driven-development/   教學版：語法、範本與指令範例
└── agents/
    ├── openapi-contract-designer.md
    └── contract-drift-auditor.md
```

### Skill

| 名稱 | 用途 |
| :--- | :--- |
| **sdd-pipeline** | 執行版，負責實際跑一遍 SDD 四大步驟，並在關鍵步驟委派對應的 Agent 處理。 |
| **spec-driven-development** | 教學版，提供 OpenAPI 3.1 語法範本、Mocking 與契約測試指令範例、情境／操作／驗證 (Arrange-Act-Assert) 驗收規格範本；`sdd-pipeline` Skill 遇到語法細節時會直接引用這裡的內容，不重複維護一份。 |

### Agent

| 名稱 | 用途 |
| :--- | :--- |
| **openapi-contract-designer** | 依 API 需求描述、既有 PRD 或 architecture 規格，設計並精修 OpenAPI 3.1 契約，執行 Spectral Linting 直到規格乾淨為止。只產出規格，不實作程式碼、不生成 SDK、不啟動 Mock Server。 |
| **contract-drift-auditor** | 比對 OpenAPI 規格與真實運作中的 API 或既有契約測試結果，找出規格漂移，即實際行為與規格宣告不一致之處。只回報落差、不修改任何規格或程式碼，落差交還使用者判斷該修規格還是修實作。 |

## 系統需求

- 已安裝 Node.js 與 npx：四大步驟裡的 Mocking、Spectral Lint、SDK/Stub 生成都是透過 npx 執行對應套件，不需要事先手動安裝這些工具，但要有 Node.js 環境才能跑 npx。
- 支援 Skill 與 Agent 的 Claude Code 版本，才能讀取本套件裡的 SKILL.md 與 Agent 定義。
- 想用方式二的 Plugin 安裝，需要支援 Plugin Marketplace 的 Claude Code 版本；不確定版本是否支援時，改用方式一的手動複製即可。

## 安裝方式

### 方式一：手動複製，最簡單、保證可用

1. 把這個儲存庫 clone 下來。
2. 依你想套用的範圍，把 `skills/` 與 `agents/` 底下的資料夾複製到對應位置：
   - 全域套用：`~/.claude/skills/`、`~/.claude/agents/`
   - 單一專案套用：`<專案根目錄>/.claude/skills/`、`<專案根目錄>/.claude/agents/`

```bash
git clone https://github.com/flamerecca/sdd-pipeline.git
cp -R sdd-pipeline/skills/* ~/.claude/skills/
cp -R sdd-pipeline/agents/* ~/.claude/agents/
```

複製完成後重新啟動 Claude Code，即可在對話中直接呼叫 `sdd-pipeline` Skill，或讓 Claude Code 依情境自動叫用 `openapi-contract-designer`、`contract-drift-auditor` 這兩個 Agent。

### 方式二：作為 Claude Code Plugin 安裝

這個儲存庫本身就是一份 Marketplace，內含單一 Plugin `sdd-pipeline`，適合已經在用 Plugin 機制管理套件的使用者，在 Claude Code 對話中輸入：

```
/plugin marketplace add flamerecca/sdd-pipeline
/plugin install sdd-pipeline@sdd-pipeline
```

## 快速開始

安裝完成後，在 Claude Code 裡直接描述需求即可，不需要手動點名 Skill 或 Agent，例如：

> 幫我用 SDD 流程設計一個訂單 API，包含建立訂單、查詢訂單、取消訂單三個操作。

Claude Code 會依序：

1. 判斷這是完整的 Spec-First 開發需求，套用 `sdd-pipeline` Skill。
2. 呼叫 `openapi-contract-designer` Agent，產出一份通過 Spectral Lint 的 `openapi.yaml`。
3. 執行 `npx @stoplight/prism-cli mock openapi.yaml -p 4010`，啟動 Mock Server，讓你可以立刻用這個網址測試前端串接。
4. 依專案語言生成對應的 SDK 或 Server Stub。
5. 實作完成後，呼叫 `contract-drift-auditor` Agent 複核，回報規格與實際行為是否一致。

## 深入了解

想先搞懂 SDD 四大步驟本身在做什麼、每一步的目的與產出，再決定要不要安裝，可以看 [docs/sdd-four-steps.md](./docs/sdd-four-steps.md)。

## 延伸閱讀

`spec-driven-development` Skill 底下還有三份可以獨立閱讀的教材：

- [OpenAPI 3.1 契約設計指南](./skills/spec-driven-development/references/openapi-spec-design-guide.md)：Path、Schema、Components 設計慣例與 Spectral Linting。
- [Mocking 與契約測試指南](./skills/spec-driven-development/references/contract-testing-mocking.md)：Prism Mock Server、SDK 生成與契約測試工具鏈。
- [驗收規格範本](./skills/spec-driven-development/references/acceptance-spec-template.md)：情境／操作／驗證 (Arrange-Act-Assert) 格式的驗收規格寫法。

## 使用時機

要依 Spec-First 流程開發一個新 API，包含設計 OpenAPI 3.1 契約、啟動 Mock Server 讓前後端平行開發、生成 SDK 或 Server Stub、執行契約測試並偵測規格漂移時，直接在對話中提出需求，Claude Code 會自動判斷套用 `sdd-pipeline` Skill。

只是要查 OpenAPI 語法、YAML 範本或情境／操作／驗證驗收規格範本，屬於教學情境，會改用 `spec-driven-development` Skill，兩者分工詳見 `skills/sdd-pipeline/SKILL.md` 開頭的說明。

## 授權

MIT License，詳見 [LICENSE](./LICENSE)。
