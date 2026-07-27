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
import { i18n } from '@kit.LocalizationKit';
import { BusinessError, commonEventManager, osAccount } from '@kit.BasicServicesKit';
import HiLog from '../common/utils/HiLog';
import CommonUtils from '../common/utils/CommonUtils';
import UiUtils from '../common/utils/UiUtils';
import NotificationUtils from '../common/utils/NotificationUtils';
import TonePlayer from '../common/utils/TonePlayer';
import { SetUpEventListParam } from './upDecode/SetUpEventListParam';
import { LaunchBrowserParam } from './upDecode/LaunchBrowserParam';
import { PlayToneParam } from './upDecode/PlayToneParam';
import { SendAboutParam } from './upDecode/SendAboutParam';
import { SetUpCallParam } from './upDecode/SetUpCallParam';
import { SetUpIdleModeTextParam } from './upDecode/SetUpIdleModeTextParam';
import { DisplayTextParam } from './upDecode/DisplayTextParam';
import { GetInkeyInputParam } from './upDecode/GetInkeyInputParam';
import { LanguageNotificationParam } from './upDecode/LanguageNotificationParam';
import { ProvideLocalInformationParam } from './upDecode/ProvideLocalInformationParam';
import { UiMenuResponseData, UiInputResponseData } from './UIResponseData';
import { SetUpMenuParam } from './upDecode/SetUpMenuParam';
import { ProvideLocalInformationMode } from './upDecode/ProvideLocalInformationParam';
import { sharedPreferencesUtils } from '../common/utils/SharedPreferencesUtils';
import { FromPageFlag } from './UIResponseData';
import { BaseUpParams } from './upDecode/BaseUpParams';
import { WorkerManager } from '../workers/WorkerManager';
import { SimToolKitResponseManager } from './SimToolKitResponseManager';
import { DefaultResponseData } from './responseData/terminalResponseData/DefaultResponseData';
import { MenuSelectionEnvelopeData } from './responseData/envelopeData/MenuSelectionEnvelopeData';
import { SelectItemResponseData } from './responseData/terminalResponseData/SelectItemResponseData';
import { InputInkeyResponseData } from './responseData/terminalResponseData/InputInkeyResponseData';
import { DateTimeResponseData } from './responseData/terminalResponseData/DateTimeResponseData';
import { LanguageResponseData } from './responseData/terminalResponseData/LanguageResponseData';
import { UpParamsCacheUtils } from '../common/utils/UpParamsCacheUtils';
import { AppStorageHelper, AppStorageKey } from '../common/helper/AppStorageHelper';
import { BipResponseCode,
  CommandType,
  ExResponseInfo,
  ResponseCode,
  SESSION_END,
  UIResponseCode } from '../common/constant/SimToolKitConstant';
import LanguageUtils from '../common/utils/LanguageUtils';
import { DisplayAndIdleTextHelper } from '../common/helper/DisplayAndIdleTextHelper';
import { NewIdleScreenHelper } from '../common/helper/NewIdleScreenHelper';
import { BackgroundTaskRequestUtils } from '../common/utils/BackgroundTaskRequestUtils';
import { CustTimeOutHelper } from '../common/helper/CustTimeOutHelper';
import { SettingsDataHelper } from '../common/helper/SettingsDataHelper';
import { AllBipParam } from './upDecode/AllBipParam';
import { BipResponseData } from './responseData/terminalResponseData/BipResponseData';
import { SetUpEventListHelper } from '../common/helper/SetUpEventListHelper';
import entranceHelper from '../common/helper/EntranceHelper';
import { Report } from '../common/utils/Report';
import { EventHub, HapInfo, PageUrl, SetupEventKey, SimId, TimeOut } from '../common/constant/Constants';
import { LanguageNotificationHelper } from './upDecode/LanguageNotificationHelper';

const TAG = 'SimToolKitAppService';

const START_ABILITY_RETRY_NUMBER = 30;
const START_ABILITY_RETRY_DELAY = 1000;
const SLOT_ID_ONE = 0;
const SLOT_ID_TWO = 1;
const URL_PREFIX_HTTP = 'http://';
const URL_PREFIX_HTTPS = 'https://';
const REFRESH_RESULT_INIT = 1; // The Icc has been initialized
const REFRESH_RESULT_RESET = 2; // The Icc was reset

export class SimToolKitAppService {
  private static instance: SimToolKitAppService | undefined = undefined;
  private delayQueueMap: Map<number, Array<BaseUpParams>> = new Map<number, Array<BaseUpParams>>();
  private currentLaunchBrowserParamMap: Map<number, LaunchBrowserParam | undefined> =
    new Map<number, LaunchBrowserParam | undefined>();
  private mCurCmd: Array<BaseUpParams | undefined> = [undefined, undefined];
  private mIsInProgressing: Array<boolean> = [false, false];
  private mMenuClickTimeOut: Array<number | undefined> = [undefined, undefined];
  private uiContext?: common.UIAbilityContext;
  private serviceContext?: common.ServiceExtensionContext;
  private isMainOsAccount: boolean = true;
  private isMainOsAccountAlready: boolean = false;

  public static getInstance(): SimToolKitAppService {
    if (!SimToolKitAppService.instance) {
      HiLog.info(TAG, 'SimToolKitAppService getInstance init');
      SimToolKitAppService.instance = new SimToolKitAppService();
      SimToolKitAppService.instance.reset();
    }
    return SimToolKitAppService.instance;
  }

  public setUiContext(context: common.UIAbilityContext | undefined): void {
    this.uiContext = context;
  }

  public setServiceContext(context: common.ServiceExtensionContext | undefined): void {
    this.serviceContext = context;
  }

  public async endSessionCurrentCmd(): Promise<void>{
    HiLog.info(TAG, 'endSessionCurrentCmd');
    if (CommonUtils.isEmptyObj(this.uiContext) && CommonUtils.isEmptyObj(this.serviceContext)) {
      this.manualEndSession(0);
      this.manualEndSession(1);
      NewIdleScreenHelper.getInstance().unRegisterIdleScreenListenerForcible();
      await Report.getInstance().reportCbsEvent();
    }
  }

