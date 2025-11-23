import { scanCore, generateBarcode } from '@kit.ScanKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ScenarioFusionViewModel } from '../viewmodel/ScenarioFusionKitModel';
import { AccountViewModel } from '../viewmodel/AccountViewModel';
import AccountViewModelSingleton from '../viewmodel/AccountViewModelSingleton';


@Entry
@Component
struct Index {
  @State pixelMap: image.PixelMap | undefined = undefined
  viewModel = new ScenarioFusionViewModel()
  private vm: AccountViewModel = AccountViewModelSingleton.getInstance()
  data = ''

  async aboutToAppear(): Promise<void> {
    this.viewModel.getDeviceModel()
    this.vm.getInformation()

    this.data = this.viewModel.data
    this.data += this.vm.information
  }

  build() {
    Column() {
      Button('generateBarcode Callback').onClick(() => {
        // Set parameters for generating a barcode image, for example, a QR code image.
        let content = this.data
        let options: generateBarcode.CreateOptions = {
          scanType: scanCore.ScanType.QR_CODE,
          height: 400,
          width: 400
        }
        try {
          // Return a PixelMap-format barcode image.
          generateBarcode.createBarcode(content, options, (error: BusinessError, pixelMap: image.PixelMap) => {
            if (error) {
              hilog.error(0x0001, '[generateBarcode]',
                `Failed to get PixelMap by callback with options. Code: ${error.code}, message: ${error.message}`);
              return;
            }
            this.pixelMap = pixelMap;
          })
        } catch (error) {
          hilog.error(0x0001, '[generateBarcode]',
            `Failed to createBarcode by callback with options. Code: ${error.code}, message: ${error.message}`);
        }
      }).width('80%').height(30)
      // Display the obtained barcode image.
      if (this.pixelMap) {
        Column() {
          Image(this.pixelMap).width('80%').height(100).objectFit(ImageFit.Contain).margin({ top: 16 })
          Button('Cancel Authorization').onClick(() => {
            this.vm.cancelAuth(this.getUIContext())
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/Index'
            })

          }).width('80%').height(30).margin({top:16})
        }
      }
    }
    .width('100%')
    .height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
  }
}