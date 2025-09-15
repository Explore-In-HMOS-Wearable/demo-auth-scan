import { AccountViewModel } from './AccountViewModel'

class AccountViewModelSingleton {
  private static instance: AccountViewModel

  static getInstance(): AccountViewModel {
    if (!AccountViewModelSingleton.instance) {
      AccountViewModelSingleton.instance = new AccountViewModel()
    }
    return AccountViewModelSingleton.instance
  }
}

export default AccountViewModelSingleton