  private checkMsgHaveResponse(commandType: number): boolean {
    switch (commandType) {
      case CommandType.SEND_DTMF:
      case CommandType.SEND_SMS:
      case CommandType.REFRESH:
      case CommandType.SEND_SS:
      case CommandType.SEND_USSD:
      case CommandType.CLOSE_CHANNEL:
      case CommandType.RECEIVE_DATA:
      case CommandType.SEND_DATA:
      case CommandType.GET_CHANNEL_STATUS:
        return false;
    }
    return true;
  }

  private checkManualEndSessionType(commandType: number | undefined): boolean {
    if (commandType === undefined || commandType === CommandType.SET_UP_MENU ||
      commandType === CommandType.OPEN_CHANNEL) {
      return false;
    }
    return this.checkMsgHaveResponse(commandType);
  }

  private manualEndSession(slotId: number): void {
    NotificationUtils.clearNotification(slotId, true);
    HiLog.info(TAG,
      `current on sim:${slotId}, paramsType:${this.mCurCmd[slotId]?.commandType}, mIsInProgressing:${this.mIsInProgressing[slotId]}`);
    if (!CommonUtils.isEmptyObj(this.mCurCmd[slotId] && this.mIsInProgressing[slotId])) {
      if (this.checkManualEndSessionType(this.mCurCmd[slotId]?.commandType)) {
        HiLog.info(TAG, `manualEndEndSession current on sim:${slotId} need manual end session`);
        let data = new DefaultResponseData(this.mCurCmd[slotId],
          ResponseCode.UICC_SESSION_TERM_BY_USER);
        SimToolKitResponseManager.getInstance().sendTerminalResponseData(data);
      }
    }
  }

  private reset(slotId?: number): void {
    HiLog.info(TAG, `reset All Params for AppService slotId:${slotId}`);
    if (slotId === SimId.SLOT_ID_0 || slotId === SimId.SLOT_ID_1) {
      this.mIsInProgressing[slotId] = false;
      this.mCurCmd[slotId] = undefined;
      this.delayQueueMap.set(slotId, []);
      UpParamsCacheUtils.getInstance().deleteMainMenuParams(this.serviceContext, slotId);
      UpParamsCacheUtils.getInstance().deleteCurrentUpParams(this.serviceContext, slotId);
      entranceHelper.checkIsHaveMainMenu(this.serviceContext, slotId);
    } else {
      this.mIsInProgressing = [false, false];
      this.mCurCmd = [undefined, undefined];
      this.delayQueueMap.set(SLOT_ID_ONE, []);
      this.delayQueueMap.set(SLOT_ID_TWO, []);
    }
  }

  public callBackFromService(parameters: Record<string, Object>, event: string): void {
    HiLog.info(TAG, 'callBackFromService');
    BackgroundTaskRequestUtils.getInstance()
      .applyEfficiencyResourcesGreaterThanPre(BackgroundTaskRequestUtils.DELAY_TIME_MILLISECONDS_10);
    let slotId = this.getNumberFormParameters(parameters, 'slotId');
    if (slotId === undefined) {
      HiLog.error(TAG, 'callBackFromService slotId is empty');
      return;
    }
    if (slotId !== SLOT_ID_ONE && slotId !== SLOT_ID_TWO) {
      HiLog.error(TAG, 'callBackFromService slotId is not 0 or 1');
      return;
    }
    this.isMainOsAccountInner().then((isMainOsAccount: boolean) => {
      if (slotId === undefined) {
        return;
      }
      if (isMainOsAccount) {
        // to check or load mainMenu data.
        UpParamsCacheUtils.getInstance().getMainMenuParams(this.serviceContext, slotId).then(value => {
          if (slotId !== undefined) {
            this.toDistributeMainUser(slotId, event, parameters);
          }
        });
      } else {
        if (slotId !== undefined) {
          this.toDistributeSubUser(slotId, event, parameters);
        }
      }
    });
  }

  private async isMainOsAccountInner(): Promise<boolean> {
    if (this.isMainOsAccountAlready) {
      HiLog.info(TAG, `isMainOsAccountInner already:${this.isMainOsAccountAlready}, isMain:${this.isMainOsAccount}`);
      return Promise.resolve(this.isMainOsAccount);
    }
    try {
      this.isMainOsAccount = (await osAccount.getAccountManager().getForegroundOsAccountLocalId()) === 100;
      this.isMainOsAccountAlready = true;
    } catch (error) {
      HiLog.error(TAG, 'isMainOsAccountInner error');
    }
    HiLog.info(TAG, `isMainOsAccountInner isMain:${this.isMainOsAccount}`);
    return Promise.resolve(this.isMainOsAccount);
  }

  private toDistributeSubUser(slotId: number, event: string, parameters: Record<string, Object>): void {
    if (event === commonEventManager.Support.COMMON_EVENT_STK_SESSION_END) {
      SettingsDataHelper.getInstance().setSubUserSimAbsent(this.serviceContext, true);
      SettingsDataHelper.getInstance().setSubUserSimRefresh(this.serviceContext, true);
    } else if (event === commonEventManager.Support.COMMON_EVENT_STK_ALPHA_IDENTIFIER) {
      HiLog.info(TAG, 'toDistributeSubUser not parse');
    } else if (event === commonEventManager.Support.COMMON_EVENT_STK_CARD_STATE_CHANGED) {
      let cardStatus = this.getNumberFormParameters(parameters, 'cardStatus');
      if (cardStatus !== 1) {
        this.reset(slotId);
        SettingsDataHelper.getInstance().setSubUserSimAbsent(this.serviceContext, true);
        SettingsDataHelper.getInstance().setSubUserSimRefresh(this.serviceContext, true);
        CommonUtils.terminateSelfCust(this.uiContext);
      }
    } else if (event === commonEventManager.Support.COMMON_EVENT_STK_COMMAND) {
      this.toDistributeSubUserStkCommand(slotId, parameters);
    } else {
      HiLog.debug(TAG, `toDistributeSubUser not subscribe this action:${event}`);
    }
  }

