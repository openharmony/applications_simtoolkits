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

import {
  ARR_LENGTH_ONE,
  ARR_LENGTH_THREE,
  ARR_LENGTH_TWO,
  DeviceId,
  TlvItemType,
  VALUE_HEX_80
} from '../../../common/constant/SimToolKitConstant';
import HiLog from '../../../common/utils/HiLog';
import { BaseUpParams } from '../../upDecode/BaseUpParams';

const TAG = 'DefaultResponseData';

export class DefaultResponseData {
  public commandNumber?: number;
  public commandType?: number;
  public commandQual?: number;
  public hasCompRequiredFlag?: boolean;
  public resultCode?: number;
  public slotId?: number;
  public hasAdditionalInfo: boolean = false;
  public additionalInfo: number = 0;

  constructor(upParams?: BaseUpParams, resultCode?: number) {
    if (!upParams) {
      return;
    }
    this.resultCode = resultCode;
    this.commandNumber = upParams.commandNumber;
    this.commandType = upParams.commandType;
    this.commandQual = upParams.commandQual;
    this.hasCompRequiredFlag = upParams.hasCompRequiredFlag;
    this.slotId = upParams.slotId;
  }

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'DefaultResponseData  parseDataToHex');
    if (this.commandNumber === undefined || this.commandType === undefined || this.commandQual === undefined) {
      return [];
    }
    if (this.hasCompRequiredFlag === undefined || this.resultCode === undefined || this.slotId === undefined) {
      return [];
    }
    let dataVec: number[] = [];

    // CommandDetails
    let cmdTag = TlvItemType.COMMAND_DETAILS;
    if (this.hasCompRequiredFlag) {
      cmdTag |= VALUE_HEX_80;
    }
    dataVec.push(cmdTag);
    dataVec.push(ARR_LENGTH_THREE);
    dataVec.push(this.commandNumber);
    dataVec.push(this.commandType);
    dataVec.push(this.commandQual);

    // DeviceIdentities
    let deviceIdTag = TlvItemType.DEVICE_IDENTITIES;
    dataVec.push(deviceIdTag);
    dataVec.push(ARR_LENGTH_TWO); // length
    dataVec.push(DeviceId.DEV_ID_TERMINAL); // source device id
    dataVec.push(DeviceId.DEV_ID_UICC); // destination device id

    // Result
    let resultTag = TlvItemType.RESULT;
    if (this.hasCompRequiredFlag) {
      resultTag |= VALUE_HEX_80;
    }
    dataVec.push(resultTag);
    let resultLen = this.hasAdditionalInfo ? ARR_LENGTH_TWO : ARR_LENGTH_ONE;
    dataVec.push(resultLen);
    dataVec.push(this.resultCode);
    if (this.hasAdditionalInfo) {
      dataVec.push(this.additionalInfo);
    }
    return dataVec;
  }

  public setAdditionalInfo(info: number): void {
    this.hasAdditionalInfo = true;
    this.additionalInfo = info;
  }
}