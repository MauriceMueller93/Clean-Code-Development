//
//  Database.swift
//  KcalTrack
//
//  Created by Maurice on 01.02.17.
//  Copyright © 2017 Momo App's. All rights reserved.
//

import UIKit
import CoreData

class Database  {
    
    // MARK: - properties
    
    static let sharedInstance = Database()
    
    
    // MARK: - Database access
    
    func getMoc()-> NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    func saveDatabaseContext() {
        guard let moc = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            print("critical can't get NSManagedObjectContext to save Database")
            return
        }
        do {
            try moc.save()
        }catch {
            print("critical can't save Database")
        }
    }
    
    
    // MARK: - request data from Database
    
    func getSignInUser()-> User? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [1])
        do {
            let user = try getMoc()?.fetch(request) as! [User]
            guard user.count > 0 else {return nil}
            return user[0]
        }catch {
            print("fehler beim laden des Users")
            return nil
        }
    }
    
    func getDayFromDatabase(datum : Date) -> Tag? {
        guard let dateRange = self.getDayString(fromDate: datum) else {return nil}
        guard let startDate = dateRange.start else {return nil}
        guard let endDate = dateRange.end else {return nil}
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        request.predicate = NSPredicate(format: "datum >= %@ AND datum < %@", argumentArray: [startDate, endDate])
        do {
            let tage = try getMoc()?.fetch(request) as! [Tag]
            if tage.count > 0 && tage.count < 2 { return tage[0]}
            return nil
        } catch {
            print("fehler beim laden der Tage")
            return nil
        }
    }
    
    func getKcalObjectsFromDatabase()-> [Kcal] {
        
        guard let saveMoc = getMoc() else { return []}
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Kcal")
        
        do{
            let kcal = try saveMoc.fetch(request) as? [Kcal]
            return kcal ?? []
        }catch{
            print("fehler beim laden der Tage")
            return []
        }
    }
    
    func getQuickadds(withFilter f: String)-> [Quickadd] {
        
        let safeFilter = f.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let fetchRequest = NSFetchRequest<Quickadd>(entityName: "Quickadd")
        if safeFilter.count > 0 { fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", safeFilter) }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let result = try getMoc()?.fetch(fetchRequest)
            return result ?? []
        }catch {
            print("Error while fetching data from Database in function: \(#function)")
            return []
        }
    }
    
    
    // MARK: - write data to Database
    
    func createUser(id: Int16, alter: Int16, cheatPlus: Double, firstlounge: Bool, geschlecht: String, gewicht: Double, groesse: Double, kcalZiel: Double, kfa:Double, activ:Double, activity:Int16, start:Date, auto:Bool, currentgewicht:Double, ground:Double, autoGround:Bool, ibs:Bool)-> Bool {
        guard !self.isUserExists() else {return false}
        self.saveDatabaseContext()
        self.createUserDBObject(id: id, alter: alter, cheatPlus: cheatPlus, firstlounge: firstlounge, geschlecht: geschlecht, gewicht: gewicht, groesse: groesse, kcalZiel: kcalZiel, kfa: kfa, activ: activ, activity: activity, start: start, auto: auto, currentgewicht: currentgewicht, ground: ground, autoGround: autoGround, ibs: ibs)
        return true
    }
    
    func addTag(cheatday:Bool, datum:Date, differenz:Double, ziel:Double, gewicht:Double?, old:Bool, activity:Double, ground:Double, dont:Bool) {
        
        guard let saveMoc = getMoc() else {return}
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: datum)
        
        let tag = Tag(context: saveMoc)
        tag.cheatDay = cheatday
        tag.datum = date
        tag.differenz = differenz
        tag.ziel = ziel
        tag.oldDay = old
        tag.activity = activity
        tag.groundKcal = ground
        tag.dontTrack = dont
        
        if gewicht != nil { tag.gewicht = gewicht ?? 0 }
        if let user = getSignInUser() { user.addToTag(tag) }
        saveDatabaseContext()
    }
    
    func addKcalsToDay(tag: Tag, datum : Date, kcalWert : Double, health : Int16, name: String) {
        
        guard let saveMoc = getMoc() else { return }
        
        let kcal = Kcal(context: saveMoc)
        kcal.datum = datum
        kcal.kcalWert = kcalWert
        kcal.tag = tag
        kcal.health = health
        kcal.name = name
        saveDatabaseContext()
    }
    
    func addQuickadd(name: String, kcal: Double, status: Int16, gramm: Int64, used: Int64, last: Date, onHome: Bool, size: Int64 = 100) {
        guard let saveMoc = self.getMoc() else {return}
        
        let quickadd = Quickadd(context:saveMoc)
        quickadd.name = name
        quickadd.kcal = kcal
        quickadd.status = status
        quickadd.gramm = gramm
        quickadd.used = used
        quickadd.last = last
        quickadd.onHome = onHome
        quickadd.size = size
        
        getSignInUser()?.addToQuickadds(quickadd)
        saveDatabaseContext()
    }
    
    
    // MARK: - remove data from Database
    
    func remove(day: Tag) {
        guard let saveMoc = getMoc() else { return }
        saveMoc.delete(day)
        saveDatabaseContext()
    }
    
    func remove(kcal: Kcal){
        guard let saveMoc = getMoc() else { return }
        saveMoc.delete(kcal)
        saveDatabaseContext()
    }
    
    func remove(quickadd:Quickadd){
        guard let saveMoc = getMoc() else { return }
        saveMoc.delete(quickadd)
        saveDatabaseContext()
    }
    
    
    // MARK: - Objekt mapper
    
    
    private func createUserDBObject(id: Int16, alter: Int16, cheatPlus: Double, firstlounge: Bool, geschlecht: String, gewicht: Double, groesse: Double, kcalZiel: Double, kfa:Double, activ:Double, activity:Int16, start:Date, auto:Bool, currentgewicht:Double, ground:Double, autoGround:Bool, ibs:Bool) {
        
        guard let saveMoc = getMoc() else {return}
        
        let neuerUser = User(context: saveMoc)
        neuerUser.id = id
        neuerUser.alter = alter
        neuerUser.cheatPlus = cheatPlus
        neuerUser.firstlounge = firstlounge
        neuerUser.geschlecht = geschlecht
        neuerUser.gewicht = gewicht
        neuerUser.groesse = groesse
        neuerUser.kcalZiel = kcalZiel
        neuerUser.kfa = kfa
        neuerUser.aktiv = activ
        neuerUser.activity = activity
        neuerUser.startDatum = start
        neuerUser.auto = auto
        neuerUser.currentGewicht = currentgewicht
        neuerUser.groundZiel = ground
        neuerUser.autoground = autoGround
        neuerUser.askForNoti = false
        neuerUser.notiDate0 = getDateFormatter(withFormate: "HH:mm dd-MM-yyyy").date(from: "08:00 01.01.2017")
        neuerUser.notiDate1 = getDateFormatter(withFormate: "HH:mm dd-MM-yyyy").date(from: "12:00 01.01.2017")
        neuerUser.notiDate2 = getDateFormatter(withFormate: "HH:mm dd-MM-yyyy").date(from: "20:00 01.01.2017")
        neuerUser.noti0 = false
        neuerUser.noti1 = false
        neuerUser.noti2 = false
        neuerUser.ibs = ibs
        neuerUser.inAppPro = false
        neuerUser.inAppSup = false
        neuerUser.inApp3 = false
    }
    
    
    // MARK: - Date checker
    
    private func getDayString(fromDate date: Date)-> (start: Date?, end: Date?)? {
        
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        
        let day = calendar.component(.day, from: start)
        let month = calendar.component(.month, from: start)
        let year = calendar.component(.year, from: start)
        let time = calendar.timeZone.secondsFromGMT()
        let gtm  = time / 60 / 60
        
        var startDateString = ""
        if gtm >= 0 {
            startDateString = "\(day)-\(month)-\(year) GMT+\(gtm)"
        }else{
            startDateString = "\(day)-\(month)-\(year) GMT\(gtm)"
        }
        
        let dateformat = self.getDateFormatter(withFormate: "dd-MM-yyyy ZZZZ")
        let startDateResult = dateformat.date(from: startDateString)
        let endDateResult = calendar.date(byAdding: .day,value: 1, to: startDateResult!)
        if startDateResult == nil || endDateResult == nil {return nil}
        return (start: startDateResult, end: endDateResult)
    }
    
    private func getDateFormatter(withFormate formate: String)-> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = formate
        return formatter
    }
    
    
    // MARK: - validation
    
    private func isUserExists()-> Bool {
        return self.getSignInUser() != nil
    }
    
    
    
    

}
