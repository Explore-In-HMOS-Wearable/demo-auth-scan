import { AccountKitHelper } from '../helper/Accountkit'

export class AccountViewModel {
  private _loading: boolean = false
  private _information = ''

  public set information(value) {
    this._information = value
  }

  public get information() {
    return this._information
  }

  public set loading(value: boolean) {
    this._loading = value
  }

  public get loading(): boolean {
    return this._loading
  }

  private _error: boolean = false

  public set error(value: boolean) {
    this._error = value
  }

  public get error(): boolean {
    return this._error
  }

  private _message: string = ''

  public set message(value: string) {
    this._message = value
  }

  public get message(): string {
    return this._message
  }


  async verifyAccount(context: UIContext): Promise<boolean> {
    let account = new AccountKitHelper()
    try {
      this._loading = false
      let result = await account.loginWithHuaweiId(context)
      if (!result) {
        this._message = account.error
        return false
      }
      this._information = 'Huawei Open ID : ' + account.openID + '\n' +
        'Huawei Union Id: ' + account.unionID
    } catch (e) {
      this._error = true

    } finally {
      this._loading = false
    }
    return true
  }

  async getInformation(): Promise<string> {
    return this._information
  }

  cancelAuth(context:UIContext){
    let account = new AccountKitHelper()
    account.cancelAuthRequest(context)
  }
}