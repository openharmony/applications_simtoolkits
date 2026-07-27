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
import { BusinessError, settings, systemParameterEnhance } from '@kit.BasicServicesKit';
import { call, sim } from '@kit.TelephonyKit';
import { i18n, intl } from '@kit.LocalizationKit';
import { router } from '@kit.ArkUI';
import HiLog from './HiLog';
import { ARR_LENGTH_TWO } from '../constant/SimToolKitConstant';
import { HapInfo, SimSwitchState } from '../constant/Constants';

const TAG = 'CommonUtils';
const DEVICE_PROVISIONED = 'device_provisioned';
const DEVICE_PROVISIONED_FALSE = '0';
const DEVICE_PROVISIONED_TRUE = '1';

export default class CommonUtils {
  public static isEmptyStr(text: string): boolean {
    return text === undefined || text === null || text.length === 0;
  }

  public static isEmptyArr<T>(arr: Array<T>): boolean {
    return arr === undefined || arr === null || arr.length === 0;
  }

  public static isEmptyObj<T>(obj: T): boolean {
    return obj === undefined || obj === null;
  }

  public static isSimStateValid(state: sim.SimState): boolean {
    HiLog.info(TAG, `isSimStateValid curState:${state}`);
    return (state === sim.SimState.SIM_STATE_LOADED || state === sim.SimState.SIM_STATE_READY);
  }

  public static getNumberFormat(formatNumber: number): string {
    let systemLanguage = i18n.System.getAppPreferredLanguage();
    let options: intl.NumberOptions = {
      locale: 'Locale'
    };
    let numberFormat: intl.NumberFormat = new intl.NumberFormat(systemLanguage, options);
    return numberFormat.format(formatNumber);
  }

  public static pageBackOrExit(context: common.UIAbilityContext): void {
    if (router.getLength() === '1') {
      CommonUtils.terminateSelfCust(context);
    } else {
      router.back();
    }
  }

  public static terminateSelfCust(context: common.UIAbilityContext | common.ServiceExtensionContext | undefined): void {
    try {
      context?.terminateSelf();
    } catch (error) {
      HiLog.error(TAG, 'terminateSelf error');
      return;
    }
  }

  public static isTwoSimCount(): boolean {
    return sim.getMaxSimCount() === ARR_LENGTH_TWO;
  }

  public static isDeviceProvisioned(context: common.Context | undefined): boolean {
    if (!context) {
      HiLog.warn(TAG, '[isDeviceProvisioned] context is undefined');
    }
    let deviceProvisionedStr = DEVICE_PROVISIONED_TRUE;
    try {
      deviceProvisionedStr = settings.getValueSync(context, DEVICE_PROVISIONED, DEVICE_PROVISIONED_TRUE);
      HiLog.info(TAG, `[isDeviceProvisioned] get device_provisioned: ${deviceProvisionedStr}`);
    } catch (err) {
      HiLog.error(TAG,
        `[isDeviceProvisioned] get device_provisioned failed. Error code: ${err?.code}, message: ${err?.message}`);
    }
    if (deviceProvisionedStr === DEVICE_PROVISIONED_FALSE) {
      return false;
    }
    return true;
  }

  public static isCallStateIdle(): boolean {
    try {
      let isIdle = call.getCallStateSync() === call.CallState.CALL_STATE_IDLE;
      HiLog.debug(TAG, `isCallStateisIdle: ${isIdle}`);
      return isIdle;
    } catch (error) {
      HiLog.error(TAG, 'isCallStateIdle error');
    }
    return false;
  }

  public static getSystemProp(key: string, defVal: string): string {
    try {
      return systemParameterEnhance.getSync(key, defVal);
    } catch (err) {
      HiLog.error(TAG, `get system param error:${err?.code}, ${err?.message}`);
      return defVal;
    }
  }

  public static startServiceExtensionAbility(context: common.UIAbilityContext): void {
    HiLog.info(TAG, 'startServiceExtensionAbility');
    let want = {
      bundleName: HapInfo.BUNDLE_NAME,
      abilityName: HapInfo.SERVICE_ABILITY_NAME,
    };
    context.startServiceExtensionAbility(want).then(() => {
      HiLog.info(TAG, 'startServiceExtensionAbility success.');
    }).catch((err: BusinessError) => {
      HiLog.error(TAG, `startServiceExtensionAbility failed. Code: ${err?.code}, message: ${err?.message}`);
    });
  }

  public static getEsimSwitch(): number {
    try {
      let isSupportEsim = systemParameterEnhance.getSync('const.ril.esim_type', '0') === '3';
      if (!isSupportEsim) {
        return SimSwitchState.PSIM1_PSIM2;
      }
      let esimSwitch = Number(systemParameterEnhance.getSync('persist.ril.sim_switch', ''));
      if (Number.isNaN(esimSwitch)) {
        esimSwitch = SimSwitchState.PSIM1_PSIM2;
      }
      return esimSwitch;
    } catch (err) {
      HiLog.error(TAG, `getEsimSwitch error:${err?.code}, ${err?.message}`);
      return SimSwitchState.PSIM1_PSIM2;
    }
  }
}