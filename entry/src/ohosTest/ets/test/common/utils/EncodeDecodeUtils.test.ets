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
import { EncodeDecodeUtils } from '../../../../../main/ets/common/utils/EncodeDecodeUtils';
import * as simToolKitConstant from '../../../../../main/ets/common/constant/SimToolKitConstant';

const englishStr: string = 'Enter {} [] () "0"';
const englishStrGsm7Byte: number[] = [69, 55, 189, 44, 7, 109, 80, 155, 20, 104, 195, 219, 248, 64, 168, 20, 72, 4, 19, 1];
const englishStrGsm8Byte: number[] = [69, 110, 116, 101, 114, 32, 27, 40, 27, 41, 32, 27, 60, 27, 62, 32, 40, 41, 32, 34, 48, 34];
const chineseStr: string = '中国 2023/6/19 Chinese';
const chineseStrUCS2: number[] = [78, 45, 86, 253, 0, 32, 0, 50, 0, 48, 0, 50, 0, 51, 0, 47, 0, 54, 0, 47, 0, 49, 0, 57, 0, 32, 0, 67, 0, 104, 0, 105, 0, 110, 0, 101, 0, 115, 0, 101];
const asciiStr: string = 'Chinese 2023';
const asciiStrByte: number[] = [67, 104, 105, 110, 101, 115, 101, 32, 50, 48, 50, 51];

export default function EncodeDecodeUtilsTest() {
  describe('EncodeDecodeUtilsTest', () => {
    it('hexStringToNumberArr', 0, () => {
      let hexString = '164537BD2C076D509B1468C3DBF840A81448041301';
      let arrNumberResult: number[] = [22, 69, 55, 189, 44, 7, 109, 80, 155, 20, 104, 195, 219, 248, 64, 168, 20, 72, 4, 19, 1];
      let arrNumber = EncodeDecodeUtils.getInstance().hexStringToNumberArr(hexString);
      expect(arrNumberResult.join(',')).assertEqual(arrNumber.join(','));
    })
    it('stringToGsm7BitPacked', 0, () => {
      let arrNumber = EncodeDecodeUtils.getInstance().stringToGsm7BitPacked(englishStr);
      expect(englishStrGsm7Byte.join(',')).assertEqual(arrNumber.join(','));
    })
    it('gsm7BitPackedToString', 0, () => {
      let encodeStr = EncodeDecodeUtils.getInstance().gsm7BitPackedToString(englishStrGsm7Byte);
      expect(englishStr).assertEqual(encodeStr);
    })
    it('stringToGsm8BitPacked', 0, () => {
      let arrNumber = EncodeDecodeUtils.getInstance().stringToGsm8BitPacked(englishStr);
      expect(englishStrGsm8Byte.join(',')).assertEqual(arrNumber.join(','));
    })
    it('gsm8BitPackedToString', 0, () => {
      let encodeStr = EncodeDecodeUtils.getInstance().gsm8BitPackedToString(englishStrGsm8Byte);
      expect(englishStr).assertEqual(encodeStr);
    })
    it('stringToUTF16BEArray', 0, () => {
      let arrNumber = EncodeDecodeUtils.getInstance().stringToUTF16BEArray(chineseStr);
      expect(chineseStrUCS2.join(',')).assertEqual(arrNumber.join(','));
    })
    it('arrayUTF16BEToString', 0, () => {
      let encodeStr = EncodeDecodeUtils.getInstance().arrayUTF16BEToString(chineseStrUCS2);
      expect(chineseStr).assertEqual(encodeStr);
    })
    it('arrayAsciiToString', 0, () => {
      let encodeStr = EncodeDecodeUtils.getInstance().arrayAsciiToString(asciiStrByte);
      expect(asciiStr).assertEqual(encodeStr);
    })
    it('encodeStringToNumberArray_UCS2_test', 0, () => {
      let arrNumber = EncodeDecodeUtils.getInstance()
        .encodeStringToNumberArray(chineseStr, simToolKitConstant.EncodeType.UCS2);
      expect(chineseStrUCS2.join(',')).assertEqual(arrNumber.join(','));
    })
    it('encodeStringToNumberArray_GSM7_test', 0, () => {
      let arrNumber = EncodeDecodeUtils.getInstance()
        .encodeStringToNumberArray(englishStr, simToolKitConstant.EncodeType.GSM7);
      expect(englishStrGsm7Byte.join(',')).assertEqual(arrNumber.join(','));
    })
    it('encodeStringToNumberArray_GSM8_test', 0, () => {
      let arrNumber = EncodeDecodeUtils.getInstance()
        .encodeStringToNumberArray(englishStr, simToolKitConstant.EncodeType.GSM8);
      expect(englishStrGsm8Byte.join(',')).assertEqual(arrNumber.join(','));
    })
    it('decodeNumberArrayToString_UCS2_test', 0, () => {
      let arrNumber: number[] = [0x08];
      chineseStrUCS2.forEach((value: number) => {
        arrNumber.push(value);
      });
      let encodeStr = EncodeDecodeUtils.getInstance().decodeNumberArrayToString(arrNumber);
      expect(chineseStr).assertEqual(encodeStr);
    })
    it('decodeNumberArrayToString_UCS2_TWO_test', 0, () => {
      let arrNumber: number[] = [0x80];
      chineseStrUCS2.forEach((value: number) => {
        arrNumber.push(value);
      });
      let encodeStr = EncodeDecodeUtils.getInstance().adnStringFieldToStringForSTK(arrNumber, 0, arrNumber.length);
      expect(chineseStr).assertEqual(encodeStr);
    })
    it('decodeNumberArrayToString_GSM7_test', 0, () => {
      let arrNumber: number[] = [0x00];
      englishStrGsm7Byte.forEach((value: number) => {
        arrNumber.push(value);
      });
      let encodeStr = EncodeDecodeUtils.getInstance().decodeNumberArrayToString(arrNumber);
      expect(englishStr).assertEqual(encodeStr);
    })
    it('decodeNumberArrayToString_GSM8_test', 0, () => {
      let arrNumber: number[] = [0x04];
      englishStrGsm8Byte.forEach((value: number) => {
        arrNumber.push(value);
      });
      let encodeStr = EncodeDecodeUtils.getInstance().decodeNumberArrayToString(arrNumber);
      expect(englishStr).assertEqual(encodeStr);
    })
    it('decodeNumberArrayToString_default', 0, () => {
      let encodeStr = EncodeDecodeUtils.getInstance().adnStringFieldToStringForSTK(asciiStrByte,
        0, asciiStrByte.length);
      expect(asciiStr).assertEqual(encodeStr);
    })
  })
}