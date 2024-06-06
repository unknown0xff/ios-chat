//
//  Localizable.swift
//  ios-hello9

enum L10n {
    private static var table = "InfoPlist"

    static var tab_title_wht: String {
        return L10n.tr("tab_title_wht")
    }
}

extension L10n {
    private static func tr(_ key: String, _ args: CVarArg...) -> String {
        let currentTable = table
        let format = Bundle.main.localizedString(forKey: key, value: "", table: currentTable)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

