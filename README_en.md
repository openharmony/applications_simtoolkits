# SIM Card Value-Added Services (SimToolKits)

## Introduction

SimToolKits (STK, bundle name: `com.ohos.simtoolkits`) is a pre-installed **SIM card value-added services system application** in the OpenHarmony telephony subsystem. It parses and handles proactive commands issued by the SIM card, presents interactive UI such as menus, text, input fields, and confirmation dialogs, and returns the user action result to the Telephony framework as a Terminal Response or Envelope.

This is a pre-installed system application. It supports single-SIM, dual-SIM, and eSIM scenarios. It usually has no desktop icon; users can open the STK main menu from **Settings → Mobile network → SIM management → SIM applications**.

### Core Capabilities

**SIM Card Info Display**

- Supports displaying SIM-issued text, idle mode text, or refresh prompts
- Supports playing notification tones, optionally with a text dialog
- Supports BIP confirmation / prompts and response
- Supports switching system language per SIM language notification

**SIM Card Info Interaction**

- Supports main menu / submenu display, selection and response
- Supports single- / multi-character input and response
- Supports call-setup confirmation (accept / reject)
- Supports launching the system browser after confirmation
- Supports showing / hiding the STK entry in Settings

> **Note**: This repository is the STK **application layer**. Command parsing, session dispatch, and Terminal Response encoding live in the common layer (`AppService Hub` / `UpDecode Parsing` / `Response Encoding` / `Worker`).

### Terminology

| Term | Full name | Description |
| ---- | --------- | ----------- |
| Proactive Command | — | A business instruction the SIM issues to the terminal on its own initiative (for example set up menu, display text, get input, BIP open channel); this app parses it and drives the UI |
| Terminal Response | — | The message that returns command execution results (success / failure / user cancel, and so on) from the terminal to the SIM |
| Envelope | — | An event or user selection the terminal reports to the SIM (for example menu item selection); used with Terminal Response to complete a session |
| BIP | Bearer Independent Protocol | STK data-channel capability independent of the bearer; includes `OPEN_CHANNEL`, `CLOSE_CHANNEL`, `RECEIVE_DATA`, `SEND_DATA`, `GET_CHANNEL_STATUS`, and related commands. This app mainly shows Alpha ID confirmation / prompts and returns the result; link setup and transfer run in Modem / RIL |
| Alpha ID | — | Human-readable prompt text carried in a command, shown to the user in dialogs, Toast, and similar UI |
| TLV | Tag-Length-Value | Binary encoding structure for STK commands and responses; the common layer `upDecode` / `responseData` parses and encodes it |

## Architecture

SimToolKits uses a layered, modular design. Source code is organized by product form factor, feature capabilities, and common utilities, and works with the telephony subsystem, as shown below:

![SimToolKits component and external dependencies](./docs/figures/simtoolkits_ipc_en.png)


### Application Layer Design

The overall design can be divided into a product layer, a feature layer, and a common layer:

| Layer | Main directories / components | Description |
| ----- | ------------------------- | ----------- |
| Product | phone / pad | Supports phone and tablet form factors |
| Feature | `pages`, `model/upDecode` | SIM Card Info Display, SIM Card Info Interaction |
| Common | `model/upDecode`, `model/responseData`, `model` (SimToolKitAppService), `workers`, `common/helper` (EntranceHelper), `common/utils` (NotificationUtils), `common/helper` (CustTimeOutHelper) | UpDecode Parsing, Response Encoding, AppService Hub, Worker, EntranceHelper, Notification Tool, Timeout Keep-alive |

Modules:

