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

import HiLog from '../../common/utils/HiLog';
import { ViewId } from '../constant/Constants';
import { LengthMetrics } from '@kit.ArkUI';

const TAG = 'NavBack';

export enum NavCallBackType {
  BACK,
  END_SESSION,
  HELP
}

@Component
export default struct NavBack {
  @Prop headName: string = '';
  callBack?: (type: NavCallBackType) => void = undefined;
  @Link menuItems: Array<NavCallBackType>;
  @Link isShowMenu: boolean;

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
  }

  build() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize($r('app.float.wh_24'))
          .fontColor([$r('sys.color.icon_primary')])
      }
      .id(ViewId.NAV_BACK_BACK)
      .accessibilityText($r('sys.string.icon_back'))
      .type(ButtonType.Circle)
      .size({ width: $r('app.float.wh_40'), height: $r('app.float.wh_40') })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        HiLog.info(TAG, 'onclick BACK');
        this.callBack?.(NavCallBackType.BACK);
      })

      Scroll(new Scroller()) {
        Text(this.headName)
          .draggable(false)
          .fontSize($r('app.float.font_20'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .id(ViewId.NAV_BACK_TEXT)
          .maxLines(1)
          .maxFontScale(1)
      }
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
      .align(Alignment.Start)
      .margin({ left: $r('app.float.wh_8'), right: $r('app.float.wh_8') })
      .draggable(false)
      .layoutWeight(1)
      .height('100%')

      Button({ type: ButtonType.Circle }) {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize($r('app.float.wh_24'))
          .fontColor([$r('sys.color.icon_primary')])
      }
      .id(ViewId.NAV_BACK_MENU)
      .accessibilityText($r('sys.string.ohos_toolbar_more'))
      .size({ width: $r('app.float.wh_40'), height: $r('app.float.wh_40') })
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .bindMenu(this.isShowMenu, this.MenuBuilder(), {
        onDisappear: () => {
          HiLog.info(TAG, 'menu popup onDisAppear');
          this.isShowMenu = false;
        },
        placement: Placement.BottomRight
      })
      .visibility(this.menuItems.length > 0 ? Visibility.Visible : Visibility.Hidden)
      .onClick(() => {
        this.isShowMenu = true;
      })
    }
    .width('100%')
    .height($r('app.float.wh_56'))
  }

  @Builder
  MenuBuilder() {
    if (this.menuItems.length >= 0) {
      Menu() {
        ForEach(this.menuItems, (item: NavCallBackType, index: number) => {
          MenuItem({
            content: item === NavCallBackType.END_SESSION ? $r('app.string.end_session') : $r('app.string.help')
          })
            .id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}${index}`)
            .constraintSize({
              minHeight: $r('app.float.wh_48'),
              minWidth: $r('app.float.wh_224')
            })
            .contentFont({ weight: FontWeight.Medium, size: $r('sys.float.Subtitle_M') })
            .onClick(() => {
              HiLog.info(TAG, `menu onclick: ${item}`);
              this.callBack?.(item);
            })
        })
      }
      .menuItemDivider({
        strokeWidth: LengthMetrics.vp(0.5),
        color: $r('sys.color.comp_divider'),
      })
    }
  }
}