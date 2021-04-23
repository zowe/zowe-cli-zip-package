#!/usr/bin/env bash
###
# This program and the accompanying materials are made available under the terms of the
# Eclipse Public License v2.0 which accompanies this distribution, and is available at
# https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright Contributors to the Zowe Project.
#
###

zoweVersion=$1
imperativeVersion=$2
cliVersion=$3

mkdir -p node-sdk
cd node-sdk

git clone -b v${imperativeVersion} --depth 1 https://github.com/zowe/imperative.git
git clone -b v${cliVersion} --depth 1 https://github.com/zowe/zowe-cli.git

npm init -y
npm install --save-dev @types/node typescript@^3.8.0 typedoc@^0.19.0 \
  @strictsoftware/typedoc-plugin-monorepo typedoc-plugin-sourcefile-url

mkdir -p node_modules/@zowe/imperative
mv imperative/{packages,README.md} node_modules/@zowe/imperative/
mv zowe-cli/packages/core node_modules/@zowe/core-for-zowe-sdk
mv zowe-cli/packages/provisioning node_modules/@zowe/provisioning-for-zowe-sdk
mv zowe-cli/packages/zosconsole node_modules/@zowe/zos-console-for-zowe-sdk
mv zowe-cli/packages/zosfiles node_modules/@zowe/zos-files-for-zowe-sdk
mv zowe-cli/packages/zosjobs node_modules/@zowe/zos-jobs-for-zowe-sdk
mv zowe-cli/packages/zostso node_modules/@zowe/zos-tso-for-zowe-sdk
mv zowe-cli/packages/zosuss node_modules/@zowe/zos-uss-for-zowe-sdk
mv zowe-cli/packages/workflows node_modules/@zowe/zos-workflows-for-zowe-sdk
mv zowe-cli/packages/zosmf node_modules/@zowe/zosmf-for-zowe-sdk

cat > sourcefile-map.json << EOF
[
  {
    "pattern": "^@zowe/imperative",
    "replace": "https://github.com/zowe/imperative/blob/v$imperativeVersion"
  },
  {
    "pattern": "^@zowe/core-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/core"
  },
  {
    "pattern": "^@zowe/provisioning-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/provisioning"
  },
  {
    "pattern": "^@zowe/zos-console-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/zosconsole"
  },
  {
    "pattern": "^@zowe/zos-files-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/zosfiles"
  },
  {
    "pattern": "^@zowe/zos-jobs-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/zosjobs"
  },
  {
    "pattern": "^@zowe/zos-tso-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/zostso"
  },
  {
    "pattern": "^@zowe/zos-uss-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/zosuss"
  },
  {
    "pattern": "^@zowe/zos-workflows-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/workflows"
  },
  {
    "pattern": "^@zowe/zosmf-for-zowe-sdk",
    "replace": "https://github.com/zowe/zowe-cli/blob/v${cliVersion}/packages/zosmf"
  }
]
EOF

cat > typedoc.json << EOF
{
  "disableOutputCheck": true,
  "exclude": [
    "**/__tests__/**",
    "**/node_modules/**/node_modules",
    "**/index.ts"
  ],
  "excludeNotExported": true,
  "ignoreCompilerErrors": true,
  "name": "Zowe Node.js SDK - v$zoweVersion",
  "out": "typedoc",
  "readme": "zowe-cli/README.md",
  "external-modulemap": ".*(@zowe\/[^\/]+)\/.*",
  "sourcefile-url-map": "sourcefile-map.json"
}
EOF

npx typedoc ./node_modules/@zowe
zip ../zowe-node-sdk-typedoc.zip typedoc