<table>
  <thead>
    <tr>
      <th>Module</th>
      <th>Directories and key classes</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>phone / pad</td>
      <td><code>module.json5</code> (<code>deviceTypes: default</code> / <code>tablet</code>)</td>
      <td>Declare phone (<code>default</code>) and tablet (<code>tablet</code>) form factors in <code>module.json5</code>; share the same STK parse / dispatch / pages and <code>entry</code> HAP, with no separate product source tree</td>
    </tr>
    <tr>
      <td rowspan="4">SIM Card Info Display</td>
      <td><code>model/upDecode</code> (DisplayTextParam, SetUpIdleModeTextParam)</td>
      <td>Supports displaying SIM-issued text, idle mode text, or refresh prompts</td>
    </tr>
    <tr>
      <td><code>model/upDecode</code> (PlayToneParam)</td>
      <td>Supports playing notification tones, optionally with a text dialog</td>
    </tr>
    <tr>
      <td><code>pages</code> (LauncherDialog), <code>model/upDecode</code> (AllBipParam)</td>
      <td>Supports BIP confirmation / prompts and response (Alpha ID in app; execution in RIL)</td>
    </tr>
    <tr>
      <td><code>model/upDecode</code> (LanguageNotificationHelper, LanguageNotificationParam)</td>
      <td>Supports switching system language per SIM language notification</td>
    </tr>
    <tr>
      <td rowspan="4">SIM Card Info Interaction</td>
      <td><code>pages</code> (Index), <code>model/upDecode</code> (SetUpMenuParam, SelectItemParam)</td>
      <td>Supports main menu / submenu display, selection and response</td>
    </tr>
    <tr>
      <td><code>pages</code> (SimToolKitInput), <code>model/upDecode</code> (GetInkeyInputParam)</td>
      <td>Supports single- / multi-character input and response</td>
    </tr>
    <tr>
      <td><code>pages</code> (LauncherDialog), <code>model/upDecode</code> (SetUpCallParam)</td>
      <td>Supports call-setup confirmation (accept / reject)</td>
    </tr>
    <tr>
      <td><code>pages</code> (LauncherDialog), <code>model/upDecode</code> (LaunchBrowserParam)</td>
      <td>Supports launching the system browser after confirmation</td>
    </tr>
    <tr>
      <td>UpDecode Parsing</td>
      <td><code>model/upDecode</code> (UpDecodeFactory, Param classes)</td>
      <td>Parse proactive-command TLVs from the SIM into the corresponding Param</td>
    </tr>
    <tr>
      <td>response Encoding</td>
      <td><code>model/responseData</code></td>
      <td>Encode Terminal Response / Envelope and return via TelephonyKit</td>
    </tr>
    <tr>
      <td>AppService Hub</td>
      <td><code>model</code> (SimToolKitAppService)</td>
      <td>STK command hub: dispatch by type to pages / dialogs and drive the response</td>
    </tr>
    <tr>
      <td>Worker</td>
      <td><code>workers</code>, <code>common/components</code></td>
      <td>Async STK command-hex parsing, and reusable UI such as confirm / tone dialogs</td>
    </tr>
    <tr>
      <td>EntranceHelper</td>
      <td><code>common/helper</code> (EntranceHelper, SettingsDataHelper)</td>
      <td>Supports showing / hiding the STK entry in Settings</td>
    </tr>
    <tr>
      <td>Notification Tool</td>
      <td><code>common/utils</code> (NotificationUtils, UiUtils, UpParamsCacheUtils, etc.), <code>common/constant</code>, <code>common/helper</code> (DisplayAndIdleTextHelper)</td>
      <td>STK shared utilities: notification, start Ability / floating window, main-menu cache, idle-mode text, command-type and response-code constants</td>
    </tr>
    <tr>
      <td>Timeout Keep-alive</td>
      <td><code>common/helper</code> (CustTimeOutHelper)</td>
      <td>STK session command timeout and background keep-alive; reused by display / interaction modules</td>
    </tr>
  </tbody>
</table>

### Relationship with Other Applications

| Item                        | Description |
|-----------------------------| ----------- |
| Can other apps launch it?   | Yes. `EntryAbility` / `ServiceExtAbility` declare `exported=true`; Telephony and other system components can start them via Want |
| Launch scenarios            | **Scenario 1 (SIM-initiated):** After the pre-installed app is available, when the SIM issues a proactive command, the Telephony framework starts `ServiceExtAbility` with `action` / `msgCmd` / `slotId` (and related Want params) to deliver the STK event and drive interaction.<br>**Scenario 2 (User from Settings):** When the user opens **Settings / SIM management → SIM applications**, Settings or `com.ohos.simcardmanagement` starts `EntryAbility` with `slotId` (and optional `pageUrl`) to open the STK main menu for that slot. |
| Supported Want parameters   | `action` (`COMMON_EVENT_STK_*`), `msgCmd`, `slotId`, `pageUrl`, and so on (see `ServiceExtAbility` / `EntryAbility`) |
| Cross-process collaboration | Returns command results via TelephonyKit APIs; coordinates Settings entry and dual-SIM launch with `com.ohos.settings` and `com.ohos.simcardmanagement` through Settings / RPC |

