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

import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { Driver, ON } from '@ohos.UiTest';
import { expect } from '@ohos/hypium';
import Want from '@ohos.app.ability.Want';
import commonEventManager from '@ohos.commonEventManager';
import { BaseUpParams } from '../../../main/ets/model/upDecode/BaseUpParams';
import CommonUtils from '../../../main/ets/common/utils/CommonUtils';
import { HapInfo, PageUrl, ViewId } from '../../../main/ets/common/constant/Constants';
import HiLog from '../../../main/ets/common/utils/HiLog';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@ohos.base';
import { CommonTestHex, DELAY_TIME, DELAY_TIME_1000, DELAY_TIME_3000 } from './constants/TestConstants';
import { SLOT_ID } from './constants/TestConstants';

export interface ParseParamData {
  commandHex: string
}

export async function inputTextCust(driver: Driver, text: string): Promise<void> {
  let input = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
    DELAY_TIME_3000);
  await input.inputText(text);
  await driver.delayMs(DELAY_TIME);

  let textStr = await driver.findComponent(ON.text('小艺输入法'));
  let okStr = await driver.findComponent(ON.text('同意'));
  if (textStr && okStr) {
    await okStr.click();
    await driver.delayMs(DELAY_TIME);
  }

  let text2Str = await driver.findComponent(ON.text('请选择中文键盘布局'));
  let ok2Str = await driver.findComponent(ON.text('下一步'));
  if (text2Str && ok2Str) {
    await ok2Str.click();
    await driver.delayMs(DELAY_TIME);
  }

  let input3 = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
    DELAY_TIME_3000);
  if (input3) {
    await input3.clearText();
    await input3.inputText(text);
  }
}

export async function startAbilityMine(
  slotId: number, upParam: BaseUpParams | undefined, pageUrl: string, delayTime: number = 0): Promise<void> {
  let data: Record<string, Object> = {
    'pageUrl': pageUrl,
    'slotId': slotId
  };
  if (upParam !== undefined) {
    data['upParam'] = upParam;
  }
  let abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
  await abilityDelegator.startAbility({
    bundleName: HapInfo.BUNDLE_NAME,
    abilityName: HapInfo.MAIN_ABILITY,
    parameters: data
  });
  let driver = Driver.create();
  if (delayTime === 0) {
    await driver.delayMs(DELAY_TIME_1000);
  } else {
    await driver.delayMs(delayTime);
  }
}

export async function sendCommandHex(commandHex: string, slotId?: number, delayTime: number = 0): Promise<void> {
  let data: Record<string, Object> = {
    'msgCmd': commandHex,
    'slotId': slotId ?? SLOT_ID
  };
  let abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
  await abilityDelegator.startAbility({
    bundleName: HapInfo.BUNDLE_NAME,
    abilityName: HapInfo.SERVICE_ABILITY_NAME,
    action: commonEventManager.Support.COMMON_EVENT_STK_COMMAND,
    parameters: data
  });
  let driver = Driver.create();
  if (delayTime === 0) {
    await driver.delayMs(DELAY_TIME_1000);
  } else {
    await driver.delayMs(delayTime);
  }
}

export async function sendEndSession(delayTime: number = 0): Promise<void> {
  let abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
  let data: Record<string, Object> = {
    'slotId': SLOT_ID
  };
  await abilityDelegator.startAbility({
    bundleName: HapInfo.BUNDLE_NAME,
    abilityName: HapInfo.SERVICE_ABILITY_NAME,
    action: commonEventManager.Support.COMMON_EVENT_STK_SESSION_END,
    parameters: data
  });
  let driver = Driver.create();
  if (delayTime === 0) {
    await driver.delayMs(DELAY_TIME_1000);
  } else {
    await driver.delayMs(delayTime);
  }
}

export async function startSecondMenuPage(): Promise<void> {
  await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
  let driver = Driver.create();
  let backButton = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}0`),
    DELAY_TIME_3000);
  expect(!CommonUtils.isEmptyObj(backButton)).assertTrue();
  await backButton.click();
  await driver.delayMs(DELAY_TIME);
  await sendCommandHex(CommonTestHex.SELECT_ITEM);
}

export async function startLaunchBrowser(): Promise<void> {
  // start browser
  let uri = 'xxx.yyy.zzz';
  let uriSplit = '://';
  let want: Want = {
    'action': 'ohos.want.action.viewData',
    'entities': ['entity.system.browsable'],
    'uri': `http${uriSplit}${uri}`
  };
  let abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
  abilityDelegator.startAbility(want);
  let driver = Driver.create();
  await driver.delayMs(DELAY_TIME_3000);
}

export function sleep(time: number): Promise<void> {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve();
    }, time);
  });
}

export async function setMock(
  abilityDelegator: abilityDelegatorRegistry.AbilityDelegator, jsonPath: string): Promise<void> {
  let rawFile: Uint8Array;
  let tag = 'setMock';
  try {
    let moduleName = abilityDelegatorRegistry.getArguments().parameters['-m'];
    let context = abilityDelegator.getAppContext().getApplicationContext().createModuleContext(
      HapInfo.BUNDLE_NAME, moduleName);
    rawFile = context.resourceManager.getRawFileContentSync(jsonPath);
    HiLog.info(tag, 'MockList file exists');
    let mockStr: string = util.TextDecoder.create('utf-8', { ignoreBOM: true }).decodeToString(rawFile);
    let mockMap: Record<string, string> = getMockList(mockStr);
    try {
      abilityDelegator.setMockList(mockMap);
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      HiLog.error(tag, `abilityDelegator.setMockList failed, error code: ${code}, message: ${message}.`);
    }
  } catch (error) {
    let code = (error as BusinessError).code;
    let message = (error as BusinessError).message;
    HiLog.error(tag, `ResourceManager:callback getRawFileContent failed, error code: ${code}, message: ${message}.`);
  }
}

function getMockList(jsonStr: string): Record<string, string> {
  let tag = 'getMockList';
  let jsonObj: Record<string, Object> = JSON.parse(jsonStr);
  let map: Map<string, object> = new Map<string, object>(Object.entries(jsonObj));
  let mockList: Record<string, string> = {};
  map.forEach((value: object, key: string) => {
    let realValue: string = value['source'].toString();
    mockList[key] = realValue;
  });
  HiLog.info(tag, 'mock-json value:' + JSON.stringify(mockList) ?? '');
  return mockList;
}