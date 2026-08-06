# SIM卡增值服务(SimToolKits)

## 简介

SimToolKits（STK，包名：com.ohos.simtoolkits）是 OpenHarmony 电话子系统中预置的**SIM卡增值服务系统应用**，负责解析并处理 SIM 卡下发的主动式命令（Proactive Command），向用户展示菜单、文本、输入框、确认对话框等交互界面，并将用户操作结果以 Terminal Response / Envelope 形式回传给 Telephony 框架。

本应用为系统预置应用，支持单卡 / 双卡 / eSIM 场景，通常不在桌面显示图标，用户可通过「设置 → 移动网络 → SIM 卡管理 → SIM 应用程序」入口进入 STK 主菜单。

### 核心能力

**SIM卡信息展示**

- 支持展示 SIM 下发文本、空闲模式文本或刷新提示
- 支持播放提示音，并可选伴随文本弹窗
- 支持 BIP 确认 / 提示与回传
- 支持按 SIM 下发语言通知切换系统语言

**SIM卡信息交互**

- 支持主菜单与子菜单的展示、选择与回传
- 支持单字符 / 多字符输入与回传
- 支持呼叫建立确认（接受 / 拒绝）
- 支持确认后拉起系统浏览器
- 支持在设置中显隐 STK 应用程序入口

> **说明**：本仓定位为 STK **应用层**。命令解析、会话分发、Terminal Response 编码等基础能力位于公共层（`AppService中枢` / `upDecode解析` / `response编码` / `Worker`）。Modem / RIL 侧实际执行短信、补充业务、USSD、DTMF 等操作。


## 架构说明

SimToolKits 采用分层与模块化设计，按产品形态、业务特性与公共能力组织代码，并与电话子系统协同工作，如图：

![SimToolKits 部件与外部依赖](./docs/figures/simtoolkits_ipc.png)


### 应用层分层设计

整体可划分为产品层、特性层、公共层：

| 层次 | 主要目录 / 组件 | 说明 |
| ---- | -------------- | ---- |
| 产品层 | phone / pad | 支持手机、平板形态 |
| 特性层 | `pages`、`model/upDecode` | SIM卡信息展示、SIM卡信息交互 |
| 公共层 | `model/upDecode`、`model/responseData`、`model`（SimToolKitAppService）、`workers`、`common/helper`（EntranceHelper）、`common/utils`（NotificationUtils）、`common/helper`（CustTimeOutHelper） | UpDecode解析、response编码、AppService中枢、Worker、EntranceHelper、通知工具、超时保活 |

特性层模块说明：

<table>
  <thead>
    <tr>
      <th>核心能力</th>
      <th>模块与关键类</th>
      <th>说明</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="4">SIM卡信息展示</td>
      <td><code>model/upDecode</code>（DisplayTextParam、SetUpIdleModeTextParam）</td>
      <td>支持展示 SIM 下发文本、空闲模式文本或刷新提示</td>
    </tr>
    <tr>
      <td><code>model/upDecode</code>（PlayToneParam）</td>
      <td>支持播放提示音，并可选伴随文本弹窗</td>
    </tr>
    <tr>
      <td><code>pages</code>（LauncherDialog）、<code>model/upDecode</code>（AllBipParam）</td>
      <td>支持 BIP 确认 / 提示与回传</td>
    </tr>
    <tr>
      <td><code>model/upDecode</code>（LanguageNotificationHelper、LanguageNotificationParam）</td>
      <td>支持按 SIM 下发语言通知切换系统语言</td>
    </tr>
    <tr>
      <td rowspan="5">SIM卡信息交互</td>
      <td><code>pages</code>（Index）、<code>model/upDecode</code>（SetUpMenuParam、SelectItemParam）</td>
      <td>支持主菜单与子菜单的展示、选择与回传</td>
    </tr>
    <tr>
      <td><code>pages</code>（SimToolKitInput）、<code>model/upDecode</code>（GetInkeyInputParam）</td>
      <td>支持单字符 / 多字符输入与回传</td>
    </tr>
    <tr>
      <td><code>pages</code>（LauncherDialog）、<code>model/upDecode</code>（SetUpCallParam）</td>
      <td>支持呼叫建立确认（接受 / 拒绝）</td>
    </tr>
    <tr>
      <td><code>pages</code>（LauncherDialog）、<code>model/upDecode</code>（LaunchBrowserParam）</td>
      <td>支持确认后拉起系统浏览器</td>
    </tr>
    <tr>
      <td><code>common/helper</code>（EntranceHelper、SettingsDataHelper）</td>
      <td>支持在设置中显隐 STK 应用程序入口</td>
    </tr>
  </tbody>