## Build

Source code is organized as product / feature / common layers inside a single `entry` module. The project is built with Hvigor and produces the `com.ohos.simtoolkits` (`SimToolkits.hap`) system application package.

### Environment Requirements

- OpenHarmony SDK: compileSdkVersion 26, compatibleSdkVersion 23
- DevEco Studio or the Hvigor command-line toolchain
- System signing certificates (see `signature/`)

### Build Commands

From the repository root:

```bash
# Open the project in DevEco Studio and build, or use the hvigor CLI
hvigorw assembleHap
```

## SimToolKits Development

SimToolKits is developed in ArkTS, with UI based on the ArkUI Stage model. The app receives STK events from Telephony through `ServiceExtAbility`, and `SimToolKitAppService` parses and dispatches them. Menu / input flows start `EntryAbility` to load `Index` or `SimToolKitInput`; confirm / Toast / tone flows are launched as `LauncherDialog` directly from `ServiceExtAbility`. See also: [ArkUI Development Overview](https://gitcode.com/openharmony/docs/blob/master/en/application-dev/ui/arkts-ui-development-overview.md)

### Developing on Existing Modules

Typical scenarios: customize existing capabilities, such as trimming or adjusting STK command handling, changing UI interaction, or updating Settings entry logic.

Modifying or trimming existing modules

**Scenario 1: Modify the command parsing path**

To adjust Param creation for a command type, change the corresponding branch in `UpDecodeFactory`:

```typescript
// model/upDecode/UpDecodeFactory.ets — create Param by commandType
private createUpParams(commandType: number): BaseUpParams | undefined {
  switch (commandType) {
    case CommandType.SET_UP_MENU:
      return new SetUpMenuParam();
    case CommandType.DISPLAY_TEXT:
      return new DisplayTextParam();
    // When adjusting an existing command, change the Param class or branch here
    default:
      return this.createUpParamsSecondary(commandType);
  }
}
```

**Scenario 2: Modify the command dispatch path**

To adjust how `SELECT_ITEM` / input commands are started, extend `SimToolKitAppService`:

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
  // When adjusting an existing command, change the branch logic here
}
```

**Scenario 3: Modify STK entry visibility in Settings**

After the SIM sets up or clears the main menu (`SET_UP_MENU`), the app calls `EntranceHelper.checkIsHaveMainMenu`: based on whether that slot has a cached main menu, it writes Settings, publishes the `stk_entrance` event, and RPCs `com.ohos.settings` to enable / disable the search item, controlling whether **Settings → SIM applications** is visible. To customize show/hide policy or dual-SIM / eSIM mapping, change `EntranceHelper`:

```typescript
// common/helper/EntranceHelper.ets — refresh Settings entry from main-menu cache
public async checkIsHaveMainMenu(
  context: common.ServiceExtensionContext | undefined,
  slotId: number
): Promise<void> {
  if (!context) {
    return;
  }
  // Whether this slot already has a SET_UP_MENU-cached main menu
  let isHaveMainMenu =
    !CommonUtils.isEmptyObj(UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId));
  let settingDataKey = this.getSettingDataKey(slotId);
  let settingDataValue = this.getSaveSettingDataValue(slotId, isHaveMainMenu);
  await settings.setValue(context, settingDataKey, settingDataValue);
  // Also write timestamp, publish('stk_entrance'), then RPC enableSearchItems / disableSearchItems
}
```

**Scenario 4: Modify UI components**

To customize the main menu list, edit `pages/Index.ets`:

```typescript
// pages/Index.ets — main menu / SELECT_ITEM list
List() {
  ForEach(this.menuList, (item: ItemContent, index?: number) => {
    ListItem() {
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        // Extend here: custom icon, badge, secondary text, and so on
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

Common modification entry points:

| Target | Path |
| ------ | ---- |
| Menu / submenu | `entry/src/main/ets/pages/Index.ets` |
| GET_INKEY / GET_INPUT | `entry/src/main/ets/pages/SimToolKitInput.ets` |
| Confirm / Toast / tone | `entry/src/main/ets/pages/LauncherDialog.ets`, `common/components/` |
| Command hub | `entry/src/main/ets/model/SimToolKitAppService.ets` |
| Settings entry | `entry/src/main/ets/common/helper/EntranceHelper.ets` |
| Shared dialogs / navigation | `entry/src/main/ets/common/components/` |

### Developing New Feature Capabilities

Applicable scenarios: adding Proactive Command support, extending interaction forms, supplementing differentiated capabilities, or adapting to new device form factors.

Note: This project is a single `entry` HAP (`com.ohos.simtoolkits`). Product, feature, and common capabilities are organized by directory within the same module. New capabilities are generally extended along the existing layers; if product-form HAPs are split later, add the corresponding directories and register them in `build-profile.json5`.

#### Example: adding Proactive Command support

The following uses the sample command `DEMO_CMD` (`0x7A`, not implemented in this repository) to describe the processing flow and key entry points required when adding a Proactive Command.

Processing path: Telephony delivers command hex → `ServiceExtAbility` accepts the command → `UpDecodeFactory` parses it into a Param → `SimToolKitAppService` dispatches → UI presentation and user action → `responseData` encodes Terminal Response / Envelope → TelephonyKit returns the result.

**Step 1: Complete command recognition, parsing, dispatch, and response**

Goal: enable the application to recognize `DEMO_CMD`, complete TLV parsing and command dispatch, and return the processing result according to the protocol.

1) Register the command type in `CommandType` (must match the command-type byte delivered by Modem / the card):

```typescript
// common/constant/SimToolKitConstant.ts
export enum CommandType {
  // ...
  DEMO_CMD = 0x7A, // sample command
  // ...
}
```

2) Add a Param parsing class and register it in `UpDecodeFactory.createUpParams`. If it is not registered, `parseUpData` cannot construct a Param and the command is dropped:

```typescript
// model/upDecode/DemoCmdParam.ets (sample; create this file)
export class DemoCmdParam extends BaseUpParams {
  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    // Parse this command's TLVs per protocol and write Param fields
  }
}

// model/upDecode/UpDecodeFactory.ets
case CommandType.DEMO_CMD:
  result = new DemoCmdParam();
  break;
```

3) Add a dispatch branch in `SimToolKitAppService` to route the Param to the corresponding UI entry (confirm dialog via `UiUtils.startDialog`; full-screen page via `startInputOrMenuAbility`):

```typescript
// model/SimToolKitAppService.ets — handleUpParamDataSecondary
case CommandType.DEMO_CMD:
  // UiUtils.startDialog(this.uiContext, this.serviceContext, upParams);
  // or: this.startInputOrMenuAbility(upParams.slotId, upParams, PageUrl.PAGE_URL_XXX);
  break;
```

4) Complete encoding and response through `SimToolKitResponseManager.sendTerminalResponseData` (use `sendBipResponseData` in BIP scenarios). Ordinary commands may reuse `DefaultResponseData`; add a dedicated encoder only when custom result fields must be returned.

