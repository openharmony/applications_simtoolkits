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
  ARR_INDEX_ONE,
  ARR_LENGTH_ONE,
  ARR_LENGTH_TWO,
  DeviceId,
  TlvItemType,
  TlvType,
  VALUE_HEX_80
} from '../../../common/constant/SimToolKitConstant';
import HiLog from '../../../common/utils/HiLog';

const TAG = 'MenuSelectionEnvelopeData';

export class MenuSelectionEnvelopeData {
  public menuId: number | undefined = undefined;
  public isHelpRequired: boolean | undefined = undefined;
  public slotId: number | undefined = undefined;

  public constructor(slotId?: number, menuId?: number, isHelpRequired?: boolean) {
    this.slotId = slotId;
    this.menuId = menuId;
    this.isHelpRequired = isHelpRequired;
  }

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'MenuSelectionEnvelopeData  parseDataToHex');
    if (this.menuId === undefined || this.isHelpRequired === undefined || this.slotId === undefined) {
      HiLog.info(TAG, 'MenuSelectionEnvelopeData  parameter error');
      return [];
    }
    let dataVec: number[] = [];
    dataVec.push(TlvType.MENU_SELECTION_ENVELOPE);
    dataVec.push(0); // placeholder, assume length < 128.

    // device
    dataVec.push(VALUE_HEX_80 | TlvItemType.DEVICE_IDENTITIES);
    dataVec.push(ARR_LENGTH_TWO);
    dataVec.push(DeviceId.DEV_ID_KEYPAD); // source device id
    dataVec.push(DeviceId.DEV_ID_UICC); // destination device id

    // item id
    dataVec.push(VALUE_HEX_80 | TlvItemType.ITEM_ID);
    dataVec.push(ARR_LENGTH_ONE);
    dataVec.push(this.menuId);

    // helpRequired
    if (this.isHelpRequired) {
      dataVec.push(TlvItemType.HELP_REQUEST);
      dataVec.push(0);
    }

    // set total length
    dataVec[ARR_INDEX_ONE] = dataVec.length - ARR_LENGTH_TWO;
    return dataVec;
  }
}
