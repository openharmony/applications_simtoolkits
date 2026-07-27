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

import HiLog from '../utils/HiLog';
import { UIResponseCode } from '../constant/SimToolKitConstant';
import { ViewId } from '../constant/Constants';

const TAG: string = 'ToneDialog';

@CustomDialog
export default struct ToneDialog {
  controller?: CustomDialogController;
  @Prop private content: string = '';
  private onEvent?: (responseEvent: number) => void;

  aboutToAppear(): void {
    HiLog.info(TAG, `aboutToAppear content:${this.content}`);
  }

  onBackPress(): void {
    HiLog.info(TAG, 'onBackPress');
    this.onEvent?.(UIResponseCode.RESPONSE_TYPE_BACKWARD);
    this.onEvent = undefined;
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear')
    this.onEvent?.(UIResponseCode.RESPONSE_TYPE_BACKWARD);
    this.onEvent = undefined;
  }

  build() {
    Row() {
      Blank()
      Column() {
        Image($r('app.media.ic_volume'))
          .draggable(false)
          .width($r('app.float.alert_tone_ic_width'))
          .height($r('app.float.alert_tone_ic_height'))
        Text(this.content)
          .draggable(false)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('app.float.alert_window_content_font_size'))
          .margin({ top: $r('app.float.alert_window_content_margin') })
      }
      .id(ViewId.PLAY_TONE_VIEW)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .padding($r('app.float.alert_dialog_vertical_padding'))
      .margin($r('app.float.alert_dialog_vertical_padding'))
      .borderRadius($r('app.float.alert_dialog_radius'))

      Blank()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}