5) Add test cases under `entry/src/ohosTest/ets/test/commandtype/`, drive parsing and UI validation with command hex, and register them in `List.test.ets`.

**Step 2: Verify Ability and permission configuration**

Step 1 has completed command parsing, dispatch, and response logic at the business layer. Next, verify the Ability and permission declarations in `entry/src/main/module.json5` to ensure Telephony can deliver the command to this application and that this application has permission to start UI and return results. These entry points and permissions are typically already available in this repository; confirm them against the actual interaction of the new command:

```json5
// entry/src/main/module.json5 (excerpt)
{
  "module": {
    "mainElement": "EntryAbility",
    "pages": "$profile:main_pages",
    "abilities": [{
      "name": "EntryAbility",
      "srcEntry": "./ets/entryability/EntryAbility.ets",
      "exported": true,          // full-screen page entry
      "launchType": "singleton",
      "permissions": ["ohos.permission.SET_TELEPHONY_STATE"]
    }],
    "extensionAbilities": [{
      "name": "ServiceExtAbility",
      "srcEntry": "./ets/ServiceExtAbility/ServiceExtAbility.ets",
      "type": "service",
      "exported": true           // entry for STK events delivered by Telephony
    }],
    "requestPermissions": [
      "ohos.permission.SET_TELEPHONY_STATE",              // Terminal Response / Envelope
      "ohos.permission.START_ABILITIES_FROM_BACKGROUND",  // start EntryAbility / dialogs from background
      "ohos.permission.SYSTEM_FLOAT_WINDOW",              // LauncherDialog floating window
      "ohos.permission.KEEP_BACKGROUND_RUNNING"           // keep STK session alive
    ]
  }
}
```

