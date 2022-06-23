//
//  RTCustomAlert.swift
//  RTCustomAlert
//
//  Created by Rohit on 19/10/20.
//

import UIKit
import RxCocoa
import RxSwift

protocol RTCustomAlertDelegate: class {
    func okButtonPressed(_ alert: RTCustomAlert, alertTag: Int)
    func cancelButtonPressed(_ alert: RTCustomAlert, alertTag: Int)
}
class RTCustomAlert: UIViewController {
    var timer = Timer()
    var totalTime = 600
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var alertView: UIView!
    
    var alertTitle = ""
    var alertMessage = ""
    var okButtonTitle = "Ok"
    var cancelButtonTitle = "Cancel"
    var alertTag = 0
    var statusImage = UIImage.init(named: "smiley")
    var isCancelButtonHidden = false
    
    weak var delegate: RTCustomAlertDelegate?

    init() {
        super.init(nibName: "RTCustomAlert", bundle: Bundle(for: RTCustomAlert.self))
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAlert()
        startTimer()
    }
    
    func show() {
        if #available(iOS 13, *) {
            UIApplication.shared.windows.first?.rootViewController?.present(self, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController!.present(self, animated: true, completion: nil)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sourceObservable?.dispose()
    }
    
    func setupAlert() {
        titleLabel.text = alertTitle
        messageLabel.text = alertMessage
        statusImageView.image = statusImage
        okButton.setTitle(okButtonTitle, for: .normal)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.isHidden = isCancelButtonHidden
    }
    @IBAction func actionOnOkButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.okButtonPressed(self, alertTag: alertTag)
//        setupRX()
//        sourceObservable = nil
    }
    @IBAction func actionOnCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelButtonPressed(self, alertTag: alertTag)
    }
    
    func startTimer() {
//           timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        //turn thi rx timer
        
        Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
                .take(self.totalTime+1)
                .subscribe(onNext: { timePassed in
                    let count = self.totalTime - timePassed
                    print(count)
                    self.updateTime()

                }, onCompleted: {
                    print("count down complete")
                })
       }
    @objc func updateTime() {
            messageLabel.text = "\(timeFormatted(totalTime))"
        

            if totalTime != 0 {
                totalTime -= 1
            } else {
                self.messageLabel.text = "Time limit has finished!!.."
            }
        }

//        func endTimer() {
//            timer.invalidate()
//        }

        func timeFormatted(_ totalSeconds: Int) -> String {
            let seconds: Int = totalSeconds % 60
            let minutes: Int = (totalSeconds / 60) % 60
            //     let hours: Int = totalSeconds / 3600
            return String(format: "%02d:%02d", minutes, seconds)
        }
//    var disposeBag = DisposeBag()
//
//    func setupRX() {
//        sourceObservable = self.okButton.rx.tap.subscribe(onNext : { _ in
//            print("Hola mundo")
//            self.sourceObservable = nil
//            self.sourceObservable?.dispose()
//        })
//    }
    var sourceObservable: Disposable?
   
}
