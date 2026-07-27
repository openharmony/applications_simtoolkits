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

import { sim } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../common/utils/HiLog';
import { EncodeDecodeUtils } from '../common/utils/EncodeDecodeUtils';
import { DefaultResponseData } from './responseData/terminalResponseData/DefaultResponseData';
import { MenuSelectionEnvelopeData } from './responseData/envelopeData/MenuSelectionEnvelopeData';
import { BaseEventListEnvelopeData } from './responseData/envelopeData/BaseEventListEnvelopeData';
import CommonUtils from '../common/utils/CommonUtils';
import { BipResponseData } from './responseData/terminalResponseData/BipResponseData';
import { sendCallSetupRequest } from './TsManager';

const TAG = 'SimToolKitResponseManager';

export class SimToolKitResponseManager {
  private static instance: SimToolKitResponseManager;

  public static getInstance(): SimToolKitResponseManager {
    if (CommonUtils.isEmptyObj(SimToolKitResponseManager.instance)) {
      HiLog.info(TAG, 'SimToolKitResponseManager getInstance init');
      SimToolKitResponseManager.instance = new SimToolKitResponseManager();
    }
    return SimToolKitResponseManager.instance;
  }

  public sendBipResponseData(data: BipResponseData): void {
    let responseDataHex = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
    HiLog.info(TAG, `sendBipResponseData slotId:${data.slotId}, responseDataHex:${responseDataHex}`);
    sim.sendTerminalResponseCmd(data.slotId, responseDataHex).then(value => {
      HiLog.info(TAG, 'sendBipResponseData success');
    }).catch((error: BusinessError) => {
      HiLog.error(TAG, 'sendBipResponseData error');
    });
  }

  public sendTerminalResponseData(data: DefaultResponseData): void {
    let responseDataHex = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
    HiLog.info(TAG,
      `sendTerminalResponseData slotId:${data.slotId}, commandType:${data.commandType}, resultCode:${data.resultCode}`);
    sim.sendTerminalResponseCmd(data.slotId, responseDataHex).then(value => {
      HiLog.info(TAG, 'sendTerminalResponseData success');
    }).catch((error: BusinessError) => {
      HiLog.error(TAG, 'sendTerminalResponseData error');
    });
  }

  public sendMenuSelectionEnvelopeData(data: MenuSelectionEnvelopeData): void {
    let responseDataHex = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
    HiLog.info(TAG, `sendMenuSelectionEnvelopeData slotId:${data.slotId}, menuId:${data.menuId}`);
    sim.sendEnvelopeCmd(data.slotId, responseDataHex).then(value => {
      HiLog.info(TAG, 'sendMenuSelectionEnvelopeData success');
    }).catch((error: BusinessError) => {
      HiLog.error(TAG, 'sendMenuSelectionEnvelopeData error');
    });
  }

  public sendEventListEnvelopeData(data: BaseEventListEnvelopeData): void {
    let responseDataHex = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
    HiLog.info(TAG, `sendEventListEnvelopeData slotId:${data.slotId}, eventId:${data.eventId}`);
    sim.sendEnvelopeCmd(data.slotId, responseDataHex).then(value => {
      HiLog.info(TAG, 'sendEventListEnvelopeData success');
    }).catch((error: BusinessError) => {
      HiLog.error(TAG, 'sendEventListEnvelopeData error');
    });
  }

  public sendCallSetupRequest(slotId: number, isAccept: boolean): void {
    sendCallSetupRequest(slotId, isAccept);
  }
}





