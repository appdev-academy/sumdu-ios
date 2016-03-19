//
//  Alert.swift
//  SumDU
//
//  Created by Maksym Skliarov on 1/28/16.
//  Copyright © 2016 AppDecAcademy. All rights reserved.
//

import UIKit
import SVProgressHUD

class Alert {
    class func showWithStatus(status: String) {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showSuccessWithStatus(status, maskType: SVProgressHUDMaskType.Gradient)
        })
    }
    
    class func showWithError(error: String) {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showErrorWithStatus(error, maskType: SVProgressHUDMaskType.Gradient)
        })
    }
    
    class func showWithStatus() {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Gradient)
        })
    }
    
    class func dismiss() {
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.dismiss()
        })
    }
    
    // MARK: - Helpers
    
    class func showSuccessStatus() {
        Alert.showWithStatus(NSLocalizedString("Done", comment: ""))
    }
    
    class func showNetworkingError() {
        Alert.showWithError(NSLocalizedString("Please, check your network connection or try again later", comment: ""))
    }
}