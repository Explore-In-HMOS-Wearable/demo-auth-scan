import { AccountViewModel } from '../viewmodel/AccountViewModel';

import AccountViewModelSingleton from '../viewmodel/AccountViewModelSingleton';


@Builder
export function PageTwoBuilder(name: string, param: Object) {
  Index()
}


@Entry
@Component
struct Index {
  private message: string = 'Login With Huawei ID';
  viewModel: AccountViewModel = AccountViewModelSingleton.getInstance()
  @State handlePopup: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();
  // Popup builder
  @Builder
  popupBuilder() {
    Column({ space: 2 }) {
      Text('Custom Popup').fontSize(10)
    }.width(100).height(50).padding(5)
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button(this.message)
          .width('%60')
          .height('20%')
          .borderRadius(10)
          .shadow(8)
          .backgroundColor('#446E94')
          .bindPopup(this.handlePopup, {
            message: this.viewModel.message,
            messageOptions: {
              textColor: Color.Red,
              font: {
                size: '14vp',
                style: FontStyle.Italic,
                weight: FontWeight.Bolder
              }
            },
            placement: Placement.Bottom,
            enableArrow: false,
            followTransformOfTarget: true,
            onStateChange: (e) => {
              let timer = setTimeout(() => {
                this.handlePopup = false;
              }, 6000);
              if (!e.isVisible) {
                this.handlePopup = false;
                clearTimeout(timer);
              }
            }
          })
      }
      .onClick(async () => {
        const result = await this.viewModel.verifyAccount(this.getUIContext())
        if (result) {
          this.pageInfos.pushPath({
            name:`Scan`
          })
        } else {

          this.handlePopup = !this.handlePopup;

        }
      })
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#EAEAEA')
    }.hideTitleBar(true).hideBackButton(true)
  }
}