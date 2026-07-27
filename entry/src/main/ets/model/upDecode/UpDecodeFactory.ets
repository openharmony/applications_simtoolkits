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

import HiLog from '../../common/utils/HiLog';
import { BaseUpParams } from './BaseUpParams';
import { CommandType, ResponseCode } from '../../common/constant/SimToolKitConstant';
import { Tlv } from './Tlv';
import { SetUpMenuParam } from './SetUpMenuParam';
import { SelectItemParam } from './SelectItemParam';
import { DisplayTextParam } from './DisplayTextParam';
import { SetUpIdleModeTextParam } from './SetUpIdleModeTextParam';
import { GetInkeyInputParam } from './GetInkeyInputParam';
import { SendAboutParam } from './SendAboutParam';
import { SetUpCallParam } from './SetUpCallParam';
import { LaunchBrowserParam } from './LaunchBrowserParam';
import { PlayToneParam } from './PlayToneParam';
import { SetUpEventListParam } from './SetUpEventListParam';
import { ProvideLocalInformationParam } from './ProvideLocalInformationParam';
import { LanguageNotificationParam } from './LanguageNotificationParam';
import CommonUtils from '../../common/utils/CommonUtils';
import { AllBipParam } from './AllBipParam';

const TAG = 'UpDecodeFactory';

export class UpDecodeFactory {
  private static instance: UpDecodeFactory;

  public static getInstance(): UpDecodeFactory {
    if (CommonUtils.isEmptyObj(UpDecodeFactory.instance)) {
      HiLog.info(TAG, 'SimToolKitResponseManager getInstance init');
      UpDecodeFactory.instance = new UpDecodeFactory();
    }
    return UpDecodeFactory.instance;
  }

  public parseUpData(commandHex: string, slotId: number): BaseUpParams | undefined {
    let rootTlv = new Tlv();
    let resultFlag = Tlv.tlvDecode(commandHex, rootTlv);
    if (!resultFlag) {
      HiLog.error(TAG, 'parseUpData decode error');
      return undefined;
    }
    let upParams = this.createUpParams(rootTlv.commandType);
    if (!upParams) {
      HiLog.debug(TAG, `UpDecodeFactory not upParams  error:${commandHex}`);
      return undefined;
    }
    upParams.slotId = slotId;
    upParams.commandHex = commandHex;
    upParams.processMsgList(rootTlv.tlvList);
    if (upParams.parseResultCode !== ResponseCode.OK) {
      HiLog.debug(TAG, `UpDecodeFactory upParams.processMsgList  error:${commandHex}`);
    }
    return upParams;
  }

  private createUpParamsSecondary(commandType: number): BaseUpParams | undefined {
    let result: BaseUpParams | undefined = undefined;
    switch (commandType) {
      case CommandType.SEND_DTMF:
      case CommandType.SEND_SMS:
      case CommandType.REFRESH:
      case CommandType.SEND_SS:
      case CommandType.SEND_USSD:
        result = new SendAboutParam();
        break;
      case CommandType.OPEN_CHANNEL:
      case CommandType.CLOSE_CHANNEL:
      case CommandType.RECEIVE_DATA:
      case CommandType.SEND_DATA:
      case CommandType.GET_CHANNEL_STATUS:
        result = new AllBipParam();
        break;
      default:
        break;
    }
    return result;
  }

  private createUpParams(commandType: number): BaseUpParams | undefined {
    let result: BaseUpParams | undefined = undefined;
    switch (commandType) {
      case CommandType.SET_UP_MENU:
        result = new SetUpMenuParam();
        break;
      case CommandType.SELECT_ITEM:
        result = new SelectItemParam();
        break;
      case CommandType.DISPLAY_TEXT:
        result = new DisplayTextParam();
        break;
      case CommandType.SET_UP_IDLE_MODE_TEXT:
        result = new SetUpIdleModeTextParam();
        break;
      case CommandType.GET_INKEY:
      case CommandType.GET_INPUT:
        result = new GetInkeyInputParam(commandType);
        break;
      case CommandType.SET_UP_CALL:
        result = new SetUpCallParam();
        break;
      case CommandType.LAUNCH_BROWSER:
        result = new LaunchBrowserParam();
        break;
      case CommandType.PLAY_TONE:
        result = new PlayToneParam();
        break;
      case CommandType.SET_UP_EVENT_LIST:
        result = new SetUpEventListParam();
        break;
      case CommandType.PROVIDE_LOCAL_INFORMATION:
        result = new ProvideLocalInformationParam();
        break;
      case CommandType.LANGUAGE_NOTIFICATION:
        result = new LanguageNotificationParam();
        break;
      default:
        result = this.createUpParamsSecondary(commandType);
        break;
    }
    if (result === undefined) {
      result = new BaseUpParams();
      result.isSupport = false;
      result.parseResultCode = ResponseCode.BEYOND_TERMINAL_CAPABILITY;
    }
    return result;
  }
}