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

import { describe, it, expect } from '@ohos/hypium';
import { sharedPreferencesUtils } from '../../../../../main/ets/common/utils/SharedPreferencesUtils';
import TestApplication from '../../../application/TestApplication';

const TEST_STRING_KEY = 'test_string_key';
const TEST_ARRAY_KEY = 'test_array_key';

export default function SharedPreferencesUtilsTest() {
  describe('SharedPreferencesUtilsTest', () => {
    it('sharedPreferencesUtils_query', 0, async () => {
      await sharedPreferencesUtils.saveString(TestApplication.applicationContext, TEST_STRING_KEY,
        'sharedPreferencesUtils_save');
      await sharedPreferencesUtils.saveNumberArray(TestApplication.applicationContext, TEST_ARRAY_KEY, [1, 2, 3]);

      let strResult = await sharedPreferencesUtils.getString(TestApplication.applicationContext, TEST_STRING_KEY, '');
      expect('sharedPreferencesUtils_save').assertEqual(strResult);
      let arrResult = await sharedPreferencesUtils.getNumberArray(TestApplication.applicationContext,
        TEST_ARRAY_KEY);
      expect('1,2,3').assertEqual(arrResult.join(','));
    })
    it('sharedPreferencesUtils_delete', 0, async (done: Function) => {
      sharedPreferencesUtils.deleteToPreferences(TestApplication.applicationContext, TEST_STRING_KEY);
      sharedPreferencesUtils.deleteToPreferences(TestApplication.applicationContext, TEST_ARRAY_KEY);
      expect(TestApplication.applicationContext != undefined).assertTrue();
      setTimeout(() => {
        done();
      }, 1000);
    })
  })
}