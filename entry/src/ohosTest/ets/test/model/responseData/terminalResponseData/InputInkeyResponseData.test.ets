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
import { EncodeDecodeUtils } from '../../../../../../main/ets/common/utils/EncodeDecodeUtils';
import { InputInkeyResponseData } from '../../../../../../main/ets/model/responseData/terminalResponseData/InputInkeyResponseData';
import { Duration } from '../../../../../../main/ets/model/upDecode/BaseUpParams';
import { GetInkeyInputParam } from '../../../../../../main/ets/model/upDecode/GetInkeyInputParam';

const yesNoTypeInputJson = '{"slotId":0,"commandHex":"D0198103012280820281828D0E004537BD2C07896022D071DABC01","commandNumber":1,"commandType":34,"commandQual":128,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"text":"Enter 0 GSM7","duration":0,"isDigitOnly":true,"isUcs2":false,"isYesNo":false,"isHelpAvailable":true,"isEcho":true,"isPacked":false,"responseMinLength":1,"responseMaxLength":1,"defaultText":"","inputEncodeType":4}';
const yesNoTypeYesNoJson = '{"slotId":0,"commandHex":"D05A8103012284820281828D4B0830104E2D56FD79FB52A83011548CFF0C662F73B05728FF0C66F4662F672A6765FF0C62114EEC4E0D65AD521B65B0FF0C8BA94F60548C4F60624073CD89C676844E00520766F44EB28FD10402013C","commandNumber":1,"commandType":34,"commandQual":132,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"text":"【中国移动】和，是现在，更是未来，我们不断创新，让你和你所珍视的一切更亲近","duration":60000,"durationObj":{"timeInterval":60,"timeUnit":1},"isDigitOnly":true,"isUcs2":false,"isYesNo":true,"isHelpAvailable":true,"isEcho":true,"isPacked":false,"responseMinLength":1,"responseMaxLength":1,"defaultText":"","inputEncodeType":4}';
const inputTypeJson = '{"slotId":0,"commandHex":"D01D8103012380820281828D0E00C72215947442AB54D071DABC0111020608","commandNumber":1,"commandType":35,"commandQual":128,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"text":"GET INPUT GSM7","duration":0,"isDigitOnly":true,"isUcs2":false,"isYesNo":false,"isHelpAvailable":true,"isEcho":true,"isPacked":false,"responseMinLength":6,"responseMaxLength":8,"defaultText":"","inputEncodeType":4}';

export default function InputInkeyResponseDataTest() {
  describe('InputInkeyResponseDataTest', () => {
    it('InputInkeyResponseDataTest_yesNo_input', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(yesNoTypeInputJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param);
      inputData.setInputData('8', param.inputEncodeType, 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(inputData.parseDataToHex());
      expect('8103012280020282818301008D020438').assertEqual(hexStr);
    })
    it('InputInkeyResponseDataTest_inputType_input', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(inputTypeJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param,);
      inputData.setInputData('88888888', param.inputEncodeType, 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(inputData.parseDataToHex());
      expect('8103012380020282818301008D09043838383838383838').assertEqual(hexStr);
    })
    it('InputInkeyResponseDataTest_inputType_undefined_code', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(inputTypeJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param,);
      inputData.setInputData('88888888', param.inputEncodeType, undefined);
      let numberArr = inputData.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('InputInkeyResponseDataTest_inputType_encodeType', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(inputTypeJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param,);
      inputData.setInputData('88888888', 9, 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(inputData.parseDataToHex());
      expect('8103012380020282818301008D0109').assertEqual(hexStr);
    })
    it('InputInkeyResponseDataTest_inputType_duration', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(inputTypeJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param);
      inputData.setTimeOutHaveDuration(new Duration(30, 1), 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(inputData.parseDataToHex());
      expect('8103012380020282818301000402011E').assertEqual(hexStr);
    })
    it('InputInkeyResponseDataTest_inputType_duration_code', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(inputTypeJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param);
      inputData.setTimeOutHaveDuration(new Duration(30, 1), undefined);
      let numberArr = inputData.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('InputInkeyResponseDataTest_yesNoType_true', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(yesNoTypeYesNoJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param);
      inputData.setYesNoInKeyData(true, 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(inputData.parseDataToHex());
      expect('8103012284020282818301008D020401').assertEqual(hexStr);
    })
    it('InputInkeyResponseDataTest_yesNoType_false', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(yesNoTypeYesNoJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param);
      inputData.setYesNoInKeyData(false, 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(inputData.parseDataToHex());
      expect('8103012284020282818301008D020400').assertEqual(hexStr);
    })
    it('InputInkeyResponseDataTest_yesNoType_undefined_code', 0, () => {
      let param: GetInkeyInputParam = JSON.parse(yesNoTypeYesNoJson) as GetInkeyInputParam;
      let inputData = new InputInkeyResponseData(param);
      inputData.setYesNoInKeyData(false, undefined);
      let numberArr = inputData.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
  })
}