  private toDistributeSubUserStkCommand(slotId: number, parameters: Record<string, Object>): void {
    let msgCmd = this.getStringFormParameters(parameters, 'msgCmd');
    if (!msgCmd) {
      HiLog.error(TAG, 'toDistributeSubUser error');
      return;
    }
    HiLog.info(TAG, `toDistributeSubUser msgCmd:${msgCmd}`);
    WorkerManager.getInstance().sendUpParams(msgCmd, slotId, upParams => {
      if (!upParams || !upParams.isParseCmdDetailSuccess) {
        return;
      }
      if (upParams.commandType === CommandType.SET_UP_MENU) {
        UpParamsCacheUtils.getInstance().putMainMenuParamsMemory(upParams as SetUpMenuParam);
        this.sendDefaultResponseData(upParams,
          this.refreshRespCodeIfLoadIconFailed(upParams, ResponseCode.OK));
        entranceHelper.checkIsHaveMainMenu(this.serviceContext, slotId);
      } else {
        if (!this.checkMsgHaveResponse(upParams.commandType)) {
          return;
        }
        SettingsDataHelper.getInstance().setSubUserSimAbsent(this.serviceContext, true);
        SettingsDataHelper.getInstance().setSubUserSimRefresh(this.serviceContext, true);
        if (upParams.commandType === CommandType.OPEN_CHANNEL) {
          let data = new BipResponseData(slotId, upParams.commandType, BipResponseCode.CONFIRM_REJECT);
          SimToolKitResponseManager.getInstance().sendBipResponseData(data);
        } else {
          this.sendDefaultResponseData(upParams, ResponseCode.TERMINAL_CRNTLY_UNABLE_TO_PROCESS);
        }
      }
    });
  }

  private toDistributeMainUser(slotId: number, event: string, parameters: Record<string, Object>): void {
    switch (event) {
      case commonEventManager.Support.COMMON_EVENT_STK_SESSION_END:
        this.onSessionEndSubscriberCallBack(slotId);
        break;
      case commonEventManager.Support.COMMON_EVENT_STK_ALPHA_IDENTIFIER:
        this.onAlphaIdSubscriberCallBack(this.getStringFormParameters(parameters, 'alphaString'));
        break;
      case commonEventManager.Support.COMMON_EVENT_STK_CARD_STATE_CHANGED:
        let cardStatus = this.getNumberFormParameters(parameters, 'cardStatus');
        let refreshResult = this.getNumberFormParameters(parameters, 'refreshResult');
        this.onCardStatusSubscriberCallBack(slotId, cardStatus, refreshResult);
        break;
      case commonEventManager.Support.COMMON_EVENT_STK_COMMAND:
        this.onCommandSubscriberCallBack(slotId, this.getStringFormParameters(parameters, 'msgCmd'));
        break;
      default:
        HiLog.debug(TAG, `simToolkitSubscriberCallBack not subscribe this action:${event}`);
    }
  }

  private getNumberFormParameters(parameters: Record<string, Object>, key: string): number | undefined {
    if (parameters[key] === undefined || parameters[key] === null) {
      return undefined;
    }
    return (typeof parameters[key]) === 'number' ? parameters[key] as number : undefined;
  }

  private getStringFormParameters(parameters: Record<string, Object>, key: string): string | undefined {
    if (parameters[key] === undefined || parameters[key] === null) {
      return undefined;
    }
    return (typeof parameters[key]) === 'string' ? parameters[key] as string : undefined;
  }

  private onSessionEndSubscriberCallBack(slotId: number): void {
    let upParam = new BaseUpParams();
    upParam.slotId = slotId;
    upParam.commandType = SESSION_END;
    if (this.mIsInProgressing[slotId]) {
      HiLog.info(TAG, `SessionEnd CallBack IsInProgressing is true on slotId:${slotId}`);
      this.delayQueueMap.get(slotId)?.push(upParam);
    } else {
      HiLog.info(TAG, `SessionEnd CallBack set IsInProgressing to false for slotId:${slotId}`);
      this.mIsInProgressing[slotId] = true;
      this.handleUpParamData(upParam);
    }
  }

  private onAlphaIdSubscriberCallBack(alphaString: string | undefined): void {
    if (alphaString && this.serviceContext) {
      UiUtils.showToastFromServiceAbility(this.serviceContext, alphaString);
    } else {
      HiLog.error(TAG, 'onAlphaIdSubscriberCallBack empty');
    }
  }

  private onCardStatusSubscriberCallBack(
    slotId: number, cardStatus: number | undefined, refreshResult: number | undefined): void {
    if (CommonUtils.isEmptyObj(cardStatus)) {
      HiLog.error(TAG, 'onCardStatusSubscriberCallBack slotId/cardStatus is undefined');
      return;
    }
    // ICC_CARD_STATE_ABSENT:0, ICC_CARD_STATE_PRESENT:1
    let isCardPresent: boolean = cardStatus === 1;
    HiLog.info(TAG, `CardStatus Event on slotId:${slotId}  isCardPresent:${isCardPresent}`);
    if (isCardPresent) {
      // PRESENT
      if (refreshResult === REFRESH_RESULT_INIT || refreshResult === REFRESH_RESULT_RESET) {
        // Clear Idle Text
        NotificationUtils.clearNotification(slotId, false);
        sharedPreferencesUtils.deleteToPreferences(this.serviceContext,
          `${SetupEventKey.IDLE_MODE_TEXT_KEY}${slotId}`);
      }
      if (refreshResult === REFRESH_RESULT_RESET) {
        // Uninstall STkmenu
      }
    } else {
      // ABSENT
      NotificationUtils.clearNotification(slotId, false);
      sharedPreferencesUtils.deleteToPreferences(this.serviceContext,
        `${SetupEventKey.IDLE_MODE_TEXT_KEY}${slotId}`);
      this.reset(slotId);
      CommonUtils.terminateSelfCust(this.uiContext);
    }
  }

