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
    
    private static var currentInstance: Database?
    
    static var sharedInstance : Database {
        guard let saveInstance = Database.currentInstance else {
            let instance = Database()
            self.currentInstance = instance
            return instance
        }
        return saveInstance
    }
    
    var userData: [User] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let deleget = UIApplication.shared.delegate as! AppDelegate
    

    func save(){
        deleget.saveContext()
    }
    
    //liefert den user oder nil zurück als optional
    func getUser()-> User?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "id == %@", argumentArray: [1])
        do{
            let user = try context.fetch(request) as! [User]
            if user.count > 0 {
            return user[0]
            }
        }catch{
            print("fehler beim laden des Users")
        }
        return nil
    }
    
    //erzeugt einen user wenn noch keiner vorhanden ist, wenn fehlschlägt false
    func createUser(id:Int16,alter: Int16,cheatPlus:Double,firstlounge:Bool,geschlecht:String,gewicht:Double,groesse:Double,kcalZiel: Double,kfa:Double,activ:Double,activity:Int16,start:Date,auto:Bool,currentgewicht:Double,ground:Double,autoGround:Bool,ibs:Bool)-> Bool{
        let user: User? = self.getUser()
        if user != nil{
            return false
        }
        let d = DateFormatter()
        d.calendar = Calendar.current
        d.dateFormat = "HH:mm dd-MM-yyyy"
        let neuerUser = User(context: context)
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
        neuerUser.notiDate0 = d.date(from: "08:00 01.01.2017")
        neuerUser.notiDate1 = d.date(from: "12:00 01.01.2017")
        neuerUser.notiDate2 = d.date(from: "20:00 01.01.2017")
        neuerUser.noti0 = false
        neuerUser.noti1 = false
        neuerUser.noti2 = false
        neuerUser.ibs = ibs
        
        neuerUser.inAppPro = false
        neuerUser.inAppSup = false
        neuerUser.inApp3 = false
        save()
        return true
    }
    
    // läd ein tag eines datum aus der DB
    func getTag(datum : Date) -> Tag?{
        var calender = Calendar.current
       // calender.timeZone = TimeZone(secondsFromGMT: 0)!
        let calendar = Calendar.current
        let daate = calendar.startOfDay(for: datum)
        
        let day = calender.component(.day, from: daate)
        let month = calender.component(.month, from: daate)
        let year = calender.component(.year, from: daate)
        let time = calender.timeZone.secondsFromGMT()
        let gtm  = ((time/60)/60)
        var dateA:String = ""
        if gtm >= 0 {
            dateA = "\(day)-\(month)-\(year) GMT+\(gtm)"
        }else{
            dateA = "\(day)-\(month)-\(year) GMT\(gtm)"
           
        }
        
        let dateformat = DateFormatter()
        dateformat.calendar = Calendar.current
        dateformat.dateFormat = "dd-MM-yyyy ZZZZ"
        let dateSA = dateformat.date(from: dateA)
        let dateSB = calender.date(byAdding: .day,value: 1, to: dateSA!)
        if dateSA == nil || dateSB == nil{
            return nil
        }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        request.predicate = NSPredicate(format: "datum >= %@ AND datum < %@", argumentArray: [dateSA!,dateSB!])
        do{
            let tage = try context.fetch(request) as! [Tag]
            if tage.count > 0 && tage.count < 2 {
                return tage[0]
            }
        }catch{
            print("fehler beim laden der Tage")
        }
      return nil
    }
    
    
    //fügt ein neues tag obj in die datenbank hinzu
    func addTag(cheatday:Bool,datum:Date,differenz:Double,ziel:Double,gewicht:Double?,old:Bool,activity:Double,ground:Double,dont:Bool){
        
        let calendar = Calendar.current
        let daate = calendar.startOfDay(for: datum)
        
        let tag = Tag(context:context)
        tag.cheatDay = cheatday
        tag.datum = daate
        tag.differenz = differenz
        tag.ziel = ziel
        tag.oldDay = old
        tag.activity = activity
        tag.groundKcal = ground
        tag.dontTrack = dont
        if gewicht != nil{
        tag.gewicht = gewicht!
        }
        let user = getUser()
        if user != nil{
            user!.addToTag(tag)
            save()
        }
    }
    
    //liefert alle Kcal Objkte
    func allKcals()->[Kcal]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Kcal")
        do{
            let kcal = try context.fetch(request) as! [Kcal]
                return kcal
        }catch{
            print("fehler beim laden der Tage")
            return nil
        }
    }
    
    //fügt ein Kcal Obj einem tag hinzu
    func addKcal(tag: Tag,datum : Date, kcalWert : Double,health : Int16,name:String){
        let kcal = Kcal(context:context)
        kcal.datum = datum
        kcal.kcalWert = kcalWert
        kcal.tag = tag
        kcal.health = health
        kcal.name = name
        save()
        
    }
    
    //löscht einen Tag aus der db muss noch gespeichert werden
    func rmvDay(day:Tag){
        context.delete(day)
    }
    
    //löscht ein Kcal Obj
    func rmvKcal(kcal:Kcal){
        context.delete(kcal)
        save()
    }
    
    //fügt einen Quickadd hinzu einem user hinzu
    func addQuickadd(name : String,kcal:Double,status:Int16,gramm:Int64,used:Int64,last:Date,onHome:Bool,size: Int64 = 100){
        let quickadd = Quickadd(context:context)
        quickadd.name = name
        quickadd.kcal = kcal
        quickadd.status = status
        quickadd.gramm = gramm
        quickadd.used = used
        quickadd.last = last
        quickadd.onHome = onHome
        quickadd.size = size
        getUser()!.addToQuickadds(quickadd)
        save()
    }
    
    ///läd alle Quickadds aus der db
    func getQuickadds(withFilter f: String)-> [Quickadd]{
        let fetchRequest = NSFetchRequest<Quickadd>(entityName: "Quickadd")
        let safeFilter = f.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if safeFilter.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", safeFilter)
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let result = try self.context.fetch(fetchRequest)
            return result
        }catch {
            print("Error while fetching data from Database in function: \(#function)")
            return []
        }
    }
    
    ///löscht ein Quickadd
    func rmvQuickadd(r:Quickadd){
        context.delete(r)
        save()
    }
    
}
