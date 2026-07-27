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
import { Tlv } from '../../../../../main/ets/model/upDecode/Tlv';

const moreThanTagHex = 'D01F81030120008202810385094469616C20546F6E658E0101840201057F05AA00';
const moreThanLengthHex = 'D081AE81030120008202810385094469616C20546F6E658E0101840201058D8190040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000';
const errorHex = 'D02';

export default function TlvTest() {
  describe('TlvTest', () => {
    it('TlvTest_Tag_moreThanTagHex', 0, () => {
      let rootTlv = new Tlv();
      let resultFlag = Tlv.tlvDecode(moreThanTagHex, rootTlv);
      expect(false).assertEqual(resultFlag);
    })
    it('TlvTest_Tag_set_up_menu', 0, () => {
      let rootTlv = new Tlv();
      let msg: string = 'D03C810301250082028182850C546F6F6C6B6974204D656E758F07014974656D20318F07024974656D20328F07034974656D20339E0201019F0401050505';
      let resultFlag = Tlv.tlvDecode(msg, rootTlv);
      expect(true).assertEqual(resultFlag);
    })
    it('TlvTest_Tag_end_zero', 0, () => {
      let rootTlv = new Tlv();
      let msg: string = 'D02281030125008202818285074D6574666F6E658F0A0150686F6E65626F6F6B00000000';
      let resultFlag = Tlv.tlvDecode(msg, rootTlv);
      expect(true).assertEqual(resultFlag);
    })
    it('TlvTest_Length', 0, () => {
      let rootTlv = new Tlv();
      let resultFlag = Tlv.tlvDecode(moreThanLengthHex, rootTlv);
      expect(true).assertEqual(resultFlag);
    })
    it('TlvTest_ParseToNumberError', 0, () => {
      let rootTlv = new Tlv();
      let resultFlag = Tlv.tlvDecode(errorHex, rootTlv);
      expect(false).assertEqual(resultFlag);
    })
  })
}