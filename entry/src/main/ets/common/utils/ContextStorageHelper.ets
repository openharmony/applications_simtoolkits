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

import { common } from '@kit.AbilityKit';
import HiLog from './HiLog';

const TAG = 'ContextStorageHelper';

export class ContextStorageHelper {
  private static instance: ContextStorageHelper;
  private entryUiContext: common.UIAbilityContext | undefined;
  private serviceContext: common.ServiceExtensionContext | undefined;

  public static getInstance(): ContextStorageHelper {
    if (!ContextStorageHelper.instance) {
      HiLog.info(TAG, 'ContextStorageHelper getInstance init');
      ContextStorageHelper.instance = new ContextStorageHelper();
    }
    return ContextStorageHelper.instance;
  }

  private constructor() {
  }

  public setEntryUiContext(context: common.UIAbilityContext | undefined): void {
    this.entryUiContext = context;
  }

  public getEntryUiContext(): common.UIAbilityContext | undefined {
    return this.entryUiContext;
  }

  public setServiceContext(context: common.ServiceExtensionContext | undefined): void {
    this.serviceContext = context;
  }

  public getServiceContext(): common.ServiceExtensionContext | undefined {
    return this.serviceContext;
  }
}