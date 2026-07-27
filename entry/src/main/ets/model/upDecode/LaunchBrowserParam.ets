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
import { LaunchBrowserMode, ResponseCode } from '../../common/constant/SimToolKitConstant';
import { Tlv } from './Tlv';

export class LaunchBrowserParam extends BaseUpParams {
  public url: string = '';
  public confirmText: string = '';
  public launchBrowserMode: number = -1;

  private parseLaunchBrowserMode(): void {
    if (this.commandQual === LaunchBrowserMode.USE_EXISTING_BROWSER ||
      this.commandQual === LaunchBrowserMode.LAUNCH_NEW_BROWSER) {
      this.launchBrowserMode = this.commandQual;
    } else {
      this.launchBrowserMode = LaunchBrowserMode.LAUNCH_IF_NOT_ALREADY_LAUNCHED;
    }
  }

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.parseLaunchBrowserMode();
      this.url = DecodeItemUtil.parseUrl(tlvList, false) ?? '';
      this.confirmText = DecodeItemUtil.parseAlphaId(tlvList, false) ?? '';
    }
  }
}