| Interaction | Required entry / permission |
| ----------- | --------------------------- |
| Confirm / Toast | `ServiceExtAbility`, `SYSTEM_FLOAT_WINDOW`, response permission |
| Full-screen page | Also `EntryAbility` (`exported=true`), `START_ABILITIES_FROM_BACKGROUND` |
| Return processing result | `SET_TELEPHONY_STATE` |

**Step 3: Complete UI-side integration**

Step 2 has confirmed that the command can enter the application and that permissions to start UI and return results are available. Next, complete UI-side integration so that Param fields can be presented to the user and user action results can be returned to `SimToolKitAppService` for the response:

- Confirm dialog: add a `CommandType.DEMO_CMD` branch in `pages/LauncherDialog.ets`; `main_pages.json` usually does not need changes.
- Full-screen page: add the page and register it in `resources/base/profile/main_pages.json`, add a route constant in `PageUrl`, and dispatch with `startInputOrMenuAbility(..., PageUrl.PAGE_URL_XXX)`. The Want must carry `pageUrl`, `upParam`, and `slotId` so that `EntryAbility` can execute `loadContent`.

## Directory

```text
simtoolkits
├─AppScope                              # STK app-level config (bundle com.ohos.simtoolkits) and localized strings
│  ├─app.json5                          # STK bundleName and version
│  └─resources/                         # STK global strings / icons (menu titles, default confirm text, etc.)
├─docs
│  └─figures/                           # STK architecture diagrams (app vs Telephony / RIL)
├─entry                                 # Single STK HAP module (output SimToolkits.hap)
│  └─src/main/
│     ├─ets/
│     │  ├─application/                 # STK process init (SimToolKitApplication)
│     │  ├─entryability/                # STK UI EntryAbility: open main menu / GET_INPUT page
│     │  ├─ServiceExtAbility/           # STK event entry: receive proactive commands from Telephony and hand off to the hub
│     │  ├─pages/                       # STK interaction pages
│     │  │                              #   Index — STK main menu / SELECT_ITEM submenu
│     │  │                              #   SimToolKitInput — GET_INKEY / GET_INPUT page
│     │  │                              #   LauncherDialog — confirm / Toast / PLAY_TONE / BIP open-channel confirm
│     │  ├─model/                       # STK business hub and codec
│     │  │  ├─upDecode/                 # STK proactive-command parse (SET_UP_MENU, DISPLAY_TEXT, BIP Params, etc.)
│     │  │  └─responseData/             # STK return encoding (Terminal Response / menu-selection Envelope)
│     │  ├─common/
│     │  │  ├─components/               # STK shared UI (confirm dialog, tone dialog, back nav, etc.)
│     │  │  ├─constant/                 # STK command types, TLV tags, response codes, PageUrl, timeouts
│     │  │  ├─helper/                   # STK helpers: Settings “SIM applications” entry show/hide, idle-mode text, session timeout, etc.
│     │  │  └─utils/                    # STK utilities: notification, codec, main-menu cache, start Ability / dialog, etc.
│     │  └─workers/                     # Async STK command-hex parsing (avoid blocking the UI thread)
│     ├─resources/                      # STK module resources (strings, colors, main_pages.json routes)
│     └─module.json5                    # STK Ability / permission declarations (EntryAbility, ServiceExtAbility)
├─hvigor                                # Build tool config
├─signature                             # System-app signing certificates and profiles
├─build-profile.json5                   # Project / signing / product config
├─oh-package.json5
├─OAT.xml                               # Open-source compliance audit
├─LICENSE
├─README.md                             # Chinese documentation
└─README_en.md                          # English documentation
```

## Constraints

Language: ArkTS

Runtime form: pre-installed system application (`com.ohos.simtoolkits`), depending on TelephonyKit, notification, floating window, background task, and related system capabilities

Device types: `phone`, `tablet` (see `entry/src/main/module.json5`)

