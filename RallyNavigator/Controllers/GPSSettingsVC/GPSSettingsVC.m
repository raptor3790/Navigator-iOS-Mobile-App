//  The converted code is limited to 2 KB.
//  Upgrade your plan to remove this limitation.
//
//  Converted to Swift 4 by Swiftify v4.2.20547 - https://objectivec2swift.com/
//
//  GPSSettingsVC.m
//  RallyNavigator
//
//  Created by C205 on 22/12/17.
//  Copyright © 2017 C205. All rights reserved.
//
enum GPSRecordingAccuracy : Int {
    case trackPointRecordingFrequency = 0
    case trackPointAngleFilter = 1
    case tulipAngle = 2
}
class GPSSettingsVC {
    func viewDidLoad() {
        super.viewDidLoad()
        title = "GPS Recording Accuracy"
        if DefaultsValues.getBooleanValueFromUserDefaults_(forKey: kIsNightView) {
            tblGPSSettings.backgroundColor = UIColor.black
        } else {
            tblGPSSettings.backgroundColor = UIColor.white
        }
        tblGPSSettings.tableFooterView = UIView(frame: CGRect.zero)
    }
    func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
// MARK: - UIButton Click Events
    @IBAction func btnDismissClicked(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true)
    }
// MARK: - UITableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var strAlertMsg = ""
        switch indexPath.row {
            case GPSRecordingAccuracy.trackPointRecordingFrequency.rawValue:
                strAlertMsg = "Please enter track point recording frequency amount in meters"
                return
            case GPSRecordingAccuracy.trackPointAngleFilter.rawValue:
                strAlertMsg = "Please enter track point angle filter"
                return
            case GPSRecordingAccuracy.tulipAngle.rawValue:
                strAlertMsg = "Please enter tulip angle"
            default:
                break
        }
//
//  The converted code is limited to 2 KB.
//  Upgrade your plan to remove this limitation.
//
//  %< ----------------------------------------------------------------------------------------- %<
