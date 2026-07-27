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

import { ResponseCode } from '../../common/constant/SimToolKitConstant';
import { BaseUpParams } from './BaseUpParams';
import { DecodeItemUtil } from './DecodeItemUtil';
import { Tlv } from './Tlv';

export class SetUpCallParam extends BaseUpParams {
  public confirmText: string = '';
  public callSetUpText: string = '';

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      let tempText = DecodeItemUtil.parseAlphaId(tlvList, false);
      let isHaveAddress = DecodeItemUtil.parseIsHaveAddress(tlvList);
      if (isHaveAddress) {
        this.confirmText = tempText ?? '';
        this.callSetUpText = DecodeItemUtil.parseAlphaId(tlvList, false) ?? '';
      } else {
        this.callSetUpText = tempText ?? '';
      }
    }
  }
}