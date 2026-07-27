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
import { router, window } from '@kit.ArkUI';
import HiLog from '../common/utils/HiLog';
import UiUtils from '../common/utils/UiUtils';
import NavBack, { NavCallBackType } from '../common/components/NavBack';
import { CommandType, UIResponseCode } from '../common/constant/SimToolKitConstant';
import { GetInkeyInputParam } from '../model/upDecode/GetInkeyInputParam';
import { SlotIdAndParam } from '../model/upDecode/BaseUpParams';
import { SimToolKitAppService } from '../model/SimToolKitAppService';
import { FromPageFlag, UiInputResponseData } from '../model/UIResponseData';
import { LocalStorageKey, TimeOut, ViewId } from '../common/constant/Constants';
import { AccessibilityUtils } from '../common/utils/AccessibilityUtils';
import CommonUtils from '../common/utils/CommonUtils';
import { CustTimeOutHelper } from '../common/helper/CustTimeOutHelper';
import { AppStorageKey } from '../common/helper/AppStorageHelper';

const TAG: string = 'SimToolKitInput';
const UCS2_MAX_LEN_LIMIT: number = 70;
const PACK_MAX_LEN_LIMIT: number = 160;
const UNPACK_MAX_LEN_LIMIT: number = 160;
const DIGIT_ONLY_REGULAR: string = '[0-9*#+]';
const BIG_FONT_SCALE_SIZE: number = 2;
const BUTTON_TEXT_FONT_SIZE: number = 16;
const BUTTON_TEXT_MARGE: number = 52;
const WIDTH_COMPARE_SIZE: number = 5;

class AvoidAreaParam {
  public type?: window.AvoidAreaType;
  public area?: window.AvoidArea;
}

enum InkeyInputStatus {
  STATE_YES_NO,
  STATE_TEXT
}

@Entry
@Component
struct SimToolKitInput {
  @State title: string = '';
  @State menuItems: Array<NavCallBackType> = [];
  @State isDigitOnly: boolean = false;
  @State status: InkeyInputStatus = InkeyInputStatus.STATE_TEXT;
  @State inputDesc: string = '';
  @State input: string = '';
  @State inTypeValueAndSize: string = '';
  @State isConfirmButtonEnable: boolean = false;
  @State textInputType: InputType = InputType.NEW_PASSWORD;
  @State isShowCancelButton: boolean = true;
  @State minLength: number = 1;
  @State maxLength: number = 1;
  @State scrollHeight: number = 0;
  @State isShowMenu: boolean = false;
  @State isSecondButton: boolean = false;
  @StorageProp(AppStorageKey.FONT_SIZE_SCALE_KEY) fontSizeScale: number = 1;
  private scroller: Scroller = new Scroller();
  private slotId?: number;
  private inkeyInputParam?: GetInkeyInputParam;
  private inputTimeOut?: number;
  // page aboutToDisappear end session
  private isTerminalResponse: boolean = true;

