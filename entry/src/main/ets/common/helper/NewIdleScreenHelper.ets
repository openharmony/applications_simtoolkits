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

import { abilityManager, appManager, bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HapInfo, SimId } from '../constant/Constants';
import HiLog from '../utils/HiLog';

const TAG = 'NewIdleScreenHelper';
const HOME_BUNDLE_NAME = 'com.ohos.sceneboard';
const HOME_WINDOW_NAME_PRE = 'SCB';
const OUTER_HOME_BUNDLE_NAME = 'com.ohos.outerhome';

export class NewIdleScreenHelper {
  private static instance: NewIdleScreenHelper;
  private abilityStateChangedObserverId: number | undefined = undefined;
  private idleScreenListenerArr: Array<Map<string, (slotId: number) => void>> =
    [new Map<string, (slotId: number) => void>(), new Map<string, (slotId: number) => void>()];

  public static getInstance(): NewIdleScreenHelper {
    if (!NewIdleScreenHelper.instance) {
      HiLog.info(TAG, 'NewIdleScreenHelper getInstance init');
      NewIdleScreenHelper.instance = new NewIdleScreenHelper();
    }
    return NewIdleScreenHelper.instance;
  }

  private constructor() {
  }

  public registerIdleScreenListener(slotId: number, callBackName: string, callBack: (slotId: number) => void): void {
    HiLog.info(TAG, `registerDisplayText  slotId:${slotId}`);
    if (slotId !== SimId.SLOT_ID_0 && slotId !== SimId.SLOT_ID_1) {
      return;
    }
    if (callBack === undefined || callBack === null) {
      return;
    }
    this.idleScreenListenerArr[slotId].set(callBackName, callBack);
    this.registerAbilityStateChanged();
  }

  public unRegisterIdleScreenListenerForcible(): void {
    this.idleScreenListenerArr[SimId.SLOT_ID_0].clear();
    this.idleScreenListenerArr[SimId.SLOT_ID_1].clear();
    this.unRegisterAbilityStateChanged();
  }

  public unRegisterIdleScreenListener(slotId: number, callBackName: string): void {
    if (slotId !== SimId.SLOT_ID_0 && slotId !== SimId.SLOT_ID_1) {
      return;
    }
    this.idleScreenListenerArr[slotId].delete(callBackName);
    let callBackSize =
      this.idleScreenListenerArr[SimId.SLOT_ID_0].size + this.idleScreenListenerArr[SimId.SLOT_ID_1].size;
    if (callBackSize === 0) {
      this.unRegisterAbilityStateChanged();
    }
  }

  private registerAbilityStateChanged(): void {
    if (this.abilityStateChangedObserverId !== undefined) {
      HiLog.info(TAG, `[registerAbilityStateChanged] already register`);
      return;
    }
    let applicationStateObserver: appManager.ApplicationStateObserver = {
      onAbilityStateChanged(abilityStateData: appManager.AbilityStateData) {
        NewIdleScreenHelper.getInstance().onAbilityStateChangedInner();
      },
      onForegroundApplicationChanged(appStateData: appManager.AppStateData) {
      },
      onAppStarted(appStateData: appManager.AppStateData) {
      },
      onAppStopped(appStateData: appManager.AppStateData) {
      },
      onProcessCreated(processData: appManager.ProcessData) {
      },
      onProcessDied(processData: appManager.ProcessData) {
      },
      onProcessStateChanged(processData: appManager.ProcessData) {
      }
    };
    let bundleNameList = [HOME_BUNDLE_NAME];
    try {
      this.abilityStateChangedObserverId = appManager.on('applicationState', applicationStateObserver, bundleNameList);
    } catch (paramError) {
      let error = paramError as BusinessError;
      HiLog.info(TAG, `[registerAbilityStateChanged] error: ${error.code}, ${error.message} `);
    }
  }

  private unRegisterAbilityStateChanged(): void {
    if (this.abilityStateChangedObserverId === undefined) {
      return;
    }
    HiLog.info(TAG, '[unRegisterAbilityStateChanged] start');
    try {
      appManager.off('applicationState', this.abilityStateChangedObserverId);
      this.abilityStateChangedObserverId = undefined;
    } catch (paramError) {
      let error = paramError as BusinessError;
      HiLog.info(TAG, `[unRegisterAbilityStateChanged] error: ${error.code}, ${error.message} `);
    }
  }

  private onScreenIdle(slotId: number): void {
    this.idleScreenListenerArr[slotId].forEach(
      (value: (slotId: number) => void, key: string, map: Map<string, (slotId: number) => void>) => {
        HiLog.info(TAG, `onScreenIdle key:${key}`);
        value(slotId);
      });
    this.idleScreenListenerArr[slotId].clear();
  }

  public async onAbilityStateChangedInner(): Promise<void> {
    let isHomeTop = await this.isHomeAbilityTop();
    HiLog.info(TAG, `onAbilityStateChangedInner isHomeTop:${isHomeTop}`);
    if (isHomeTop) {
      this.onScreenIdle(SimId.SLOT_ID_0);
      this.onScreenIdle(SimId.SLOT_ID_1);
      this.unRegisterAbilityStateChanged();
    }
  }

  private checkHomeAbilityInner(bundleName?: string): boolean {
    if (bundleName === undefined || bundleName === null || bundleName.length === 0) {
      return false;
    }
    return HOME_BUNDLE_NAME === bundleName || bundleName?.startsWith(HOME_WINDOW_NAME_PRE);
  }

  private isOnlyOuterHome(abilityStateData: Array<abilityManager.AbilityStateData>): boolean {
    if (abilityStateData !== undefined && abilityStateData.length === 1) {
      return abilityStateData[0].bundleName === OUTER_HOME_BUNDLE_NAME;
    }
    return false;
  }

  public async isHomeAbilityTop(): Promise<boolean> {
    let isHomeTop: boolean = false;
    try {
      let abilityStateData: abilityManager.AbilityStateData[] = await abilityManager.getForegroundUIAbilities();
      if (abilityStateData === undefined || abilityStateData.length === 0 || this.isOnlyOuterHome(abilityStateData)) {
        let topElementName: bundleManager.ElementName = await abilityManager.getTopAbility();
        isHomeTop = this.checkHomeAbilityInner(topElementName?.bundleName);
      } else {
        isHomeTop = false;
      }
    } catch (err) {
      let error = err as BusinessError;
      HiLog.info(TAG, `[isHomeAbilityTop] error: ${error.code}, ${error.message} `);
    }
    return Promise.resolve(isHomeTop);
  }

  public async isHomeOrStkAbilityTop(): Promise<boolean> {
    let isTop: boolean = false;
    try {
      let isTopHome = await this.isHomeAbilityTop();
      let topElementName: bundleManager.ElementName = await abilityManager.getTopAbility();
      if (isTopHome || HapInfo.BUNDLE_NAME === topElementName?.bundleName) {
        isTop = true;
      }
    } catch (err) {
      let error = err as BusinessError;
      HiLog.info(TAG, `[isHomeOrStkAbilityTop] error: ${error.code}, ${error.message} `);
    }
    return Promise.resolve(isTop);
  }
}