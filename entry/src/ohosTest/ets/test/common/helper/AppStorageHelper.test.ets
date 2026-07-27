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

import { describe, it, expect, beforeAll } from '@ohos/hypium'
import { AppStorageHelper } from '../../../../../main/ets/common/helper/AppStorageHelper';

const APP_STORAGE_KEY = 'AppStorageKey';
const APP_STORAGE_Value = 'AppStorageValue';

export default function AppStorageHelperTest() {
  describe('AppStorageHelperTest', () => {
    beforeAll(async (done: Function) => {
      AppStorageHelper.remove(APP_STORAGE_KEY);
      AppStorageHelper.remove('');
      done();
    })
    it('AppStorageHelperTest_get', 0, () => {
      let resultValue = AppStorageHelper.get<string>(APP_STORAGE_KEY, undefined);
      expect(resultValue).assertUndefined();
    })
    it('AppStorageHelperTest_set_nullStr', 0, () => {
      AppStorageHelper.set<string>('', APP_STORAGE_Value);
      let resultValue = AppStorageHelper.get<string>('', undefined);
      expect(resultValue).assertUndefined();
    })
    it('AppStorageHelperTest_set_key', 0, () => {
      AppStorageHelper.set<string>(APP_STORAGE_KEY, APP_STORAGE_Value);
      let resultValue = AppStorageHelper.get<string>(APP_STORAGE_KEY, undefined);
      expect(resultValue).assertEqual(APP_STORAGE_Value);
    })
    it('AppStorageHelperTest_set_remove', 0, () => {
      AppStorageHelper.remove(APP_STORAGE_KEY);
      let resultValue = AppStorageHelper.get<string>(APP_STORAGE_KEY, undefined);
      expect(resultValue).assertUndefined();
    })
  })
}