#!/usr/bin/env bash
#
# sdd-pipeline 系統需求檢查腳本
#
# 用法：
#   ./check-requirements.sh
#   curl -fsSL https://raw.githubusercontent.com/flamerecca/sdd-pipeline/main/check-requirements.sh | bash

set -euo pipefail

PASS=0
FAIL=0

ok() {
  echo "  ✓ $1"
  PASS=$((PASS + 1))
}

missing() {
  echo "  ✗ $1"
  FAIL=$((FAIL + 1))
}

check_command_version() {
  local name="$1"
  local cmd="$2"
  local version_flag="$3"
  local hint="$4"

  if command -v "$cmd" >/dev/null 2>&1; then
    local version
    version="$("$cmd" "$version_flag" 2>/dev/null | head -n 1)"
    ok "$name 已安裝：$version"
  else
    missing "$name 未安裝。$hint"
  fi
}

echo "檢查 sdd-pipeline 系統需求..."
echo

echo "[方式一／方式三共用需求] git 與 Bash"
check_command_version "git" "git" "--version" "方式一與方式三都需要用 git clone 抓取套件內容，請先安裝 git。"

if [ -n "${BASH_VERSION:-}" ]; then
  ok "Bash 已安裝，版本：$BASH_VERSION"
else
  missing "找不到 Bash，方式三的一鍵安裝指令需要 Bash 才能執行。"
fi
echo

echo "[方式三額外需求] curl"
check_command_version "curl" "curl" "--version" "方式三用 curl 下載 install.sh，請先安裝 curl，或改用方式一手動複製。"
echo

echo "[四大步驟共用需求] Node.js 與 npx"
check_command_version "Node.js" "node" "--version" "Mocking、Spectral Lint、SDK/Stub 生成都是透過 npx 執行對應套件，請先安裝 Node.js。"
check_command_version "npx" "npx" "--version" "npx 隨 Node.js 一起安裝，若已安裝 Node.js 仍看到這則訊息，請確認 Node.js 版本是否過舊。"
echo

echo "[Claude Code 版本需求，需自行確認]"
if command -v claude >/dev/null 2>&1; then
  ok "找到 claude 指令列工具：$(claude --version 2>/dev/null | head -n 1)"
else
  echo "  ! 找不到 claude 指令列工具，無法自動判斷是否支援 Skill、Agent 與 Plugin Marketplace。"
fi
echo "  提醒：是否支援 Skill、Agent 與方式二的 Plugin Marketplace，仍須依 Claude Code 官方文件人工確認版本。"
echo

echo "檢查結果：$PASS 項通過，$FAIL 項未通過。"

if [ "$FAIL" -eq 0 ]; then
  echo "系統需求已滿足，可依 README 選擇安裝方式。"
  exit 0
else
  echo "尚有未滿足的系統需求，請參考上方提示補齊後再安裝。"
  exit 1
fi
