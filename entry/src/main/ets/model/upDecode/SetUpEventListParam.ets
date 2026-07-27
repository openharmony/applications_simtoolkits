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

import { BaseUpParams } from './BaseUpParams';
import { DecodeItemUtil } from './DecodeItemUtil';
import { EventIdType, ResponseCode } from '../../common/constant/SimToolKitConstant';
import { Tlv } from './Tlv';

export class SetUpEventListParam extends BaseUpParams {
  public eventList: Array<number> = [];

  private checkEventList(eventArr: Array<number> | undefined): void {
    if (eventArr === undefined || eventArr.length === 0) {
      return;
    }
    eventArr.forEach(value => {
      if (value === EventIdType.USER_ACTIVITY_EVENT || value === EventIdType.IDLE_SCREEN_AVAILABLE_EVENT ||
        value === EventIdType.LANGUAGE_SELECTION_EVENT) {
        this.eventList?.push(value);
      }
    });
  }

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.checkEventList(DecodeItemUtil.parseEventList(tlvList, false));
    }
  }
}