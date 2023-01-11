//
//  NotificationManager.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UserNotifications
import FirebaseMessaging

extension Notification.Name {
    static let FCMToken = Notification.Name("FCMToken")
}

class UserNotificationManager {
    
    // MARK: - Constants
    
    static let shared = UserNotificationManager()
    
    // MARK: - Public Methods
    
    func checkIfAlreadyAddedNotification(identifier: NotificationIdentifier, completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().getNotificationCategories { (categories) in
            let isEmpty: Bool = categories.filter { $0.identifier == identifier.rawValue }.isEmpty
            completion?(isEmpty)
        }
    }
    
    func addDailyNotification(identifier: NotificationIdentifier, isLinked: Bool? = nil) {
        removeDailyNotifications([NotificationIdentifier.DailyNotification1930, NotificationIdentifier.DailyRetention1200])
        
//        guard let isOn = UserDefaults.standard.object(forKey: identifier.defaultsKey) as? Bool, isOn else { return }
//        if identifier == .DailyNotification1930,
//            let isLinked = isLinked, !isLinked {
//            removeDailyNotifications([NotificationIdentifier.DailyNotification1930])
//            return
//        }
//        guard let createdAt = UserManager.shared.userModel?.createdAt else { return }
//        let makeDate: Date = Date(timeIntervalSince1970: TimeInterval(createdAt))
//        let content = UNMutableNotificationContent()
//
//        content.sound = UNNotificationSound.default
//        content.badge = 1
//        content.categoryIdentifier = identifier.rawValue
//        content.title = identifier.contentTitle
//        content.body = identifier.contentBody
//
//        var logKey: String = "가계부_리텐션_Push_등록_발송"
//        var hour: Int = 12
//        if identifier == .DailyNotification1930 {
//            logKey = "가계부_소비내역_Push_등록_발송"
//            hour = 19
//        }
//        let date = Calendar.current.date(bySettingHour: hour, minute: makeDate.minute, second: makeDate.second, of: Date()) ?? Date()
//        let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
//        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { (error) in
//            if let error = error {
//                Log.e("Error \(error.localizedDescription)")
//            } else {
//                GlobalFunction.FirLog(string: logKey, "\(hour):\(makeDate.minute):\(makeDate.second)")
//            }
//        }
    }
    
    func removeDailyNotifications(_ identifiers: [NotificationIdentifier] = NotificationIdentifier.allCases) {
        let idRawValues = identifiers.map { $0.rawValue }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idRawValues)
    }

    func addCardPaymentDateNotification() {
        removeDailyNotifications([NotificationIdentifier.CardPaymentDate1200])
//        let identifier = NotificationIdentifier.CardPaymentDate1200
//        guard let isOn = UserDefaults.standard.object(forKey: identifier.defaultsKey) as? Bool, isOn else { return }
//        guard let createdAt = UserManager.shared.userModel?.createdAt else { return }
//        let makeDate: Date = Date(timeIntervalSince1970: TimeInterval(createdAt))
//        var dateAndCard = [String: [String]]()
//
//        CardPaymentRealmProxy().getPaymentDetails().results.forEach { (paymentDetails) in
//            guard let estDate = paymentDetails.estDate, estDate != "", let estAmt = paymentDetails.estAmt, estAmt != "0", let fCodeName = paymentDetails.fCodeName else {return}
//
//            if var cardNameList = dateAndCard[estDate] {
//                cardNameList.append(fCodeName)
//            } else {
//                dateAndCard[estDate] = [fCodeName]
//            }
//        }
//        dateAndCard.forEach { (estDate, value) in
//            if estDate.count != 8 {return}
//
//            guard let month = Int(estDate[4..<6]), let day = Int(estDate[6..<8]) else {return}
//
//            let content = UNMutableNotificationContent()
//            let categoryIdentifier = "\(identifier.rawValue)\(estDate[4..<8])"
//            let cardNames = value.joined(separator: ", ")
//
//            content.title = identifier.contentTitle
//            content.body = "\(month)월 \(day)일은 \(cardNames) 결제 예정일 입니다."
//            content.sound = UNNotificationSound.default
//            content.badge = 1
//            content.categoryIdentifier = categoryIdentifier
//
//            var dateComp = DateComponents()
//            dateComp.month = month
//            dateComp.day = day > 1 ? day - 1 : day
//            dateComp.hour = 12
//            dateComp.minute = makeDate.minute
//            dateComp.second = makeDate.second
//
//            let triggerDaily = dateComp
//            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
//            let request = UNNotificationRequest(identifier: categoryIdentifier, content: content, trigger: trigger)
//
//            UNUserNotificationCenter.current().add(request) { (error) in
//                if let error = error {
//                    Log.e("Error \(error.localizedDescription)")
//                }
//            }
//        }
    }
    
    func removeNotificationFromQuiz(quizId: String) {
        let identifier = "QuizNotification\(quizId)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func removeCardPaymentDateNotification() {
        var identifiers = [String]()
        
        CardPaymentRealmProxy().getPaymentDetails().results.forEach { (paymentDetails) in
            guard let estDate = paymentDetails.estDate, estDate.count == 8 else {return}
            identifiers.append("\(NotificationIdentifier.CardPaymentDate1200.rawValue)\(estDate[4..<8])")
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func addNotification(identifier: NotificationIdentifier) {
        let content = UNMutableNotificationContent()
        
        content.body = identifier.contentBody
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = identifier.rawValue
        
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                Log.e("Error \(error.localizedDescription)")
            }
        }
    }
    
    func addPointUpdatedNotification(point: String) {
        let identifier = NotificationIdentifier.Property
        let content = UNMutableNotificationContent()
        content.body = point + " 캐시가 적립되었어요."
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = identifier.rawValue
        
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                Log.e("Error \(error.localizedDescription)")
            }
            UserManager.shared.getUser()
        }
    }
    
    func removePointUpdatedNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [UserDefaultKey.kPointUpdatedNotification.rawValue])
    }
    
    func addNotificationFromFCM(data: [AnyHashable: Any]) {
        guard let message = getMessageFromFCM(data: data) else {return}
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.body = message
            content.sound = UNNotificationSound.default
            content.userInfo = data
            
            let request = UNNotificationRequest(identifier: message, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (_) in
                UserManager.shared.getUser()
            })
        } else {
            let localNotification = UILocalNotification()
            localNotification.alertBody = message
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = data
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
    func subscribeTopics(createdAt: Int) {
        var fixedNumberStr = "\(createdAt % 1000)"
        if fixedNumberStr.count == 2 {
            fixedNumberStr = "0\(fixedNumberStr)"
        } else if fixedNumberStr.count == 1 {
            fixedNumberStr = "00\(fixedNumberStr)"
        }
        
        Messaging.messaging().subscribe(toTopic: "cashdoc_all_\(fixedNumberStr)")
    }
    
    // MARK: - Private methods
    
    private func getMessageFromFCM(data: [AnyHashable: Any]) -> String? {
        guard let type = data["type"] as? String else {return nil}
        
        let messageType = FCMMessageType(rawValue: type)

        return messageType?.createMessage(data: data)
    }
}
