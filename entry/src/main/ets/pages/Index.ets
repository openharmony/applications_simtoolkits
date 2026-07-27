/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { LengthMetrics, router } from '@kit.ArkUI';
import NavBack, { NavCallBackType } from '../common/components/NavBack';
import HiLog from '../common/utils/HiLog';
import UiUtils from '../common/utils/UiUtils';
import { CommandType, UIResponseCode } from '../common/constant/SimToolKitConstant';
import { UpParamsCacheUtils } from '../common/utils/UpParamsCacheUtils';
import { BaseUpParams, ItemContent } from '../model/upDecode/BaseUpParams';
import { SlotIdAndParam } from '../model/upDecode/BaseUpParams';
import { SelectItemParam } from '../model/upDecode/SelectItemParam';
import { SetUpMenuParam } from '../model/upDecode/SetUpMenuParam';
import { SimToolKitAppService } from '../model/SimToolKitAppService';
import { FromPageFlag, UiMenuResponseData } from '../model/UIResponseData';
import { EventHub, FontSizeScaleLevel, LocalStorageKey, TimeOut, ViewId } from '../common/constant/Constants';
import CommonUtils from '../common/utils/CommonUtils';
import { AppStorageHelper, AppStorageKey } from '../common/helper/AppStorageHelper';
import { ContextStorageHelper } from '../common/utils/ContextStorageHelper';
import { AccessibilityUtils } from '../common/utils/AccessibilityUtils';
import { CustTimeOutHelper } from '../common/helper/CustTimeOutHelper';

const TAG = 'IndexMenu';

@Entry
@Component
struct Index {
  @State title: string = '';
  @State menuItems: Array<NavCallBackType> = [];
  @State menuList: Array<ItemContent> = [];
  @State isShowMenu: boolean = false;
  private slotId?: number;
  private curUpParam?: BaseUpParams;
  private commandType: number = -1;
  private isAcceptUsersInput: boolean = true;
  private selectItemMenuTimeOut?: number;
  private defaultItem: number = 0;
  private isSelectItemBack: boolean = false;
  private isTerminalResponse: boolean = true; // page aboutToDisappear end session
  @StorageProp('isConfirmDialogShow') @Watch('isConfirmDialogStatusChange') isConfirmDialogShow: boolean = false;
  @StorageProp(AppStorageKey.FONT_SIZE_SCALE_KEY) fontSizeScale: number = 1;
  private callBackSessionEnd = (slotId: number) => {
    this.onSessionEnd(slotId);
  };
  private callBackReceiveCommand = (slotId: number, commandType: number) => {
    this.onReceiveCommand(slotId, commandType);
  };
  private callBackRefreshMenuData = (slotId: number, upParam: BaseUpParams) => {
    this.onRefreshMenuData(slotId, upParam);
  };
  private callBackRefreshSetUpMenu = (slotId: number, upParam: BaseUpParams) => {
    this.onRefreshSetUpMenu(slotId, upParam);
  };

  private isConfirmDialogStatusChange(): void {
    HiLog.info(TAG, `isConfirmDialogStatusChange :: ${this.isConfirmDialogShow}`);
    if (!this.isConfirmDialogShow) {
      AccessibilityUtils.getInstance().setDialogDestroyTime();
    }
  }

