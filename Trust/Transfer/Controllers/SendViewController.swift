// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Geth
import Eureka
import JSONRPCKit
import APIKit
import QRCodeReaderViewController

protocol SendViewControllerDelegate: class {
    func didPressConfirm(transaction: UnconfirmedTransaction, transferType: TransferType, in viewController: SendViewController)
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController)
}

class SendViewController: FormViewController {

    private lazy var viewModel: SendViewModel = {
        return .init(transferType: self.transferType)
    }()
    private let keystore = EtherKeystore()
    weak var delegate: SendViewControllerDelegate?

    struct Values {
        static let address = "address"
        static let amount = "amount"
    }

    let account: Account
    let transferType: TransferType

    var addressRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.address) as? TextFloatLabelRow
    }
    var amountRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.amount) as? TextFloatLabelRow
    }

    init(account: Account, transferType: TransferType = .ether(destination: .none)) {
        self.account = account
        self.transferType = transferType

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        form = Section()
            +++ Section("")

            <<< AppFormAppearance.textFieldFloat(tag: Values.address) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                button.setImage(R.image.qr_code_icon(), for: .normal)
                button.addTarget(self, action: #selector(self.openReader), for: .touchUpInside)

                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("send.recipientAddress", value: "Recipient Address", comment: "")
                cell.textField.rightView = button
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.amount) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "\(self.viewModel.symbol) " + NSLocalizedString("Send.AmountPlaceholder", value: "Amount", comment: "")
                cell.textField.keyboardType = .decimalPad
            }

            +++ Section {
                $0.hidden = Eureka.Condition.function([Values.amount], { _ in
                    return self.amountRow?.value?.isEmpty ?? true
                })
            }
    }

    func clear() {
        let fields = [addressRow, amountRow]
        for field in fields {
            field?.value = ""
            field?.reload()
        }
    }

    func send() {
        let errors = form.validate()
        guard errors.isEmpty else { return }

        let addressString = addressRow?.value?.trimmed ?? ""
        let amountString = amountRow?.value?.trimmed ?? ""

        let address = Address(address: addressString)
        let amount = amountString.doubleValue

        let transaction = UnconfirmedTransaction(
            transferType: transferType,
            amount: amount,
            address: address
        )
        self.delegate?.didPressConfirm(transaction: transaction, transferType: transferType, in: self)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SendViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismiss(animated: true, completion: nil)

        guard let result = QRURLParser.from(string: result) else { return }
        addressRow?.value = result.address
        addressRow?.reload()
    }
}
