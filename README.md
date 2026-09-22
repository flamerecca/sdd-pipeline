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
| **spec-driven-development** | 教學版，提供 OpenAPI 3.1 語法範本、Mocking 與契約測試指令範例、BDD Gherkin 範本；`sdd-pipeline` Skill 遇到語法細節時會直接引用這裡的內容，不重複維護一份。 |

### Agent

| 名稱 | 用途 |
| :--- | :--- |
| **openapi-contract-designer** | 依 API 需求描述、既有 PRD 或 architecture 規格，設計並精修 OpenAPI 3.1 契約，執行 Spectral Linting 直到規格乾淨為止。只產出規格，不實作程式碼、不生成 SDK、不啟動 Mock Server。 |
| **contract-drift-auditor** | 比對 OpenAPI 規格與真實運作中的 API 或既有契約測試結果，找出規格漂移，即實際行為與規格宣告不一致之處。只回報落差、不修改任何規格或程式碼，落差交還使用者判斷該修規格還是修實作。 |

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

## 使用時機

要依 Spec-First 流程開發一個新 API，包含設計 OpenAPI 3.1 契約、啟動 Mock Server 讓前後端平行開發、生成 SDK 或 Server Stub、執行契約測試並偵測規格漂移時，直接在對話中提出需求，Claude Code 會自動判斷套用 `sdd-pipeline` Skill。

只是要查 OpenAPI 語法、YAML 範本或 BDD Gherkin 範本，屬於教學情境，會改用 `spec-driven-development` Skill，兩者分工詳見 `skills/sdd-pipeline/SKILL.md` 開頭的說明。

## 授權

MIT License，詳見 [LICENSE](./LICENSE)。