  private onCommandSubscriberCallBack(slotId: number, msgCmd: string | undefined): void {
    if (!msgCmd) {
      HiLog.error(TAG, 'onCommandSubscriberCallBack error');
      return;
    }
    HiLog.info(TAG, `onCommandSubscriberCallBack msgCmd:${msgCmd}`);
    WorkerManager.getInstance().sendUpParams(msgCmd, slotId, result => {
      if (result) {
        Report.getInstance().addCmdCount(result.commandType, slotId);
      }
      // parse failed
      if (this.processParseFailed(result, slotId)) {
        HiLog.error(TAG, 'parse msgCmd error');
        return;
      }
      if (result) {
        HiLog.info(TAG, 'putCurrentUpParams start');
        UpParamsCacheUtils.getInstance().putCurrentUpParamsMemory(result);
        this.processUpParams(result);
      }
    });
  }

  private processSessionEnd(slotId: number): void {
    NotificationUtils.resetNotifyResponseFromUser(slotId);
    this.uiContext?.eventHub.emit(EventHub.SESSION_END, slotId);
    this.mCurCmd[slotId] = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId);
    this.stopMenuClickTimeOut(slotId);
    HiLog.info(TAG, 'processSessionEnd start main menu start');
    let launchBrowserParam = this.currentLaunchBrowserParamMap.get(slotId);
    if (launchBrowserParam) {
      this.startLaunchBrowser(launchBrowserParam);
      this.currentLaunchBrowserParamMap.set(slotId, undefined);
    }
    this.checkAndPullNextCmd(slotId);
  }

  private isCmdInteractive(commandType: number): boolean {
    switch (commandType) {
      case CommandType.SEND_DTMF:
      case CommandType.SEND_SMS:
      case CommandType.REFRESH:
      case CommandType.SEND_SS:
      case CommandType.SEND_USSD:
      case CommandType.SET_UP_IDLE_MODE_TEXT:
      case CommandType.SET_UP_MENU:
      case CommandType.CLOSE_CHANNEL:
      case CommandType.RECEIVE_DATA:
      case CommandType.SEND_DATA:
      case CommandType.GET_CHANNEL_STATUS:
      case CommandType.SET_UP_EVENT_LIST:
      case CommandType.PROVIDE_LOCAL_INFORMATION:
      case CommandType.LANGUAGE_NOTIFICATION:
        return false;
    }
    return true;
  }

  private processParseFailed(upParams: BaseUpParams | undefined, slotId: number): boolean {
    if (!upParams || !upParams.isParseCmdDetailSuccess) {
      UpParamsCacheUtils.getInstance().getCurrentUpParams(slotId).then(value => {
        this.sendDefaultResponseData(value, ResponseCode.REQUIRED_VALUES_MISSING);
      });
      return true;
    }
    if (upParams && (upParams.parseResultCode !== ResponseCode.OK || !upParams.isSupport)) {
      this.sendDefaultResponseData(upParams, upParams.parseResultCode);
      return true;
    }
    return false;
  }

  private filterDuplicateMsg(newMsg: BaseUpParams): void {
    let slotId = newMsg.slotId;
    let queueSize = this.delayQueueMap.get(slotId)?.length;
    let lastCmd: BaseUpParams | undefined = undefined;
    if (queueSize !== undefined) {
      lastCmd = queueSize > 0 ? this.delayQueueMap.get(slotId)?.[queueSize - 1] : this.mCurCmd[slotId];
    }
    let newCmd = newMsg.commandHex;
    if (!CommonUtils.isEmptyStr(newCmd) && (newCmd === lastCmd?.commandHex)) {
      HiLog.debug(TAG, `filterDuplicateMsg:${newCmd}`);
      return;
    }
    this.delayQueueMap.get(slotId)?.push(newMsg);
  }

  private processUpParams(upParams: BaseUpParams): void {
    HiLog.info(TAG, `processUpParams on slotId:${upParams.slotId}, type:${upParams.commandType}`);
    this.uiContext?.eventHub.emit(EventHub.RECEIVE_COMMAND, upParams.slotId, upParams.commandType);
    this.stopMenuClickTimeOut(upParams.slotId);
    if (this.isCmdInteractive(upParams.commandType)) {
      if (this.mIsInProgressing[upParams.slotId]) {
        HiLog.info(TAG, 'processUpParams IsInProgressing');
        this.filterDuplicateMsg(upParams);
      } else {
        this.mIsInProgressing[upParams.slotId] = true;
        this.handleUpParamData(upParams);
      }
    } else {
      this.handleUpParamData(upParams);
    }
  }

  private startMenuClickTimeOut(slotId: number): void {
    this.stopMenuClickTimeOut(slotId);
    this.mMenuClickTimeOut[slotId] = CustTimeOutHelper.getInstance().setTimeOutCust(() => {
      this.processSessionEnd(slotId);
    }, TimeOut.MENU_ITEM_CLICK);
  }

  private stopMenuClickTimeOut(slotId: number): void {
    if (this.mMenuClickTimeOut[slotId] !== undefined) {
      clearTimeout(this.mMenuClickTimeOut[slotId]);
      this.mMenuClickTimeOut[slotId] = undefined;
    }
  }

  private handleUpParamData(upParams: BaseUpParams): void {
    HiLog.info(TAG, `handleUpParamData commandType:${upParams.commandType}`);
    let isWaitForUsersResponse: boolean = true;
    let slotId = upParams.slotId;
    this.mCurCmd[slotId] = upParams;
    switch (upParams.commandType) {
      case SESSION_END:
        this.processSessionEnd(slotId);
        break;
      case CommandType.DISPLAY_TEXT:
        let displayTextParam = upParams as DisplayTextParam;
        if (!displayTextParam.responseNeeded) {
          isWaitForUsersResponse = false;
        }
        DisplayAndIdleTextHelper.getInstance(slotId)?.parseDisplayText(displayTextParam);
        break;
      case CommandType.SET_UP_IDLE_MODE_TEXT:
        isWaitForUsersResponse = false;
        this.parseSetUpIdleModeText(upParams as SetUpIdleModeTextParam);
        break;
      case CommandType.SEND_SMS:
      case CommandType.SEND_DTMF:
      case CommandType.SEND_SS:
      case CommandType.SEND_USSD:
        isWaitForUsersResponse = false;
        this.mCurCmd[slotId] = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId);
        this.showToast((upParams as SendAboutParam).text);
        break;
      case CommandType.REFRESH:
        isWaitForUsersResponse = false;
        NotificationUtils.startNotification(this.serviceContext, '', (upParams as SendAboutParam)?.text,
          upParams.slotId, false);
        break;
      case CommandType.CLOSE_CHANNEL:
      case CommandType.RECEIVE_DATA:
      case CommandType.SEND_DATA:
      case CommandType.OPEN_CHANNEL:
      case CommandType.GET_CHANNEL_STATUS:
        isWaitForUsersResponse = this.parseBipParam(upParams);
        break;
      default:
        this.handleUpParamDataSecondary(upParams);
        break;
    }
    if (!isWaitForUsersResponse) {
      this.checkAndPullNextCmd(slotId);
    }
  }

  private handleUpParamDataSecondary(upParams: BaseUpParams): void {
    switch (upParams.commandType) {
      case CommandType.SELECT_ITEM:
        let isMenuPageShow = AppStorageHelper.get<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false);
        HiLog.info(TAG, `Receive SELECT_ITEM isCurrentShowMenu: ${isMenuPageShow}`);
        this.startInputOrMenuAbility(upParams.slotId, upParams, PageUrl.PAGE_URL_MAIN);
        break;
      case CommandType.SET_UP_MENU:
        this.parseSetUpMenu(upParams as SetUpMenuParam);
        break;
      case CommandType.GET_INPUT:
      case CommandType.GET_INKEY:
        this.startInputOrMenuAbility(upParams.slotId, upParams, PageUrl.PAGE_URL_INPUT);
        break;
      case CommandType.LAUNCH_BROWSER:
        this.parseLaunchBrowser(upParams as LaunchBrowserParam);
        break;
      case CommandType.SET_UP_CALL:
        this.parseSetUpCall(upParams as SetUpCallParam);
        break;
      case CommandType.PLAY_TONE:
        this.parsePlayTone(upParams as PlayToneParam);
        break;
      case CommandType.SET_UP_EVENT_LIST:
        this.parseSetUpEventList(upParams as SetUpEventListParam);
        break;
      case CommandType.LANGUAGE_NOTIFICATION:
        this.parseLanguageNotification(upParams as LanguageNotificationParam);
        break;
      case CommandType.PROVIDE_LOCAL_INFORMATION:
        this.parseProvideLocalInformation(upParams as ProvideLocalInformationParam);
        break;
      default:
        break;
    }
  }

  private checkAndPullNextCmd(slotId: number): void {
    if (this.delayQueueMap.get(slotId)?.length !== 0) {
      let queueParams = this.delayQueueMap.get(slotId)?.shift();
      if (queueParams) {
        this.handleUpParamData(queueParams);
        return;
      }
    }
    HiLog.info(TAG, `checkAndPullNextCmd set IsInProgressing to false for slotId:${slotId}`);
    this.mIsInProgressing[slotId] = false;
  }

  private parseSetUpMenu(upParams: SetUpMenuParam): void {
    UpParamsCacheUtils.getInstance().putMainMenuParamsMemory(upParams as SetUpMenuParam);
    HiLog.info(TAG, 'SET_UP_MENU putMainMenuParamsMemory');
    this.sendDefaultResponseData(upParams,
      this.refreshRespCodeIfLoadIconFailed(upParams, ResponseCode.OK));
    // refresh SET_UP_MENU
    this.uiContext?.eventHub.emit(EventHub.REFRESH_SET_UP_MENU, upParams.slotId,
      UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(upParams.slotId));
    entranceHelper.checkIsHaveMainMenu(this.serviceContext, upParams.slotId);
  }

  private parseSetUpIdleModeText(idleModeParam: SetUpIdleModeTextParam): void {
    DisplayAndIdleTextHelper.getInstance(idleModeParam.slotId)?.parseSetUpIdleModeText(idleModeParam);
    this.sendDefaultResponseData(idleModeParam,
      this.refreshRespCodeIfLoadIconFailed(idleModeParam, ResponseCode.OK));
  }

  private parseSetUpCall(callParam: SetUpCallParam): void {
    if (callParam && !callParam.confirmText) {
      callParam.confirmText = UiUtils.getStringSync(this.serviceContext,
        $r('app.string.default_setup_call_msg').id) ?? '';
    }
    UiUtils.startDialog(this.uiContext, this.serviceContext, callParam);
  }

  private parseProvideLocalInformation(param: ProvideLocalInformationParam): void {
    let data: DefaultResponseData | undefined = undefined;
    if (param.infoMode === ProvideLocalInformationMode.DTTZ_SETTING) {
      data = new DateTimeResponseData(param);
    } else if (param.infoMode === ProvideLocalInformationMode.LANGUAGE_SETTING) {
      data = new LanguageResponseData(param);
    } else {
      data = new DefaultResponseData(param);
    }
    data.resultCode = ResponseCode.OK;
    SimToolKitResponseManager.getInstance().sendTerminalResponseData(data);
  }

  private async parseLanguageNotification(param: LanguageNotificationParam): Promise<void> {
    // changeLanguage  zh-Hans
    HiLog.info(TAG, 'parseLanguageNotification language');
    let languageNotificationHelper = new LanguageNotificationHelper();
    await languageNotificationHelper.parseLanguage(this.serviceContext, param);

    if (CommonUtils.isEmptyStr(param.language)) {
      this.sendDefaultResponseData(param, ResponseCode.TERMINAL_CRNTLY_UNABLE_TO_PROCESS);
      return;
    }
    let resultCode = ResponseCode.OK;
    try {
      let fullLanguageName = LanguageUtils.getSystemLanguageFullName(param.language);
      i18n.System.setSystemLanguage(fullLanguageName);
    } catch (err) {
      resultCode = ResponseCode.TERMINAL_CRNTLY_UNABLE_TO_PROCESS;
      const error = err as BusinessError;
      HiLog.error(TAG, `parseLanguageNotification System.setSystemLanguage failed, ${error?.code}, ${error?.message}`);
    }
    this.sendDefaultResponseData(param, resultCode);
  }

  private parseBipParam(upParams: BaseUpParams): boolean {
    let bipParam = upParams as AllBipParam;
    if (bipParam.commandType === CommandType.GET_CHANNEL_STATUS) {
      HiLog.info(TAG, 'parseBipParam GET_CHANNEL_STATUS not do anything');
      return false;
    }
    if (!bipParam.isShowView) {
      HiLog.info(TAG, 'parseBipParam not show view');
      return false;
    }
    if (bipParam.commandType === CommandType.OPEN_CHANNEL) {
      // show dialog
      if (CommonUtils.isEmptyStr(bipParam.text)) {
        bipParam.text = UiUtils.getStringSync(this.serviceContext, $r('app.string.default_open_channel_msg').id) ?? '';
      }
      UiUtils.startDialog(this.uiContext, this.serviceContext, bipParam);
      return true;
    }
    if (CommonUtils.isEmptyStr(bipParam.text)) {
      if (bipParam.commandType === CommandType.CLOSE_CHANNEL) {
        bipParam.text = UiUtils.getStringSync(this.serviceContext, $r('app.string.default_close_channel_msg').id) ?? '';
      } else if (bipParam.commandType === CommandType.RECEIVE_DATA) {
        bipParam.text = UiUtils.getStringSync(this.serviceContext, $r('app.string.default_receive_data_msg').id) ?? '';
      } else if (bipParam.commandType === CommandType.SEND_DATA) {
        bipParam.text = UiUtils.getStringSync(this.serviceContext, $r('app.string.default_send_data_msg').id) ?? '';
      }
    }
    if (!CommonUtils.isEmptyStr(bipParam.text)) {
      this.showToast(bipParam.text);
    }
    return false;
  }

  public showToast(text: string | undefined): void {
    HiLog.info(TAG, `showToast: text:${text}`);
    if (this.serviceContext) {
      UiUtils.showToastFromServiceAbility(this.serviceContext, text);
    }
  }

  private parsePlayTone(param: PlayToneParam): void {
    HiLog.info(TAG, `parsePlayTone: text:${param.text}`);
    if (param.text) {
      // only when incoming params has text message can show dialog, or else will play tone in background
      UiUtils.startDialog(this.uiContext, this.serviceContext, param);
    } else {
      param.text = UiUtils.getStringSync(this.serviceContext, $r('app.string.default_playtone_msg').id) ?? '';
      TonePlayer.startPlay(param, true);
    }
  }

  private parseLaunchBrowser(param: LaunchBrowserParam): void {
    if (CommonUtils.isEmptyStr(param.confirmText)) {
      param.confirmText = UiUtils.getStringSync(this.serviceContext, $r('app.string.launchBrowserDefault').id) ?? '';
    }
    NotificationUtils.notifyUserOnKeyguard(this.serviceContext, param.slotId, param.confirmText, param);
    UiUtils.startDialog(this.uiContext, this.serviceContext, param);
  }

  private startLaunchBrowser(param: LaunchBrowserParam): void {
    let url: string;
    if (CommonUtils.isEmptyStr(param.url)) {
      // url is only 'http' to start browser home.
      url = 'http';
    } else {
      if (param.url.startsWith(URL_PREFIX_HTTP) || param.url.startsWith(URL_PREFIX_HTTPS)) {
        url = param.url;
      } else {
        url = URL_PREFIX_HTTP + param.url;
      }
    }
    let want: Want = {
      'action': 'ohos.want.action.viewData',
      'entities': ['entity.system.browsable'],
      'uri': url
    };
    HiLog.info(TAG, 'startLaunchBrowser');
    this.startAbilityByWantOnly(want);
  }

  private parseSetUpEventList(param: SetUpEventListParam): void {
    // manager eventList
    SetUpEventListHelper.getInstance().handleSetupEvent(param.slotId, param.eventList);
    let resultCode: ResponseCode;
    if (CommonUtils.isEmptyArr(param.eventList)) {
      resultCode = ResponseCode.BEYOND_TERMINAL_CAPABILITY;
    } else {
      resultCode = ResponseCode.OK;
    }
    this.sendDefaultResponseData(param, resultCode);
  }

  public startInputOrMenuAbility(slotId: number, upParam: BaseUpParams, pageUrl: string): void {
    HiLog.info(TAG, `startInputOrMenuAbility slotId:${slotId}, pageUrl:${pageUrl}`);
    let want: Want = {
      bundleName: HapInfo.BUNDLE_NAME,
      abilityName: HapInfo.MAIN_ABILITY,
      parameters: {
        'upParam': upParam,
        'pageUrl': pageUrl,
        'slotId': slotId
      }
    };
    this.startInputOrMenuAbilityActuality(want, upParam, pageUrl);
  }

  private startInputOrMenuAbilityActuality(want: Want, upParams: BaseUpParams, pageUrl: string): void {
    if (!CommonUtils.isDeviceProvisioned(this.serviceContext ?? this.uiContext)) {
      this.handleCmdResponse(
        FromPageFlag.TYPE_INPUT, UIResponseCode.RESPONSE_TYPE_TIMEOUT, upParams);
      return;
    }
    if (pageUrl === PageUrl.PAGE_URL_INPUT) {
      NotificationUtils.notifyUserOnKeyguard(
        this.serviceContext, upParams.slotId, (upParams as GetInkeyInputParam).text);
    }
    this.startAbilityByWantOnly(want);
  }

  private startAbilityByWantOnly(want: Want): void {
    try {
      let curContext = this.serviceContext ?? this.uiContext;
      curContext?.startAbility(want).then((data) => {
        HiLog.info(TAG, 'startAbilityByWantOnly success, data');
      }).catch((error: BusinessError) => {
        HiLog.error(TAG, `startAbilityByWantOnly error: ${error?.code}, ${error?.message}`);
      });
    } catch (err) {
      const error = err as BusinessError;
      HiLog.error(TAG, `startAbilityByWantOnly error, ${error?.code}, ${error?.message}`);
    }
  }

  public handleCmdResponse(flag: FromPageFlag, type: UIResponseCode, upParam?: BaseUpParams,
    menuData?: UiMenuResponseData, inputData?: UiInputResponseData): void {
    if (!upParam) {
      HiLog.error(TAG, 'handleCmdResponse upParam error');
      return;
    }
    switch (flag) {
      case FromPageFlag.TYPE_MENU:
        if (type === UIResponseCode.RESPONSE_TYPE_MENU) {
          if (menuData) {
            this.sendMenuResponseData(upParam, menuData);
          }
        } else {
          this.sendSpecificResponseData(upParam, type);
        }
        break;
      case FromPageFlag.TYPE_INPUT:
        if (type === UIResponseCode.RESPONSE_TYPE_INPUT) {
          if (inputData) {
            this.sendInKeyInputResponseData(upParam as GetInkeyInputParam, inputData);
          }
        } else {
          this.sendSpecificResponseData(upParam, type);
        }
        break;
      case FromPageFlag.TYPE_DIALOG:
        this.sendDialogResponseData(upParam, type);
        break;
      case FromPageFlag.TYPE_BACKGROUND:
        this.sendBackGroundResponseData(upParam, type);
        break;
      default:
        break;
    }
    NotificationUtils.setNotifyHasResponseFromUser(
      upParam.slotId,
      type === UIResponseCode.RESPONSE_TYPE_TIMEOUT);
    this.checkAndPullNextCmd(upParam.slotId);
  }

  private sendBackGroundResponseData(param: BaseUpParams, type: number): void {
    if (type === UIResponseCode.RESPONSE_TYPE_LOCAL_BUSY) {
      let resp = new DefaultResponseData(param);
      resp.resultCode = ResponseCode.TERMINAL_CRNTLY_UNABLE_TO_PROCESS;
      resp.setAdditionalInfo(ExResponseInfo.SCREEN_BUSY);
      SimToolKitResponseManager.getInstance().sendTerminalResponseData(resp);
    }
  }

  private sendMenuResponseData(upParam: BaseUpParams, responseData: UiMenuResponseData): void {
    if (CommonUtils.isEmptyObj(responseData)) {
      HiLog.error(TAG, 'sendMenuResponseData responseData error');
      return;
    }
    this.startMenuClickTimeOut(upParam.slotId);
    if (upParam.commandType === CommandType.SET_UP_MENU) {
      let menuSelectData = new MenuSelectionEnvelopeData(
        upParam.slotId, responseData.menuId, responseData.isHelpRequired);
      SimToolKitResponseManager.getInstance().sendMenuSelectionEnvelopeData(menuSelectData);
    } else {
      let noHelpCode: number = this.refreshRespCodeIfLoadIconFailed(upParam, ResponseCode.OK);
      let resultCode = responseData.isHelpRequired ? ResponseCode.HELP_INFO_REQUIRED : noHelpCode;
      let selectItemData = new SelectItemResponseData(upParam, responseData.menuId, resultCode);
      SimToolKitResponseManager.getInstance().sendTerminalResponseData(selectItemData);
    }
  }

  private sendInKeyInputResponseData(upParam: GetInkeyInputParam, responseData: UiInputResponseData): void {
    if (CommonUtils.isEmptyObj(responseData)) {
      HiLog.error(TAG, 'sendInKeyResponseData responseData error');
      return;
    }
    let terminalResponseData: DefaultResponseData;
    if (upParam.isYesNo) {
      let inkeyData = new InputInkeyResponseData(upParam);
      inkeyData.setYesNoInKeyData(responseData.isYesNo, ResponseCode.OK);
      terminalResponseData = inkeyData;
    } else {
      if (responseData.isHelpRequired) {
        terminalResponseData = new DefaultResponseData(upParam,
          responseData.isHelpRequired ? ResponseCode.HELP_INFO_REQUIRED :
          ResponseCode.OK);
      } else {
        let inputData = new InputInkeyResponseData(upParam);
        let respCode: number = this.refreshRespCodeIfLoadIconFailed(upParam, ResponseCode.OK);
        inputData.setInputData(responseData.inputStr, upParam.inputEncodeType, respCode);
        terminalResponseData = inputData;
      }
    }
    SimToolKitResponseManager.getInstance().sendTerminalResponseData(terminalResponseData);
  }

  private refreshRespCodeIfLoadIconFailed(upParam: BaseUpParams, defRespCode: number): number {
    if (upParam?.iconInfo?.hasIconAndLoadFailed) {
      HiLog.info(TAG, 'refreshRespCode when load icon failed');
      return ResponseCode.PRFRMD_ICON_NOT_DISPLAYED;
    } else {
      return defRespCode;
    }
  }

  private sendDialogResponseData(upParam: BaseUpParams, resultCode: number): void {
    HiLog.info(TAG, 'sendDialogResponseData from slotId:${upParam.slotId}');
    AppStorageHelper.remove(AppStorageKey.PAGE_BIND_DIALOG_PARAM);
    if (upParam.commandType === CommandType.OPEN_CHANNEL) {
      this.sendOpenChannelResponseData(upParam as AllBipParam, resultCode);
      return;
    }
    if (upParam.commandType === CommandType.SET_UP_CALL) {
      this.sendDialogSetUpCallResponseData(upParam as SetUpCallParam, resultCode);
      return;
    }
    let data = new DefaultResponseData(upParam);
    let type = upParam.commandType;
    switch (resultCode) {
      case UIResponseCode.RESPONSE_TYPE_DIALOG_CLEAN:
      case UIResponseCode.RESPONSE_TYPE_CONFIRM_REJECT:
        data.resultCode = ResponseCode.UICC_SESSION_TERM_BY_USER;
        break;
      case UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT:
        data.resultCode = this.refreshRespCodeIfLoadIconFailed(upParam, ResponseCode.OK);
        break;
      case UIResponseCode.RESPONSE_TYPE_BACKWARD:
        HiLog.info(TAG, 'sendDialogResponseData Type:BackWard');
        data.resultCode = (type === CommandType.PLAY_TONE) ?
        ResponseCode.UICC_SESSION_TERM_BY_USER :
        ResponseCode.BACKWARD_MOVE_BY_USER;
        break;
      case UIResponseCode.RESPONSE_TYPE_TIMEOUT:
        HiLog.info(TAG, 'sendDialogResponseData Type:Timeout');
        data.resultCode = ResponseCode.NO_RESPONSE_FROM_USER;
        if (type === CommandType.PLAY_TONE) {
          data.resultCode = this.refreshRespCodeIfLoadIconFailed(upParam, ResponseCode.OK);
        }
        if (type === CommandType.DISPLAY_TEXT && !(upParam as DisplayTextParam).isUserClear) {
          data.resultCode = ResponseCode.OK;
        }
        break;
      default:
        break;
    }
    HiLog.info(TAG, `sendDialogResponseData resultCode:${data.resultCode}`);
    SimToolKitResponseManager.getInstance().sendTerminalResponseData(data);
    if (upParam.commandType === CommandType.LAUNCH_BROWSER &&
      resultCode === UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT) {
      this.currentLaunchBrowserParamMap.set(upParam.slotId, upParam as LaunchBrowserParam);
    }
  }

  private sendDialogSetUpCallResponseData(upParam: SetUpCallParam, resultCode: number): void {
    HiLog.info(TAG, 'sendDialogSetUpCallResponseData');
    if (resultCode === UIResponseCode.RESPONSE_TYPE_TIMEOUT) {
      let data = new DefaultResponseData(upParam);
      data.resultCode = ResponseCode.NO_RESPONSE_FROM_USER;
      SimToolKitResponseManager.getInstance().sendTerminalResponseData(data);
    } else {
      let isAccept = resultCode === UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT ? true : false;
      SimToolKitResponseManager.getInstance().sendCallSetupRequest(upParam.slotId, isAccept);
      if (isAccept && upParam.callSetUpText) {
        this.showToast(upParam.callSetUpText);
      }
    }
  }

  private sendOpenChannelResponseData(upParam: AllBipParam, resultCode: number): void {
    HiLog.info(TAG, 'sendOpenChannelResponseData');
    let responseCode: BipResponseCode;
    if (resultCode === UIResponseCode.RESPONSE_TYPE_TIMEOUT) {
      responseCode = BipResponseCode.TIMEOUT;
    } else if (resultCode === UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT) {
      responseCode = BipResponseCode.CONFIRM_ACCEPT;
    } else {
      responseCode = BipResponseCode.CONFIRM_REJECT;
    }
    let data = new BipResponseData(upParam.slotId, upParam.commandType, responseCode);
    SimToolKitResponseManager.getInstance().sendBipResponseData(data);
  }

  // RESPONSE_TYPE_BACKWARD, RESPONSE_TYPE_TIMEOUT, RESPONSE_TYPE_END_SESSION
  private sendSpecificResponseData(upParam: BaseUpParams, type: number): void {
    let data: DefaultResponseData | undefined = undefined;
    if (type === UIResponseCode.RESPONSE_TYPE_TIMEOUT) {
      if (upParam.commandType === CommandType.GET_INKEY ||
        upParam.commandType === CommandType.GET_INPUT) {
        data = this.createInkeyInputSpecificNoResponse(upParam, ResponseCode.NO_RESPONSE_FROM_USER);
      } else {
        data = new DefaultResponseData(upParam, ResponseCode.NO_RESPONSE_FROM_USER);
      }
    } else if (type === UIResponseCode.RESPONSE_TYPE_BACKWARD) {
      data = new DefaultResponseData(upParam, ResponseCode.BACKWARD_MOVE_BY_USER);
    } else if (type === UIResponseCode.RESPONSE_TYPE_END_SESSION) {
      data = new DefaultResponseData(upParam, ResponseCode.UICC_SESSION_TERM_BY_USER);
    } else {
      HiLog.error(TAG, 'sendSpecificResponseData type is not find');
      return;
    }
    SimToolKitResponseManager.getInstance().sendTerminalResponseData(data);
  }

  private createInkeyInputSpecificNoResponse(upParam: BaseUpParams, resultCode: number): InputInkeyResponseData {
    let data = new InputInkeyResponseData(upParam);
    data.setTimeOutHaveDuration((upParam as GetInkeyInputParam).durationObj, resultCode);
    return data;
  }

  private sendDefaultResponseData(param: BaseUpParams | undefined, resultCode: number): void {
    if (!param) {
      HiLog.error(TAG, 'sendDefaultResponseData BaseUpParams is empty');
      return;
    }
    if (!this.checkMsgHaveResponse(param.commandType) ||
      param.commandType === CommandType.OPEN_CHANNEL) {
      HiLog.info(TAG, 'sendDefaultResponseData is not to response');
      return;
    }
    let defaultResponseData = new DefaultResponseData(param);
    defaultResponseData.resultCode = resultCode;
    SimToolKitResponseManager.getInstance().sendTerminalResponseData(defaultResponseData);
  }
}
