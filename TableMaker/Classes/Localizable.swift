import Foundation

public enum Localizable: String {
    case TakePhoto = "TakePhoto"
    case ChooseFromAlbum = "ChooseFromAlbum"
    case Cancel = "Cancel"
    case PhotoLibraryAccessSetting = "PhotoLibraryAccessSetting"
    case CameraAccessSettings = "CameraAccessSettings"
    case Error = "Error"
    case OK = "OK"
}

public extension Localizable {
    var localized: String {
//        let bundle = Bundle(identifier: "TableMaker-TableMaker")
//        return NSLocalizedString(rawValue, tableName: "Localizable", bundle: bundle! ,comment: "")
        return NSLocalizedString(rawValue, tableName: "Localizable", comment: "")
    }
}
