import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';

export class AccountKitHelper {
  private _code: string = '';

  public set code(value: string) {
    this._code = value;
  }

  public get code(): string {
    return this._code;
  }

  private _idToken: string = '';

  public set idToken(value: string) {
    this._idToken = value;
  }

  public get idToken(): string {
    return this._idToken;
  }

  private _openID: string = '';

  public set openID(value: string) {
    this._openID = value;
  }

  public get openID(): string {
    return this._openID;
  }

  private _unionID: string = '';

  public set unionID(value: string) {
    this._unionID = value;
  }

  public get unionID(): string {
    return this._unionID;
  }

  private _error: string = '';

  public set error(value: string) {
    this._error = value;
  }

  public get error(): string {
    return this._error;
  }

  async loginWithHuaweiId(context: UIContext): Promise<Boolean> {
    // Create a sign-in request and set parameters.
    const loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // The default value is true. If no HUAWEI ID has signed in, the HUAWEI ID sign-in screen will be forcibly shown.
    loginRequest.forceLogin = true;
    loginRequest.idTokenSignAlgorithm = authentication.IdTokenSignAlgorithm.PS256; // The default value is PS256.
    loginRequest.state = util.generateRandomUUID(); // You are advised to use generateRandomUUID to generate a state.

    // Execute the sign-in request.
    try {

      const controller = new authentication.AuthenticationController(context.getHostContext());
      await controller.executeRequest(loginRequest).then((response: authentication.LoginWithHuaweiIDResponse) => {
        const loginWithHuaweiIDResponse = response as authentication.LoginWithHuaweiIDResponse;
        const state = loginWithHuaweiIDResponse.state;
        if (state && loginRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to login. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in logging in.');
        const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse?.data;
        const code = loginWithHuaweiIDCredential?.authorizationCode;
        const idToken = loginWithHuaweiIDCredential?.idToken;
        const openID = loginWithHuaweiIDCredential?.openID
        const unionID = loginWithHuaweiIDCredential?.unionID
        if (code !== undefined && idToken !== undefined && unionID !== undefined && openID !== undefined) {
          this._code = code
          this._idToken = idToken
          this._unionID = unionID
          this._openID = openID
        }


        // Process the authorization code and ID token.
      }).catch((error: BusinessError) => {
        this.dealAllError(error);
        this._error = error.message
        return false
      })
    } catch (error) {
      this.dealAllError(error);
      this._error = error.message
      return false
    }

    return true
  }

  cancelAuthRequest(context: UIContext) {
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID(); // You are advised to use generateRandomUUID to generate a state.

    // Execute the authorization revoking request and process the result.
    try {
      const controller = new authentication.AuthenticationController(context.getHostContext());
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        if (error) {
          this.dealAllErrorCancel(error);
          return;
        }
        const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
        const state = cancelAuthorizationResponse.state;
        if (state && cancelRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to cancel. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  dealAllError(error: BusinessError): void {
    hilog.error(0x0000, 'testTag', `Failed to login. Code: ${error.code}, message: ${error.message}`);
    // In sign-in scenarios involving UI interactions,
    // it is advised to guide the user with the following error code prompts:
    if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
      // HUAWEI ID not signed in. Use a HUAWEI ID to sign in and try again, or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
      // A network exception occurs. Check the current network status
      // and try again, or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_INTERNAL_ERROR) {
      // Failed to sign in. Try another way.
    } else if (error.code === ErrorCode.ERROR_CODE_USER_CANCEL) {
      // Authorization canceled by the user.
    } else if (error.code === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
      // System service exception. Try again later or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
      // Repeated request. No further action is needed.
    } else {
      // Failed to sign in. Try another way.
    }
  }

  dealAllErrorCancel(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag', `Failed to cancel. Code: ${error.code}, message: ${error.message}`);
    // In sign-in scenarios that involve UI interactions,
    // it is advised to display the following error messages to users:
    if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
      // HUAWEI ID not signed in. Use a HUAWEI ID to sign in and try again, or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
      // A network exception occurs. Check the current network status and
      // try again, or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_INTERNAL_ERROR) {
      // Failed to sign in. Try another way.
    } else if (error.code === ErrorCode.ERROR_CODE_USER_CANCEL) {
      // Authorization canceled.
    } else if (error.code === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
      // System service exception. Try again later or sign in to the app in another way.
    } else if (error.code === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
      // Repeated request. No further action is needed.
    } else {
      // Failed to sign in. Try another way.
    }
  }
}


export enum ErrorCode {
  // HUAWEI ID not signed in.
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // Network error.
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  // Internal error.
  ERROR_CODE_INTERNAL_ERROR = 1001502009,
  // Authorization canceled by the user.
  ERROR_CODE_USER_CANCEL = 1001502012,
  // System service exception.
  ERROR_CODE_SYSTEM_SERVICE = 12300001,
  // Repeated request.
  ERROR_CODE_REQUEST_REFUSE = 1001500002
}

