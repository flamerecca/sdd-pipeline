# OpenAPI 3.1 契約設計與 Linter 指南 (OpenAPI Design Guide)

本文件提供 OpenAPI 3.1 YAML 契約設計範本與 Spectral Linter 配置。

---

## 1. OpenAPI 3.1 YAML 範例 (`openapi.yaml`)

```yaml
openapi: 3.1.0
info:
  title: 使用者管理 API (User Service API)
  version: 1.0.0
  description: 規格驅動開發 (SDD) 標準使用者 API 契約

paths:
  /api/v1/users/{id}:
    get:
      summary: 根據 ID 查詢使用者資料
      operationId: getUserById
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: 成功回傳使用者物件
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: 找不到該使用者

components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
          example: 101
        name:
          type: string
          example: "Recca Chao"
        email:
          type: string
          format: email
          example: "recca@example.com"
```

---

## 2. 使用 Spectral 進行規格 Linting

在 CI/CD 中驗證 `openapi.yaml` 是否符合團隊設計規範：

```bash
npx @stoplight/spectral-cli lint openapi.yaml
```
