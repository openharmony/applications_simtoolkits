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
  TlvItemType,
  TlvType,
  VALUE_HEX_80
} from '../../../common/constant/SimToolKitConstant';
import HiLog from '../../../common/utils/HiLog';

const TAG = 'BaseEventListEnvelopeData';

export class BaseEventListEnvelopeData {
  public slotId: number | undefined = undefined;
  public devicesSource: number | undefined = undefined;
  public devicesDest: number | undefined = undefined;
  public eventId: number | undefined = undefined;

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'BaseEventListEnvelopeData  parseDataToHex');
    if (this.slotId === undefined) {
      return [];
    }
    if (this.eventId === undefined || this.devicesSource === undefined || this.devicesDest === undefined) {
      return [];
    }
    let dataVec: number[] = [];
    dataVec.push(TlvType.EVENT_ENVELOPE);
    dataVec.push(0); // placeholder, assume length < 128.

    // eventId
    dataVec.push(VALUE_HEX_80 | TlvItemType.EVENT_LIST);
    dataVec.push(ARR_LENGTH_ONE); // length
    dataVec.push(this.eventId); // event value

    // device id
    dataVec.push(VALUE_HEX_80 | TlvItemType.DEVICE_IDENTITIES);
    dataVec.push(ARR_LENGTH_TWO);
    dataVec.push(this.devicesSource); // source device id
    dataVec.push(this.devicesDest); // destination device id

    // set total length
    dataVec[ARR_INDEX_ONE] = dataVec.length - ARR_LENGTH_TWO;
    return dataVec;
  }
}