  private startInputTimeOut(): void {
    HiLog.info(TAG, 'startInputTimeOut');
    this.stopInputTimeOut();
    let duration: number = (this.inkeyInputParam === undefined ||
      this.inkeyInputParam === null) ? 0 : this.inkeyInputParam.duration;
    if (duration <= 0) {
      duration = TimeOut.TIME_UNIT_MINUTE;
    }
    this.inputTimeOut = CustTimeOutHelper.getInstance().setTimeOutCust(() => {
      this.isTerminalResponse = false;
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT,
        UIResponseCode.RESPONSE_TYPE_TIMEOUT, this.inkeyInputParam, undefined, undefined);
      CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
    }, duration);
  }

  private stopInputTimeOut(): void {
    if (this.inputTimeOut !== undefined) {
      HiLog.info(TAG, 'stopInputTimeOut');
      clearTimeout(this.inputTimeOut);
      this.inputTimeOut = undefined;
    }
  }

  private handleCommandResponse(isConfirm: boolean, input: string, isHelper: boolean): void {
    let inputResponseData = new UiInputResponseData(isConfirm, input, isHelper);
    SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT, UIResponseCode.RESPONSE_TYPE_INPUT,
      this.inkeyInputParam, undefined, inputResponseData);
  }

  private buttonClick(isConfirm: boolean, input: string): void {
    if (this.status === InkeyInputStatus.STATE_TEXT) {
      if (isConfirm) {
        this.handleCommandResponse(true, input, false);
      } else {
        SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT,
          UIResponseCode.RESPONSE_TYPE_END_SESSION, this.inkeyInputParam, undefined, undefined);
      }
    } else {
      // yes no
      this.handleCommandResponse(isConfirm, '', false);
    }
    this.stopInputTimeOut();
    this.isTerminalResponse = false;
    CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
  }

  private toolBarClick(type: NavCallBackType): void {
    switch (type) {
      case NavCallBackType.BACK:
        SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT,
          UIResponseCode.RESPONSE_TYPE_BACKWARD, this.inkeyInputParam, undefined, undefined);
        break;
      case NavCallBackType.HELP:
        this.handleCommandResponse(false, '', true);
        break;
      case NavCallBackType.END_SESSION:
        SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT,
          UIResponseCode.RESPONSE_TYPE_END_SESSION, this.inkeyInputParam, undefined, undefined);
        break;
      default:
        break;
    }
    this.stopInputTimeOut();
    this.isTerminalResponse = false;
    CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
  }

  onPageShow(): void {
    if (this.inkeyInputParam) {
      this.startInputTimeOut();
    }
  }

  onPageHide(): void {
    this.isShowMenu = false;
  }

  aboutToAppear(): void {
    HiLog.info(TAG, 'aboutToAppear');
    this.setPrivacyModeAndRouteBack(true);
    this.getSlotIdAndUpParam();
    if (this.slotId === undefined || this.inkeyInputParam === undefined) {
      HiLog.error(TAG, 'aboutToAppear param is error');
      CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
      return;
    }
    this.title = UiUtils.getPageTitleInput(getContext(this) as common.UIAbilityContext, this.slotId);
    let commandType = this.inkeyInputParam.commandType;
    if (commandType === CommandType.GET_INKEY) {
      this.status = this.inkeyInputParam.isYesNo ? InkeyInputStatus.STATE_YES_NO : InkeyInputStatus.STATE_TEXT;
      this.input = '';
      this.textInputType = this.getTextInputType(true);
    } else {
      this.status = InkeyInputStatus.STATE_TEXT;
      this.input = this.inkeyInputParam.defaultText;
      this.textInputType = this.getTextInputType(this.inkeyInputParam.isEcho);
    }
    this.inputDesc = this.inkeyInputParam.text;
    this.isDigitOnly = this.inkeyInputParam.isDigitOnly;
    if (this.status === InkeyInputStatus.STATE_TEXT) {
      this.getInTypeValueAndSizeFormInput(this.inkeyInputParam);
      this.isConfirmButtonEnable = this.minLength === 0;
    } else {
      this.inTypeValueAndSize = '';
      this.minLength = 1;
      this.maxLength = 1;
      this.isShowCancelButton = true;
      this.isConfirmButtonEnable = true;
    }
    if (this.menuItems.length !== 0) {
      this.menuItems.splice(0, this.menuItems.length);
    }
    this.menuItems.push(NavCallBackType.END_SESSION);
    if (this.inkeyInputParam.isHelpAvailable) {
      this.menuItems.push(NavCallBackType.HELP);
    }
    this.windowKeyInput();
  }

  private getTextInputType(isEcho: boolean): InputType {
    return AccessibilityUtils.getInstance().isStartAccessibility() ?
    InputType.NEW_PASSWORD : (isEcho ? InputType.Normal : InputType.NEW_PASSWORD);
  }

  private getInTypeValueAndSizeFormInput(inputParam: GetInkeyInputParam): void {
    let inTypeValue = inputParam.isDigitOnly ? this.getStringFormResource($r('app.string.digits')) :
    this.getStringFormResource($r('app.string.alphabet'));
    let maxLen = inputParam.responseMaxLength;
    if (inputParam.isUcs2 && maxLen > UCS2_MAX_LEN_LIMIT) {
      HiLog.info(TAG, `the maxLen:${maxLen} > UCS2_MAX_LEN_LIMIT:${UCS2_MAX_LEN_LIMIT}`);
      maxLen = UCS2_MAX_LEN_LIMIT;
    } else if (inputParam.isPacked && maxLen > PACK_MAX_LEN_LIMIT) {
      HiLog.info(TAG, `the maxLen:${maxLen} > PACK_MAX_LEN_LIMIT:${PACK_MAX_LEN_LIMIT}`);
      maxLen = PACK_MAX_LEN_LIMIT;
    } else if (!inputParam.isPacked && maxLen > UNPACK_MAX_LEN_LIMIT) {
      HiLog.info(TAG, `the maxLen:${maxLen} > UNPACK_MAX_LEN_LIMIT:${UNPACK_MAX_LEN_LIMIT}`);
      maxLen = UNPACK_MAX_LEN_LIMIT;
    } else {
      HiLog.info(TAG, 'default maxLen');
    }
    this.maxLength = maxLen;
    let lengthLimit = inputParam.responseMinLength.toString();
    if (maxLen !== inputParam.responseMinLength) {
      lengthLimit = lengthLimit + '-' + maxLen;
    }
    this.minLength = inputParam.responseMinLength;
    this.maxLength = maxLen;
    this.inTypeValueAndSize = `${inTypeValue} ${lengthLimit}`;
  }

  private getStringFormResource(str: Resource): string {
    try {
      return (getContext(this) as common.UIAbilityContext)?.resourceManager?.getStringSync(str.id);
    } catch (error) {
      HiLog.error(TAG, `getStringFormResource failed. Error code: ${error?.code}, message: ${error?.message}`);
      return '';
    }
  }

  private getSlotIdAndUpParam(): void {
    HiLog.info(TAG, 'getSlotIdAndUpParam');
    let params = router.getParams();
    if (params) {
      let slotIdAndParam = params as SlotIdAndParam;
      this.slotId = slotIdAndParam.slotId;
      this.inkeyInputParam = slotIdAndParam.upParam as GetInkeyInputParam;
      HiLog.info(TAG, `getSlotIdAndUpParam commandType:${this.inkeyInputParam?.commandType}`);
    } else {
      this.slotId = LocalStorage.getShared().get(LocalStorageKey.SLOT_ID);
      this.inkeyInputParam = LocalStorage.getShared().get(LocalStorageKey.UP_PARAM + this.slotId);
    }
  }

  onBackPress?(): void | boolean {
    HiLog.info(TAG, 'onBackPress');
    SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT,
      UIResponseCode.RESPONSE_TYPE_BACKWARD, this.inkeyInputParam, undefined, undefined);
    this.isTerminalResponse = false;
    CommonUtils.pageBackOrExit(getContext(this) as common.UIAbilityContext);
    return true;
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, `aboutToDisappear isTerminalResponse:${this.isTerminalResponse}`);
    this.setPrivacyModeAndRouteBack(false);
    this.stopInputTimeOut();
    if (this.isTerminalResponse) {
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_INPUT,
        UIResponseCode.RESPONSE_TYPE_END_SESSION, this.inkeyInputParam, undefined, undefined);
    }
  }

  private setPrivacyModeAndRouteBack(isPrivacyMode: boolean): void {
    window.getLastWindow(getContext(this) as common.UIAbilityContext).then((lastWindow: window.Window) => {
      if (lastWindow) {
        lastWindow.setWindowPrivacyMode(isPrivacyMode);
      }
    });
  }

  private windowKeyInput(): void {
    window.getLastWindow(getContext(this)).then((currentWindow: window.Window) => {
      this.updateHeight(currentWindow);
      this.areaAndSizeChange(currentWindow);
    });
  }

  private areaAndSizeChange(currentWindow: window.Window): void {
    try {
      // monitor the hiding and display of softKeyboard
      currentWindow.on('avoidAreaChange', (data: AvoidAreaParam) => {
        if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
          this.updateHeight(currentWindow);
        }
      });

      currentWindow.on('windowSizeChange', (size: window.Size) => {
        this.updateHeight(currentWindow);
      });
    } catch (error) {
      HiLog.error(TAG, `areaAndSizeChange failed. Error code: ${error?.code}, message: ${error?.message}`);
    }
  }

  private updateHeight(currentWindow: window.Window): void {
    // init window height
    let windowHeight: number = currentWindow.getWindowProperties().windowRect.height;
    let statusBarHeight = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height;
    let navBarHeight = currentWindow.getWindowAvoidArea(
      window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height;
    let keyboardWindowHeight = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height;
    this.scrollHeight = px2vp(windowHeight - keyboardWindowHeight - statusBarHeight - navBarHeight);

    if (keyboardWindowHeight !== 0) {
      let offsetResult = this.scroller.currentOffset();
      if (CommonUtils.isEmptyObj(offsetResult)) {
        return;
      }
      let scrollY = this.getUIContext()
        .getComponentUtils()
        .getRectangleById(ViewId.INPUT_PAGE_TEXT_INPUT)
        .size
        .height;
      this.scroller.scrollTo({ xOffset: 0, yOffset: offsetResult.yOffset + px2vp(scrollY) });
    }
  }

  @Builder
  bottomButton() {
    Flex({
      direction: FlexDirection.Row,
      wrap: this.isSecondButton ? FlexWrap.Wrap : FlexWrap.WrapReverse,
      justifyContent: FlexAlign.SpaceBetween
    }) {
      Button({ stateEffect: this.isConfirmButtonEnable }) {
        Text((this.status === InkeyInputStatus.STATE_TEXT ? $r('app.string.confirm') : $r('app.string.button_yes')))
          .draggable(false)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('app.float.font_16'))
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .maxFontScale(BIG_FONT_SCALE_SIZE)
      }
      .draggable(false)
      .enabled(this.isConfirmButtonEnable)
      .opacity(this.isConfirmButtonEnable ? 1 : $r('sys.float.alpha_tertiary'))
      .id(ViewId.INPUT_PAGE_CONFIRM)
      .borderRadius($r('app.float.wh_20'))
      .padding($r('app.float.wh_10'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .constraintSize({ minWidth: this.isSecondButton ? '100%' : 'calc(50% - 6vp)' })
      .onClick(() => {
        if (this.isConfirmButtonEnable) {
          this.buttonClick(true, this.input);
        }
      })

      if (this.isShowCancelButton) {
        if (!this.isSecondButton) {
          Column().width($r('app.float.wh_12'))
        }
        Button() {
          Text(this.status === InkeyInputStatus.STATE_TEXT ? $r('app.string.cancel') : $r('app.string.button_no'))
            .draggable(false)
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .maxFontScale(BIG_FONT_SCALE_SIZE)
        }
        .draggable(false)
        .id(ViewId.INPUT_PAGE_CANCEL)
        .borderRadius($r('app.float.wh_20'))
        .padding($r('app.float.wh_10'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.buttonClick(false, '');
        })
        .margin({
          top: this.isSecondButton ? $r('app.float.wh_12') : 0
        })
        .constraintSize({ minWidth: this.isSecondButton ? '100%' : 'calc(50% - 6vp)' })
      }
    }
    .margin({ top: $r('app.float.wh_12'), bottom: $r('app.float.wh_12') })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.isSecondButton =
        (newValue.width as number - BUTTON_TEXT_MARGE - WIDTH_COMPARE_SIZE) < this.getMaxWidth() * 2;
    })
  }

  private getMaxWidth(): number {
    let result: number;
    if (this.status === InkeyInputStatus.STATE_TEXT) {
      result = Math.max(this.getTextWidthVp($r('app.string.confirm')), this.getTextWidthVp($r('app.string.cancel')));
    } else {
      result =
        Math.max(this.getTextWidthVp($r('app.string.button_yes')), this.getTextWidthVp($r('app.string.button_no')));
    }
    return result;
  }

  private getTextWidthVp(textResource: Resource): number {
    let sizePx = vp2px(BUTTON_TEXT_FONT_SIZE) * (Math.min(this.fontSizeScale, BIG_FONT_SCALE_SIZE))
    let buttonWidthPx = this.getUIContext()
      .getMeasureUtils()
      .measureTextSize({
        textContent: textResource,
        fontSize: `${sizePx}px`
      })
      .width as number;
    return px2vp(buttonWidthPx);
  }

  @Builder
  textInputCard() {
    Column() {
      Text(this.inputDesc)
        .draggable(false)
        .fontSize($r('app.float.font_14'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: $r('app.float.wh_28') })
        .alignSelf(ItemAlign.Start)
      if (this.status === InkeyInputStatus.STATE_TEXT) {
        TextInput({ text: this.input })
          .draggable(false)
          .onChange((inputString: string) => {
            this.isConfirmButtonEnable = inputString.length >= this.minLength;
            this.input = inputString;
            this.startInputTimeOut();
          })
          .inputFilter(this.isDigitOnly ? DIGIT_ONLY_REGULAR : '')
          .type(this.textInputType)
          .maxLength(this.maxLength)
          .enterKeyType(EnterKeyType.Done)
          .copyOption(CopyOptions.None)
          .width('100%')
          .backgroundColor($r('sys.color.comp_background_primary'))
          .fontSize($r('app.float.font_16'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: $r('app.float.wh_8') })
          .id(ViewId.INPUT_PAGE_TEXT_INPUT)

        Text(this.inTypeValueAndSize)
          .draggable(false)
          .fontSize($r('app.float.font_10'))
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ left: $r('app.float.wh_12'), right: $r('app.float.wh_12'), top: $r('app.float.wh_8') })
          .alignSelf(ItemAlign.Start)
      }
    }
    .width('100%')
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
      Column() {
        GridRow({ columns: { sm: 4, md: 8, lg: 12 } }) {
          GridCol({ span: { sm: 4, md: 6, lg: 8 }, offset: { sm: 0, md: 1, lg: 2 } }) {
            Scroll(this.scroller) {
              Column() {
                this.textInputCard()
                this.bottomButton()
              }
              .width('100%')
              .height('auto')
              .constraintSize({ minHeight: '100%' })
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .align(Alignment.TopStart)
            .scrollBar(BarState.Off)
            .width('100%')
            .height('100%')
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height(this.scrollHeight)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ left: $r('app.float.cust_padding'), right: $r('app.float.cust_padding') })
    .expandSafeArea([SafeAreaType.KEYBOARD])
  }
}