Permissions: main permissions required by SimToolKits (see `entry/src/main/module.json5`). Usage below lists only SIM / STK trigger points:

| Permission | Grant mode | Usage (SIM / STK specific) |
| ---------- | ---------- | -------------------------- |
| ohos.permission.SET_TELEPHONY_STATE | system grant | After menu selection, input, or confirm / reject, return Terminal Response / Envelope for that slot; for `SET_UP_CALL`, return accept / reject to Telephony |
| ohos.permission.GET_TELEPHONY_STATE | system grant | Before opening the STK main menu, check whether that slot’s SIM is ready (exit if no card / not active); in dual-SIM, use `getMaxSimCount` and SIM labels to distinguish card 1 / card 2 / eSIM entry text |
| ohos.permission.START_ABILITIES_FROM_BACKGROUND | system grant | When the SIM issues a proactive command while the app is in the background: `SELECT_ITEM` / main menu → `EntryAbility` + `Index`; `GET_INKEY` / `GET_INPUT` → `EntryAbility` + `SimToolKitInput`; after the user accepts `LAUNCH_BROWSER`, start the system browser |
| ohos.permission.SYSTEM_FLOAT_WINDOW | system grant | Show confirm / prompt UI via `LauncherDialog` floating window for commands such as `DISPLAY_TEXT`, `SET_UP_CALL`, `LAUNCH_BROWSER`, `OPEN_CHANNEL`, `PLAY_TONE` |
| ohos.permission.KEEP_BACKGROUND_RUNNING | system grant | While an STK session waits for the user, listens for idle-mode text, or runs event-list timeouts, apply background efficiency resources so the session is not suspended before a response can be returned |
| ohos.permission.ACCESS_NOTIFICATION_POLICY | system grant | Publish idle-mode text for `SET_UP_IDLE_MODE_TEXT`; show `REFRESH` prompts; on the lock screen, notify the user about confirm-style STK commands |
| ohos.permission.MANAGE_SETTINGS / ACCESS_SYSTEM_SETTINGS | system grant | After the SIM sets up or clears `SET_UP_MENU`, write Settings `stk_entrance` to show / hide **Settings → Mobile network → SIM management → SIM applications** per slot (including dual-SIM / eSIM) |
| ohos.permission.UPDATE_CONFIGURATION | system grant | On SIM `LANGUAGE_NOTIFICATION`, switch the system language to the language specified by the card |
| ohos.permission.VIBRATE | system grant | On SIM `PLAY_TONE` when the command qualifier requests vibration, `TonePlayer` vibrates for the tone duration (see `PlayToneParam.isVibrate`) |
| ohos.permission.PRIVACY_WINDOW | system grant | On the `GET_INKEY` / `GET_INPUT` page (`SimToolKitInput`), enable window privacy mode so password-style input is not captured by screenshot / screen recording |

> **SIM notes**: Menu entry, notifications, and responses are isolated by `slotId` for dual-SIM / eSIM. Settings entry visibility depends on whether each slot has a cached `SET_UP_MENU` main menu; physical SIM / eSIM mapping is in `EntranceHelper`.

Supported proactive commands: `SET_UP_MENU`, `SELECT_ITEM`, `DISPLAY_TEXT`, `GET_INKEY`, `GET_INPUT`, `SET_UP_IDLE_MODE_TEXT`, `PROVIDE_LOCAL_INFORMATION`, `SET_UP_CALL`, `LAUNCH_BROWSER`, `PLAY_TONE`, `SET_UP_EVENT_LIST`, `LANGUAGE_NOTIFICATION`, and BIP-related commands (`OPEN_CHANNEL`, `CLOSE_CHANNEL`, `RECEIVE_DATA`, `SEND_DATA`, `GET_CHANNEL_STATUS`), among others (for some commands the app only shows prompt text; channel / SMS / USSD execution is in RIL)

## Contributing

Contributions of code, documentation, and more are welcome. See [Contributing](https://gitcode.com/openharmony/docs/blob/master/en/contribute/contribution-process.md).

## Related Repositories

- [applications_simcardmanagement](https://gitcode.com/openharmony-sig/applications_simcardmanagement) (SIM card management app)
- [applications_settings](https://gitcode.com/openharmony/applications_settings) (system Settings and related external pages)
