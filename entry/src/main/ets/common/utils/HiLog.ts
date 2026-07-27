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

import { hilog as Log } from '@kit.PerformanceAnalysisKit';

const TAG = 'SimToolKitLog';
const DOMAIN = 0x0900;

export default class HiLog {
  private static readonly COLON: string = ': ';

  constructor() {
  }

  private static prefix(tag: string): string {
    return tag + this.COLON;
  }

  static debug(tag: string, msg: string): void {
    Log.debug(DOMAIN, TAG, this.prefix(tag) + msg);
  }

  static info(tag: string, msg: string): void {
    Log.info(DOMAIN, TAG, this.prefix(tag) + msg);
  }

  static warn(tag: string, msg: string): void {
    Log.warn(DOMAIN, TAG, this.prefix(tag) + msg);
  }

  static error(tag: string, msg: string): void {
    Log.error(DOMAIN, TAG, this.prefix(tag) + msg);
  }
}