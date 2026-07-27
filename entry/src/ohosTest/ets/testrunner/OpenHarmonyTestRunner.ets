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

import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import { TestRunner } from '@kit.TestKit';
import { UIAbility } from '@kit.AbilityKit';
import HiLog from '../../../main/ets/common/utils/HiLog';

const TAG: string = 'OpenHarmonyTestRunner';
let abilityDelegator: AbilityDelegatorRegistry.AbilityDelegator | undefined = undefined;
let abilityDelegatorArguments: AbilityDelegatorRegistry.AbilityDelegatorArgs | undefined = undefined;
const global: object = new Function('return this')();

async function onAbilityCreateCallback(data: UIAbility) {
  HiLog.info(TAG, 'onAbilityCreateCallback');
  AppStorage.setOrCreate('TestAbility', data);
}

async function onAbilityDestroyCallback(data: UIAbility) {
  HiLog.info(TAG, `onAbilityDestroyCallback : ${JSON.stringify(data) ?? ''}s`);
  AppStorage.delete('TestAbility');
}

async function addAbilityMonitorCallback(err: Error) {
  HiLog.info(TAG, `addAbilityMonitorCallback : ${JSON.stringify(err) ?? ''}s`);
}

export default class OpenHarmonyTestRunner implements TestRunner {
  constructor() {
  }

  onPrepare() {
    HiLog.info(TAG, 'OnPrepare');
  }

  async onRun() {
    HiLog.info(TAG, 'OpenHarmonyTestRunner onRun run');
    abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments();
    abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
    const moduleName: string = abilityDelegatorArguments.parameters['-m'];
    const bundleName: string = abilityDelegatorArguments.bundleName;
    const testAbilityName: string = 'TestAbility';
    let uid: number = Math.floor(abilityDelegator.getAppContext().applicationInfo.uid / 200000);
    global['__savePath__'] = '/data/storage/el2/base/js_coverage.json';
    global['__readPath__'] = `/data/app/el2/${uid}/base/${bundleName}/js_coverage.json`;
    global['__testMode__'] = 'ohostest';
    const lMonitor: AbilityDelegatorRegistry.AbilityMonitor = {
      abilityName: testAbilityName,
      onAbilityCreate: onAbilityCreateCallback,
      onAbilityDestroy: onAbilityDestroyCallback,
      moduleName: moduleName
    };
    abilityDelegator.addAbilityMonitor(lMonitor, addAbilityMonitorCallback);
    const want: Want = {
      bundleName: bundleName,
      abilityName: testAbilityName,
      moduleName: moduleName
    };
    abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
    abilityDelegator.startAbility(want).then((data: void) => {
      HiLog.info(TAG, `startAbility: data : ${JSON.stringify(data) ?? ''}`);
    }).catch((err: BusinessError) => {
      HiLog.info(TAG, `startAbility: err : ${JSON.stringify(err) ?? ''}`);
    });
    HiLog.info(TAG, 'OpenHarmonyTestRunner onRun end.');
  }
}