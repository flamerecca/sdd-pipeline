---
name: sdd-pipeline
description: >-
  當使用者要實際執行規格驅動開發 SDD 完整工作流程，包含設計 OpenAPI 3.1 契約、啟動 Mock Server 讓前後端平行開發、生成 SDK 或 Server Stub、執行契約測試並偵測規格漂移，或要求依 Spec-First 流程開發一個新 API 時使用此 Skill。語法教學、YAML 範本與驗收規格範本請改用 spec-driven-development Skill。
---

# SDD 工作流程執行 Skill (SDD Pipeline)

本 Skill 是規格驅動開發 Spec-Driven Development / SDD 四大步驟的**執行版**，負責實際跑一遍流程並在關鍵步驟委派專門的 Agent。`spec-driven-development` Skill 是**教學版**，提供概念說明、OpenAPI 語法範本、Spectral／Prism／openapi-generator 指令範例與情境／操作／驗證 (Arrange-Act-Assert) 驗收規格範本；本 Skill 遇到語法細節時直接引用該 Skill 的 references，不重複寫一份。

兩者分工：語法怎麼寫，看 `spec-driven-development`；這次要不要走完整流程、由誰做、做完怎麼判斷過關，看本 Skill。

---

## SDD 四大步驟與執行者

```
Step 1 設計 OpenAPI 契約   → 委派 openapi-contract-designer Agent
Step 2 Mocking             → 本 Skill 直接執行單一指令
Step 3 SDK / Stub 生成      → 本 Skill 直接執行單一指令
Step 4 契約測試與 CI 驗證    → 委派 contract-drift-auditor Agent 複核
```

Step 1 與 Step 4 需要判斷力與多輪修正，交給對應的 Agent，讓它們在乾淨的上下文裡專注把一件事做完；Step 2、Step 3 是單一 CLI 指令就能完成的機械操作，不需要動用 Agent，直接執行即可。

## 標準執行步驟 (SOP)

### 步驟 1：設計契約

呼叫 `openapi-contract-designer` Agent，交付使用者的 API 需求描述，或指向專案既有的 PRD / architecture 規格。等待該 Agent 產出規格檔案與 Spectral Lint 結果。

小範圍異動可以直接 inline 處理，不需要動用 Agent：只是修一個欄位的 `description` 文字、修正明顯的錯字、調整 `example` 值。凡是牽動 Schema 結構、新增或刪除 Endpoint、變更必填欄位，一律走 Agent，因為這類變更值得完整走一遍步驟 2 到 4 的釐清與修正流程。

### 步驟 2：啟動 Mock Server

規格產出後，立即啟動 Mock，讓前端不必等後端：

```bash
npx @stoplight/prism-cli mock <規格檔案路徑> -p 4010
```

告知使用者 Mock Server 的位置與可以開始對接的 Endpoint 清單。詳細行為與參數見 [spec-driven-development 的 contract-testing-mocking.md](../spec-driven-development/references/contract-testing-mocking.md)。

### 步驟 3：生成 SDK 或 Server Stub

依專案語言與框架選擇對應的 Generator，例如前端 TypeScript：

```bash
npx @openapitools/openapi-generator-cli generate \
  -i <規格檔案路徑> \
  -g typescript-fetch \
  -o <輸出目錄>
```

後端 Stub 依框架選擇對應的 Generator 種類。若專案已經有既定的輸出目錄或 Generator 設定，沿用既有慣例，不要另立一套。

### 步驟 4：契約測試與 CI 驗證

- 若專案已有契約測試工具鏈，先直接執行既有測試指令。
- 若尚未有契約測試，依 [spec-driven-development 的 contract-testing-mocking.md](../spec-driven-development/references/contract-testing-mocking.md) 的範本建立最小可行的一組。
- 接著呼叫 `contract-drift-auditor` Agent 進行複核，交付規格檔案路徑與比對來源（執行中的 API Base URL 或既有契約測試指令）。
- 該 Agent 只會回報落差，不會修改任何檔案。落差牽涉規格需要更新時，回到步驟 1 重新呼叫 `openapi-contract-designer`；落差是實作有誤時，交還實作者修正後重新跑步驟 4。

### 步驟 5：收尾

確認以下三件事都成立才算這一輪 SDD 流程完成：

- 規格已通過 Spectral Lint。
- Mock Server 或既有的真實服務可正常回應規格宣告的 Endpoint。
- 契約測試通過，或所有回報的落差都已交還對應角色處理並有明確去向。

---

## 何時整套流程可以省略

- 只是本地一次性除錯、不涉及對外契約、不會有其他團隊依賴這份規格的情況，不需要走完整四步驟，直接讓使用者確認是否真的需要 Spec-First。
- 專案規模非常小、只有單一 Consumer 且前後端由同一個人開發時，Mocking 與 SDK 生成帶來的價值有限，可以只做 Step 1 與 Step 4，省略 Step 2、Step 3，並向使用者說明省略的原因。

## 防雷守則

1. **不要把 Step 1 和 Step 4 的 Agent 產出的內容再自己重寫一遍**：兩個 Agent 各自的職責邊界寫得很清楚，只找問題或只產出規格，尊重它們的輸出，需要修改時透過重新呼叫該 Agent，而不是繞過它自己動手改。
2. **不要在規格還沒過 Lint 前就進入 Mocking 或 SDK 生成**：Prism 與 openapi-generator 對不合法的 YAML 容錯度不一，規格有問題時後面兩步只會產生更難追的錯誤。
3. **不要把契約測試失敗直接當成程式碼 Bug 處理**：先讓 `contract-drift-auditor` 判斷落差是規格該更新還是實作有誤，兩者的修正路徑完全不同。
4. **CI 整合**：Step 4 的驗證邏輯最終應該收斂成 CI 流水線裡的一個步驟，本 Skill 協助的是本地開發階段先跑過一輪，確保進 CI 前不會頻繁失敗，不是取代 CI。
5. **預設語言**：繁體中文，OpenAPI 語法與 YAML 欄位保留原本格式，與 `spec-driven-development` Skill 一致。