  private startSelectItemMenuTimeOut(): void {
    HiLog.info(TAG, 'startSelectItemMenuTimeOut');
    this.stopSelectItemMenuTimeOut();
    this.selectItemMenuTimeOut = CustTimeOutHelper.getInstance().setTimeOutCust(() => {
      this.isAcceptUsersInput = false;
      this.isTerminalResponse = false;
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU, UIResponseCode.RESPONSE_TYPE_TIMEOUT,
        this.curUpParam, undefined, undefined);
    }, TimeOut.MENU_AND_INPUT);
  }

  private stopSelectItemMenuTimeOut(): void {
    if (this.selectItemMenuTimeOut !== undefined) {
      HiLog.info(TAG, 'stopSelectItemMenuTimeOut');
      clearTimeout(this.selectItemMenuTimeOut);
      this.selectItemMenuTimeOut = undefined;
    }
  }

  private subscribeMessageFromAppService(): void {
    let uiContext = getContext(this) as common.UIAbilityContext;
    uiContext.eventHub.on(EventHub.SESSION_END, this.callBackSessionEnd);
    uiContext.eventHub.on(EventHub.RECEIVE_COMMAND, this.callBackReceiveCommand);
    uiContext.eventHub.on(EventHub.REFRESH_MENU_DATA, this.callBackRefreshMenuData);
    uiContext.eventHub.on(EventHub.REFRESH_SET_UP_MENU, this.callBackRefreshSetUpMenu);
  }

  private unSubscribeMessageFromAppService(): void {
    let uiContext = getContext(this) as common.UIAbilityContext;
    uiContext.eventHub.off(EventHub.SESSION_END, this.callBackSessionEnd);
    uiContext.eventHub.off(EventHub.RECEIVE_COMMAND, this.callBackReceiveCommand);
    uiContext.eventHub.off(EventHub.REFRESH_MENU_DATA, this.callBackRefreshMenuData);
    uiContext.eventHub.off(EventHub.REFRESH_SET_UP_MENU, this.callBackRefreshSetUpMenu);
  }

  private onReceiveCommand(slotId: number, commandType: number): void {
    HiLog.info(TAG, `callBackReceiveCommand slotId:${slotId}, commandType:${commandType}`);
    if (this.slotId === slotId && (commandType === CommandType.GET_INPUT || commandType === CommandType.GET_INKEY)) {
      this.stopSelectItemMenuTimeOut();
    }
  }

  private onSessionEnd(slotId: number): void {
    HiLog.info(TAG, `callBackSessionEnd slotId:${slotId}`);
    if (this.slotId === slotId) {
      let preCommandType = this.commandType;
      this.stopSelectItemMenuTimeOut();
      let mainMenuParam = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId);
      this.updateMenu(mainMenuParam);
      if (this.commandType === CommandType.SET_UP_MENU) {
        this.isAcceptUsersInput = true;
      }
      if (this.isSelectItemBack && preCommandType === CommandType.SELECT_ITEM &&
        this.commandType === CommandType.SET_UP_MENU) {
        AccessibilityUtils.getInstance().sendAccessibilityEvent(ViewId.NAV_BACK_BACK, false);
        this.isSelectItemBack = false;
      }
    }
  }

  private onRefreshMenuData(slotId: number, upParam: BaseUpParams): void {
    HiLog.info(TAG, `callBackRefreshMenuData slotId:${slotId}, commandType:${upParam?.commandType}`);
    if (upParam) {
      let preCommandType = this.commandType;
      this.isAcceptUsersInput = true;
      this.slotId = slotId;
      this.updateMenu(upParam);

      // from home to second page, to get the accessibility focus.
      if (preCommandType === CommandType.SET_UP_MENU && upParam.commandType === CommandType.SELECT_ITEM) {
        AccessibilityUtils.getInstance().sendAccessibilityEvent(ViewId.NAV_BACK_BACK, true);
      }
    } else {
      this.slotId = slotId;
      this.curUpParam = undefined;
      HiLog.error(TAG, 'callBackRefreshMenuData upParam is undefined');
    }
  }

  private onRefreshSetUpMenu(slotId: number, upParam: BaseUpParams): void {
    if (this.commandType !== CommandType.SET_UP_MENU || this.slotId !== slotId) {
      return;
    }
    this.isAcceptUsersInput = true;
    this.curUpParam = upParam;
    this.slotId = slotId;
    if (upParam) {
      this.updateMenu(upParam);
    } else {
      this.isTerminalResponse = false;
      CommonUtils.terminateSelfCust(ContextStorageHelper.getInstance().getEntryUiContext());
      HiLog.error(TAG, 'callBackRefreshMenuData upParam is undefined');
    }
  }

  onPageShow(): void {
    HiLog.info(TAG, 'onPageShow');
    AppStorageHelper.set<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, true);
    if (this.slotId === undefined) {
      HiLog.error(TAG, 'onPageShow slotId is empty');
    }
    if (this.curUpParam) {
      this.updateMenu(this.curUpParam);
    } else {
      this.getMainMenuAndUpDate();
    }
  }

  onPageHide(): void {
    HiLog.info(TAG, 'onPageHide');
    this.isShowMenu = false;
    AppStorageHelper.set<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false);
  }

  onBackPress?(): void | boolean {
    HiLog.info(TAG, `onBackPress isAcceptUsersInput:${this.isAcceptUsersInput}`);
    if (UiUtils.isNeedTransBackPressToDialog()) {
      HiLog.info(TAG, 'from index page trans onBackPress event to dialog');
      return true;
    }
    if (!this.isAcceptUsersInput) {
      HiLog.debug(TAG, 'onBackPress not accept input');
      return true;
    }
    if (this.commandType === CommandType.SELECT_ITEM) {
      this.stopSelectItemMenuTimeOut();
      this.isSelectItemBack = true;
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU,
        UIResponseCode.RESPONSE_TYPE_BACKWARD, this.curUpParam, undefined, undefined);
      this.isTerminalResponse = false;
      this.isRouterBack();
      return true;
    }

    CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
    return true;
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, `aboutToDisappear isTerminalResponse:${this.isTerminalResponse}`);
    this.unSubscribeMessageFromAppService();
    this.stopSelectItemMenuTimeOut();
    if (this.isTerminalResponse && this.commandType === CommandType.SELECT_ITEM) {
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU,
        UIResponseCode.RESPONSE_TYPE_END_SESSION, this.curUpParam, undefined, undefined);
    }
    let bindParam: BaseUpParams | undefined = AppStorageHelper.get(AppStorageKey.PAGE_BIND_DIALOG_PARAM);
    if (bindParam !== undefined && bindParam !== null) {
      HiLog.info(TAG, 'when menu disappear but bindDialog is not null, need send response for dialog');
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_DIALOG,
        UIResponseCode.RESPONSE_TYPE_DIALOG_CLEAN, bindParam, undefined, undefined);
      getContext(this).getApplicationContext().eventHub.emit(EventHub.TO_CLOSE_DIALOG);
    }
  }

  aboutToAppear(): void {
    HiLog.info(TAG, 'aboutToAppear');
    this.subscribeMessageFromAppService();
    this.isAcceptUsersInput = true;
    this.getSlotIdAndUpParam();
  }

  private getMainMenuAndUpDate(): void {
    if (this.slotId === undefined) {
      HiLog.error(TAG, 'getMainMenuAndUpDate slotId is empty');
      return;
    }
    UpParamsCacheUtils.getInstance().getMainMenuParams(getContext(this), this.slotId).then(
      (result: BaseUpParams | undefined) => {
      if (result) {
        this.updateMenu(result);
      } else {
        HiLog.error(TAG, 'mainMenu param is empty');
      }
    });
  }

  private updateMenu(upParams: BaseUpParams | undefined): void {
    this.isShowMenu = false;
    if (!upParams) {
      HiLog.error(TAG, `updateMenu is empty`);
      return;
    }
    HiLog.info(TAG, `updateMenu ${upParams?.commandType}`);
    this.title = UiUtils.getPageTitle(getContext(this), upParams.slotId);
    this.curUpParam = upParams;
    this.commandType = upParams.commandType;
    if (this.menuItems.length !== 0) {
      this.menuItems.splice(0, this.menuItems.length);
    }
    if (upParams.commandType === CommandType.SET_UP_MENU) {
      let mainMenu = upParams as SetUpMenuParam;
      this.menuList = mainMenu.itemArray;
      if (mainMenu.isHelpAvailable) {
        this.menuItems.push(NavCallBackType.HELP);
      }
      this.defaultItem = 0;
    } else if (upParams.commandType === CommandType.SELECT_ITEM) {
      let selectMenu = upParams as SelectItemParam;
      this.menuList = selectMenu.itemArray;
      this.defaultItem = selectMenu.defaultItemId;
      if (selectMenu.menuTitle) {
        this.title = selectMenu.menuTitle;
      }
      this.menuItems.push(NavCallBackType.END_SESSION);
      if (selectMenu.isHelpAvailable) {
        this.menuItems.push(NavCallBackType.HELP);
      }
    } else {
      HiLog.error(TAG, 'updateMenu BaseUpParams commandType is error');
    }
    this.isTerminalResponse = true;
    if (this.commandType === CommandType.SELECT_ITEM && this.curUpParam) {
      this.startSelectItemMenuTimeOut();
    }
  }

  private getSlotIdAndUpParam(): void {
    HiLog.info(TAG, 'getSlotIdAndUpParam');
    let params = router.getParams();
    if (params) {
      let slotIdAndParam = params as SlotIdAndParam;
      this.slotId = slotIdAndParam.slotId;
      this.curUpParam = slotIdAndParam.upParam;
      HiLog.info(TAG,
        `getSlotIdAndUpParam commandType: ${this.curUpParam === undefined ? 0 : this.curUpParam.commandType}`);
    } else {
      this.slotId = LocalStorage.getShared().get(LocalStorageKey.SLOT_ID);
      this.curUpParam = LocalStorage.getShared().get(LocalStorageKey.UP_PARAM + this.slotId);
    }
  }

  private helpClick(): void {
    HiLog.info(TAG, `helpClick defaultItem:${this.defaultItem}`);
    if (this.menuList && this.defaultItem >= 0 && this.defaultItem < this.menuList.length) {
      let defaultItemContent = this.menuList[this.defaultItem];
      let uiMenuData = new UiMenuResponseData(defaultItemContent.itemId, true);
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU, UIResponseCode.RESPONSE_TYPE_MENU,
        this.curUpParam, uiMenuData, undefined);
    } else {
      this.isAcceptUsersInput = true;
    }
  }

  private toolBarClick(type: NavCallBackType): void {
    HiLog.info(TAG, `toolBarClick type:${type}, isAcceptUsersInput:${this.isAcceptUsersInput}`);
    if (!this.isAcceptUsersInput) {
      return;
    }
    this.isTerminalResponse = false;
    if (this.commandType === CommandType.SET_UP_MENU) {
      if (type === NavCallBackType.HELP) {
        this.helpClick();
        this.isAcceptUsersInput = false;
      } else if (type === NavCallBackType.BACK) {
        CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
      }
    } else if (this.commandType === CommandType.SELECT_ITEM) {
      this.selectItemToolBarClick(type);
    } else {
      HiLog.error(TAG, 'toolBarClick BaseUpParams commandType is error');
    }
  }

  private selectItemToolBarClick(type: NavCallBackType): void {
    this.stopSelectItemMenuTimeOut();
    switch (type) {
      case NavCallBackType.BACK:
        this.isSelectItemBack = true;
        SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU,
          UIResponseCode.RESPONSE_TYPE_BACKWARD, this.curUpParam, undefined, undefined);
        this.isRouterBack();
        break;
      case NavCallBackType.HELP:
        this.helpClick();
        this.isAcceptUsersInput = false;
        break;
      case NavCallBackType.END_SESSION:
        SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU,
          UIResponseCode.RESPONSE_TYPE_END_SESSION, this.curUpParam, undefined, undefined);
        CommonUtils.terminateSelfCust(ContextStorageHelper.getInstance().getEntryUiContext());
        break;
      default:
        break;
    }
  }

  private isRouterBack(): void {
    if (this.slotId === undefined) {
      return;
    }
    let mainMenuParam = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(this.slotId);
    if (!mainMenuParam) {
      CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
    }
  }

  private menuItemClick(itemId: number): void {
    HiLog.info(TAG, `menuItemClick click itemId:${itemId}}`);
    if (!this.isAcceptUsersInput) {
      HiLog.error(TAG, 'menuItemClick current not accept user select');
      return;
    }
    this.isTerminalResponse = false;
    this.isAcceptUsersInput = false;
    this.stopSelectItemMenuTimeOut();
    let uiMenuData = new UiMenuResponseData(itemId, false);
    SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_MENU, UIResponseCode.RESPONSE_TYPE_MENU,
      this.curUpParam, uiMenuData, undefined);
  }

  private getItemPadding(): Resource {
    if (this.fontSizeScale < FontSizeScaleLevel.LEVEL1) {
      return $r('app.float.wh_12');
    } else if (this.fontSizeScale < FontSizeScaleLevel.LEVEL2) {
      return $r('app.float.wh_16');
    } else if (this.fontSizeScale < FontSizeScaleLevel.LEVEL3) {
      return $r('app.float.wh_20');
    } else {
      return $r('app.float.wh_24');
    }
  }

  @Styles
  normalStyles() {
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles() {
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('sys.color.interactive_click'))
  }

  build() {
    Column() {
      NavBack({
        headName: this.title,
        menuItems: $menuItems,
        isShowMenu: $isShowMenu,
        callBack: (type: NavCallBackType) => {
          this.toolBarClick(type);
        }
      })
      GridRow({ columns: { sm: 4, md: 8, lg: 12 } }) {
        GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
          Column() {
            List() {
              ForEach(this.menuList, (item: ItemContent, index?: number) => {
                ListItem() {
                  Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
                    Text(item.itemText)
                      .draggable(false)
                      .fontSize($r('app.float.font_16'))
                      .fontWeight(FontWeight.Medium)
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontColor([$r('sys.color.icon_secondary')])
                      .fontSize($r('app.float.wh_24'))
                      .margin({ start: LengthMetrics.resource($r('app.float.wh_24')) })
                      .opacity(0.4)
                  }
                  .accessibilityGroup(true)
                  .id(`${ViewId.INDEX_PAGE_ITEM_PRE}${index}`)
                  .padding({
                    left: $r('app.float.wh_8'),
                    right: $r('app.float.wh_8'),
                    top: this.getItemPadding(),
                    bottom: this.getItemPadding()
                  })
                  .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                  })
                  .onClick(() => {
                    this.menuItemClick(item.itemId);
                  })
                }
              })
            }
            .divider({
              strokeWidth: 0.5,
              color: $r('sys.color.comp_divider'),
              startMargin: $r('app.float.wh_8'),
              endMargin: $r('app.float.wh_8')
            })
            .scrollBar(BarState.Off)
            .padding($r('app.float.wh_4'))
          }
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius($r('sys.float.corner_radius_level8'))
          .margin({ top: $r('app.float.wh_8'), bottom: $r('app.float.wh_48') })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ left: $r('app.float.cust_padding'), right: $r('app.float.cust_padding') })
  }
}