</table>

### 与其它应用的关系

| 项目          | 说明 |
|-------------| ---- |
| 是否允许其它应用拉起  | 允许。`EntryAbility` / `ServiceExtAbility` 声明 `exported=true`，Telephony 等系统组件可通过 Want 拉起 |
| 谁能拉起        | 主要由 Telephony 框架拉起 `ServiceExtAbility` 下发 STK 事件；设置 / SIM 卡管理可携带 `slotId` 启动主菜单 |
| 什么时候能拉起     | 应用预置安装后即可被框架拉起；实际 STK 业务依赖 SIM 卡下发主动式命令 |
| 支持的 Want 参数 | `action`（`COMMON_EVENT_STK_*`）、`msgCmd`、`slotId`、`pageUrl` 等（见 `ServiceExtAbility` / `EntryAbility`） |
| 跨进程协作       | 通过 TelephonyKit API 回传命令结果；通过 Settings / RPC 与 `com.ohos.settings`、`com.ohos.simcardmanagement` 协同完成设置入口与双卡启动 |

## 编译构建

本工程源码按「产品层 / 特性层 / 公共层」组织，均位于单一 `entry` 模块内，使用 Hvigor 构建，产物为 `com.ohos.simtoolkits`（`SimToolkits.hap`）系统应用包。

### 环境要求

- OpenHarmony SDK：compileSdkVersion 26，compatibleSdkVersion 23
- DevEco Studio 或命令行 Hvigor 工具链
- 系统签名证书（见 `signature/`）

### 编译命令

在工程根目录执行：

```bash
# 使用 DevEco Studio 打开工程后执行 Build，或使用 hvigor 命令行
hvigorw assembleHap
```

## SimToolKits 开发

