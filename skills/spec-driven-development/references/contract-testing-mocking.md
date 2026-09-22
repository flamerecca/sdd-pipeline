# API Mocking、SDK 自動生成與契約測試指南 (Mocking & Contract Testing)

本文件提供 Prism Mock Server 啟動、SDK 自動生成與契約測試對照。

---

## 1. 啟動 Prism Mock API 伺服器

前端工程師在無後端情況下，一條指令啟動強大且帶有 Schema 驗證的 Mock API：

```bash
npx @stoplight/prism-cli mock openapi.yaml -p 4010
```

* 前端呼叫 `http://localhost:4010/api/v1/users/101`，Prism 會根據 `openapi.yaml` 自動回傳符合 Schema 的測試資料。

---

## 2. 自動生成 TypeScript API Client SDK

從 `openapi.yaml` 一鍵生成帶型別提示的 SDK，如使用 openapi-generator：

```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-fetch \
  -o ./src/api-client
```

---

## 3. 契約測試 (Contract Testing) 防止規格漂移

在 CI 中驗證真實運行的後端 API Response 是否 100% 符合 `openapi.yaml` 宣告：

```javascript
// 使用 Jest / Vitest + openapi-validator 進行契約測試
import { matchApiSchema } from 'jest-openapi';

describe('GET /api/v1/users/101', () => {
  it('should conform to OpenAPI spec', async () => {
    const res = await fetch('http://localhost:8080/api/v1/users/101');
    expect(res).toSatisfyApiSpec(); // 驗證實體 API 與 Spec 是否完全一致！
  });
});
```
