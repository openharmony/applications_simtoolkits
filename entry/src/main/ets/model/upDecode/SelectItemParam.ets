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
import { DecodeItemUtil } from './DecodeItemUtil';
import { SetUpMenuParam } from './SetUpMenuParam';
import { Tlv } from './Tlv';

export class SelectItemParam extends SetUpMenuParam {
  public defaultItemId: number = 0;

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.defaultItemId = DecodeItemUtil.parseItemId(tlvList, false) ?? 0;
    }
    this.isShowEndSession = true;
  }

  protected parseAlphaId(tlvList: Array<Tlv>): boolean {
    let menuTitleInfo = DecodeItemUtil.parseAlphaIdNew(tlvList);
    this.menuTitle = menuTitleInfo.data ?? '';
    return true;
  }
}