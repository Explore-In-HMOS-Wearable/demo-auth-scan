
import { ScenarioFusionKitHelper } from '../helper/ScenarioFusionKit'


export class ScenarioFusionViewModel {
  private _loading: boolean = false
  private _data = ''

  public set data(value) {
    this._data = value
  }

  public get data() {
    return this._data
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


  async getDeviceModel() : Promise<string>{

    try {
      const temp= new ScenarioFusionKitHelper()
      this._data = temp.getDeviceInformation()

    } catch (e) {
      this._error = true

    } finally {
      this._loading = false
    }
    return this._data

  }
}