SimToolKits 采用 ArkTS 语言开发，UI 基于 ArkUI Stage 模型。应用通过 `ServiceExtAbility` 接收 Telephony 下发的 STK 事件，由 `SimToolKitAppService` 完成解析与分发；菜单 / 输入类交互启动 `EntryAbility` 加载 `Index`、`SimToolKitInput`，确认框 / Toast / 音调等由 `ServiceExtAbility` 直接拉起 `LauncherDialog`。开发可参考：[ArkUI 开发概述](https://gitcode.com/openharmony/docs/blob/master/zh-cn/application-dev/ui/arkts-ui-development-overview.md)

### 基于已有模块的开发

适用场景：对已有能力做功能定制，例如裁剪 / 调整既有 STK 命令处理、修改 UI 交互、调整设置入口逻辑等。

对已有模块的功能修改与裁剪

**场景1：修改命令解析链路**

需调整某类命令的 Param 创建，可在 `UpDecodeFactory` 中修改对应分支：

```typescript
// model/upDecode/UpDecodeFactory.ets — 按 commandType 创建 Param
private createUpParams(commandType: number): BaseUpParams | undefined {
  switch (commandType) {
    case CommandType.SET_UP_MENU:
      return new SetUpMenuParam();
    case CommandType.DISPLAY_TEXT:
      return new DisplayTextParam();
    // 调整已有命令时，在此修改对应 Param 类或分支
    default:
      return this.createUpParamsSecondary(commandType);
  }
}
```

**场景2：修改命令分发链路**

需调整 `SELECT_ITEM` / 输入类命令的拉起方式，在 `SimToolKitAppService` 中扩展：

```typescript
// model/SimToolKitAppService.ets — handleUpParamData
switch (upParams.commandType) {
  case CommandType.DISPLAY_TEXT:
    DisplayAndIdleTextHelper.getInstance(slotId)?.parseDisplayText(upParams as DisplayTextParam);
    break;
  case CommandType.SELECT_ITEM:
    this.startInputOrMenuAbility(upParams.slotId, upParams, PageUrl.PAGE_URL_MAIN);
    break;
  case CommandType.GET_INPUT:
  case CommandType.GET_INKEY:
    this.startInputOrMenuAbility(upParams.slotId, upParams, PageUrl.PAGE_URL_INPUT);
    break;
  // 调整已有命令时，修改对应分支逻辑即可
}
```

场景3：修改设置入口

需调整 `SET_UP_MENU` 后的入口刷新逻辑，修改 `EntranceHelper`：

```typescript
// common/helper/EntranceHelper.ets — SET_UP_MENU 后刷新设置入口
public async checkIsHaveMainMenu(
  context: common.ServiceExtensionContext | undefined,
  slotId: number
): Promise<void> {
  if (!context) {
    return;
  }
  let isHaveMainMenu =
    !CommonUtils.isEmptyObj(UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId));
  let key = this.getSettingDataKey(slotId);
  let value = this.getSaveSettingDataValue(slotId, isHaveMainMenu);
  await settings.setValue(context, key, value);
  // 再 publish stk_entrance 事件，并 RPC enableSearchItems / disableSearchItems
}
```

场景4：修改 UI 组件

需定制主菜单列表展示，直接修改 `pages/Index.ets`：

```typescript
// pages/Index.ets — 主菜单 / SELECT_ITEM 列表
List() {
  ForEach(this.menuList, (item: ItemContent, index?: number) => {
    ListItem() {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        // 可在此扩展：自定义图标、角标、辅助说明等
        Text(item.itemText)
          .fontSize($r('app.float.font_16'))
          .fontWeight(FontWeight.Medium)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontColor([$r('sys.color.icon_secondary')])
      }
      .onClick(() => {
        this.menuItemClick(item.itemId);
      })
    }
  })
}
```

常用修改入口：

| 目标 | 路径 |
| ---- | ---- |
| 菜单 / 子菜单 | `entry/src/main/ets/pages/Index.ets` |
| GET_INKEY / GET_INPUT | `entry/src/main/ets/pages/SimToolKitInput.ets` |
| 确认框 / Toast / 音调 | `entry/src/main/ets/pages/LauncherDialog.ets`、`common/components/` |
| 命令中枢 | `entry/src/main/ets/model/SimToolKitAppService.ets` |
| 设置入口 | `entry/src/main/ets/common/helper/EntranceHelper.ets` |
| 通用弹框 / 导航 | `entry/src/main/ets/common/components/` |

### 新特性能力的开发

适用场景：新增 Proactive Command 支持、扩展交互形态、补充差异化能力或适配新设备形态。

说明：当前工程为单一 `entry` HAP（`com.ohos.simtoolkits`），产品 / 特性 / 公共能力均在同一模块内按目录划分。新能力一般按现有分层扩展；若后续拆分产品形态 HAP，可再新增对应目录并在 `build-profile.json5` 中注册。

步骤1：扩展业务能力

1. 在 `SimToolKitConstant.ts` 的 `CommandType` 中补充命令类型。
2. 在 `model/upDecode/` 中新增或扩展对应 Param 解析类，并在 `UpDecodeFactory` 中注册。
3. 在 `SimToolKitAppService` 的分发逻辑中增加处理分支（拉起 UI 或自动响应）。
4. 如需回传专用结果，在 `model/responseData/` 中补充 Response / Envelope 编码。
5. 在 `entry/src/ohosTest` 中补充对齐 3GPP TS 27.22 的解析与响应单测，并在测试入口中注册。

步骤2：配置 / 确认 Ability 入口

本工程入口已在 `entry/src/main/module.json5` 中声明，扩展能力时通常只需确认权限与 Ability 配置是否满足新场景：

```json
{
  "module": {
    "name": "entry",
    "type": "entry",
    "srcEntry": "./ets/application/SimToolKitApplication.ets",
    "mainElement": "EntryAbility",
    "deviceTypes": [
      "default",
      "tablet"
    ],
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "exported": true,
        "launchType": "singleton"
      }
    ],
    "extensionAbilities": [
      {
        "name": "ServiceExtAbility",
        "srcEntry": "./ets/ServiceExtAbility/ServiceExtAbility.ets",
        "type": "service",
        "exported": true
      }
    ]
  }
}
```

步骤3：定制 UI

在完成业务能力与 Ability 配置后，按上一节对「已有模块的功能修改与裁剪」中的 UI 组件修改方式扩展菜单页、输入页或弹窗页即可。

若需新增独立页面：

1. 在 `pages/` 下新增页面文件；
2. 如需系统路由注册，在 `resources/base/profile/main_pages.json` 中声明；
3. 在 `Constants.ts` 补充 `PageUrl`，并由 `SimToolKitAppService` / `EntryAbility` 按命令类型拉起。

## 目录

```text
simtoolkits
├─AppScope                              # 应用级配置与多语言资源
│  ├─app.json5                          # 包名、版本号等
│  └─resources/                         # 全局字符串 / 图标等资源
├─docs
│  └─figures/                           # 架构图
├─entry                                 # 唯一 HAP 模块
│  └─src/main/
│     ├─ets/
│     │  ├─application/                 # 全局管理器：应用级生命周期与全局初始化
│     │  ├─entryability/                # 入口能力：拉起主菜单 / 输入页等 UI
│     │  ├─ServiceExtAbility/           # 扩展服务：接收电话子系统下发的 STK 事件并分发
│     │  ├─pages/                       # UI 页面：Index主菜单、SimToolKitInput 输入、确认框 /弹窗等
│     │  ├─model/                       # 业务中枢、TLV 解析、响应编码
│     │  │  ├─upDecode/                 # 主动式命令解析：建立菜单、展示文本等
│     │  │  └─responseData/             # 响应数据：终端响应 / Envelope 编码
│     │  ├─common/
│     │  │  ├─components/               # 通用 UI 组件
│     │  │  ├─constant/                 # 命令类型、TLV 标签、响应码、页面路由、超时等常量
│     │  │  ├─helper/                   # 入口、超时、空闲屏等 Helper
│     │  │  └─utils/                    # 通知、编码、缓存、上报等工具
│     │  └─workers/                     # 长时任务异步解析
│     ├─resources/                      # 模块资源、多语言等
│     └─module.json5                    # Ability、权限声明
├─hvigor                                # 构建工具配置
├─signature                             # 签名证书与 profile
├─build-profile.json5                   # 工程配置 / 签名 / product 配置
├─oh-package.json5
├─OAT.xml                               # 开源合规审计
├─LICENSE
├─README.md                             # 中文说明文档
└─README_en.md                          # 英文说明文档
```

## 约束

语言版本：ArkTS

运行形态：系统预置应用（`com.ohos.simtoolkits`），依赖 TelephonyKit、通知、浮窗、后台任务等系统能力

设备类型：`手机`、`平板`（见 `entry/src/main/module.json5`）

权限：SimToolKits 所需的主要权限如下（见 `entry/src/main/module.json5`）

| 权限 | 授权方式 | 使用场景 |
| ---- | -------- | -------- |
| ohos.permission.SET_TELEPHONY_STATE | 系统授权 | 回传 Terminal Response / Envelope，处理呼叫建立确认 |
| ohos.permission.GET_TELEPHONY_STATE | 系统授权 | 查询 SIM / 通话相关状态 |
| ohos.permission.KEEP_BACKGROUND_RUNNING | 系统授权 | STK 会话期间后台连续任务保活 |
| ohos.permission.START_ABILITIES_FROM_BACKGROUND | 系统授权 | 后台拉起菜单 / 输入 / 弹窗 Ability |
| ohos.permission.SYSTEM_FLOAT_WINDOW | 系统授权 | 创建浮窗 / 对话框展示 STK UI |
| ohos.permission.ACCESS_NOTIFICATION_POLICY | 系统授权 | 空闲模式文本、REFRESH 等通知展示 |
| ohos.permission.MANAGE_SETTINGS / ACCESS_SYSTEM_SETTINGS | 系统授权 | 读写 Settings，控制设置入口显示与隐藏 |
| ohos.permission.UPDATE_CONFIGURATION | 系统授权 | 语言通知等配置变更 |
| ohos.permission.VIBRATE | 系统授权 | PLAY_TONE 等场景振动提示 |
| ohos.permission.PRIVACY_WINDOW | 系统授权 | 敏感输入场景隐私窗口 |

支持的主动式命令：`SET_UP_MENU`、`SELECT_ITEM`、`DISPLAY_TEXT`、`GET_INKEY`、`GET_INPUT`、`SET_UP_IDLE_MODE_TEXT`、`PROVIDE_LOCAL_INFORMATION`、`SET_UP_CALL`、`LAUNCH_BROWSER`、`PLAY_TONE`、`SET_UP_EVENT_LIST`、`LANGUAGE_NOTIFICATION`、BIP 相关命令等（部分命令应用侧仅做 Alpha ID 提示，执行在 RIL）

## 参与贡献

欢迎广大开发者贡献代码、文档等，具体的贡献流程和方式请参见[参与贡献](https://gitcode.com/openharmony/docs/blob/master/zh-cn/contribute/%E5%8F%82%E4%B8%8E%E8%B4%A1%E7%8C%AE.md)。

## 相关仓

- [applications_simcardmanagement](https://gitcode.com/openharmony-sig/applications_simcardmanagement)（sim卡管理应用）
- [applications_settings](https://gitcode.com/openharmony/applications_settings)（系统设置与相关外部页面）
