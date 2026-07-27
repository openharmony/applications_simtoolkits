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

/**
 * All Bip command type(OPEN_CHANNEL CLOSE_CHANNEL RECEIVE_DATA SEND_DATA GET_CHANNEL_STATUS)
 * only parse ALPHA_ID
 *
 * @since 2024-08-30
 */
export class AllBipParam extends BaseUpParams {
  public text: string = '';
  public isShowView: boolean = false;

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      let orgText = DecodeItemUtil.parseBIPAlphaId(tlvList);
      if (orgText === undefined) {
        this.isShowView = false;
        this.text = '';
      } else {
        this.isShowView = true;
        this.text = orgText;
      }
    }
  }
}