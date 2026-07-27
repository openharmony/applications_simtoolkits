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
import { LengthMetrics } from '@kit.ArkUI';
import { AppStorageKey } from '../helper/AppStorageHelper';

const TAG: string = 'ToastDialog';

@CustomDialog
export default struct ToastDialog {
  controller?: CustomDialogController;
  @Prop private content: string = '';
  private onEvent?: (responseEvent: number) => void;
  @StorageProp(AppStorageKey.FONT_SIZE_SCALE_KEY) fontSizeScale: number = 1;

  aboutToAppear(): void {
    HiLog.info(TAG, `aboutToAppear content:${this.content}`);
  }

  onBackPress(): void {
    HiLog.info(TAG, 'onBackPress');
    this.onEvent?.(UIResponseCode.RESPONSE_TYPE_BACKWARD);
    this.onEvent = undefined;
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
    this.onEvent?.(UIResponseCode.RESPONSE_TYPE_BACKWARD);
    this.onEvent = undefined;
  }

  build() {
    Row() {
      Blank()

      Row() {
        Text(this.content)
          .draggable(false)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .lineSpacing(LengthMetrics.vp(LengthMetrics.resource($r('app.float.alert_toast_text_line_spacing')).value *
          this.fontSizeScale))
          .id(ViewId.TOAST_DIALOG_TEXT)
      }
      .id(ViewId.TOAST_DIALOG_TEXT_CONTAINER_ROW)
      .backgroundColor($r('app.color.alert_toast_bg_color'))
      .constraintSize({
        maxWidth: $r('app.float.alert_toast_content_max_width'),
        minHeight: $r('app.float.alert_toast_min_height')
      })
      .borderRadius($r('app.float.alert_toast_radius'))
      .padding({
        left: $r('app.float.alert_toast_padding_horizontal'),
        right: $r('app.float.alert_toast_padding_horizontal'),
        top: (LengthMetrics.resource($r('app.float.alert_toast_padding_vertical_big')).value === 0 ? 1 :
        this.fontSizeScale) * LengthMetrics.resource($r('app.float.alert_toast_padding_vertical')).value,
        bottom: (LengthMetrics.resource($r('app.float.alert_toast_padding_vertical_big')).value === 0 ? 1 :
        this.fontSizeScale) * LengthMetrics.resource($r('app.float.alert_toast_padding_vertical')).value,
      })
      .margin({ bottom: $r('app.float.alert_toast_bottom') })
      .align(Alignment.Bottom)
      .shadow(ShadowStyle.OUTER_DEFAULT_LG)

      Blank()
    }
  }
}