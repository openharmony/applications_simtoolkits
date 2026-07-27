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

import { AbilityStage, ConfigurationConstant, Configuration } from '@kit.AbilityKit';
import HiLog from '../common/utils/HiLog';
import { SetUpEventListHelper } from '../common/helper/SetUpEventListHelper';
import { AppStorageHelper, AppStorageKey } from '../common/helper/AppStorageHelper';
import { EventHub } from '../common/constant/Constants';

const TAG = 'SimToolKitApplication';

export default class SimToolKitApplication extends AbilityStage {
  private systemLanguage: string | undefined = undefined;
  private colorMode: ConfigurationConstant.ColorMode | undefined = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  private fontSizeScale: number | undefined = 1;

  onCreate(): void {
    HiLog.info(TAG, 'AbilityStage onCreate');
    this.systemLanguage = this.context.config.language;
    this.colorMode = this.context.config.colorMode;
    this.fontSizeScale = this.context.config.fontSizeScale;
    AppStorageHelper.set<number>(AppStorageKey.FONT_SIZE_SCALE_KEY, this.fontSizeScale ?? 1);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    if (this.systemLanguage && newConfig.language && this.systemLanguage !== newConfig.language) {
      HiLog.info(TAG, 'systemLanguage changed');
      this.systemLanguage = newConfig.language;
      SetUpEventListHelper.getInstance().languageChange(this.systemLanguage);
    }
    if (this.colorMode !== newConfig.colorMode) {
      HiLog.info(TAG, 'colorMode changed');
      this.colorMode = newConfig.colorMode;
      this.context.getApplicationContext().eventHub.emit(EventHub.CONFIG_COLOR_MODE_CHANGE, newConfig.colorMode);
    }
    if (newConfig.fontSizeScale !== undefined && this.fontSizeScale !== newConfig.fontSizeScale) {
      this.fontSizeScale = newConfig.fontSizeScale;
      AppStorageHelper.set<number>(AppStorageKey.FONT_SIZE_SCALE_KEY, newConfig.fontSizeScale);
    }
  }
}